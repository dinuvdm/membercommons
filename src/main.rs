// src/main.rs
use actix_cors::Cors;
use actix_web::{web, App, HttpResponse, HttpServer, Result, middleware};
use anyhow::Context;
use chrono::{Utc, NaiveDate};
use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{postgres::PgPoolOptions, Pool, Postgres, Row, Column, ValueRef};
use std::sync::Arc;
use std::collections::HashMap;
use uuid::Uuid;
use url::Url;

mod import;
mod google;

// Configuration structure
#[derive(Debug, Deserialize)]
struct Config {
    database_url: String,
    gemini_api_key: String,
    server_host: String,
    server_port: u16,
}

impl Config {
    fn from_env() -> anyhow::Result<Self> {
        // Try to load from .env file first
        dotenv::dotenv().ok();
        
        // Also check for a config.toml file
        if let Ok(config_str) = std::fs::read_to_string("config.toml") {
            toml::from_str(&config_str).context("Failed to parse config.toml")
        } else {
            // Fall back to environment variables
            Ok(Config {
                database_url: std::env::var("DATABASE_URL")
                    .unwrap_or_else(|_| "postgres://user:password@localhost/suitecrm".to_string()),
                gemini_api_key: std::env::var("GEMINI_API_KEY")
                    .unwrap_or_else(|_| "dummy_key".to_string()),
                server_host: std::env::var("SERVER_HOST")
                    .unwrap_or_else(|_| "127.0.0.1".to_string()),
                server_port: std::env::var("SERVER_PORT")
                    .unwrap_or_else(|_| "8081".to_string())
                    .parse()
                    .unwrap_or(8081),
            })
        }
    }
}

// CLI structure
#[derive(Parser)]
#[command(name = "suitecrm")]
#[command(about = "SuiteCRM with Gemini AI Integration", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Start the REST API server
    Serve,
    /// Initialize database schema
    InitDb,
}

// API State
struct ApiState {
    db: Pool<Postgres>,
    config: Config,
}

// Request/Response types for projects
#[derive(Debug, Serialize, Deserialize)]
struct CreateProjectRequest {
    name: String,
    description: Option<String>,
    status: Option<String>,
    estimated_start_date: Option<String>,
    estimated_end_date: Option<String>,
}

#[derive(Debug, Serialize)]
struct TableInfo {
    name: String,
    row_count: i64,
}

#[derive(Serialize)]
struct DatabaseResponse {
    success: bool,
    message: Option<String>,
    error: Option<String>,
    data: Option<serde_json::Value>,
}

#[derive(Serialize)]
struct TableInfoDetailed {
    name: String,
    rows: Option<i64>,
    description: Option<String>,
}

#[derive(Serialize)]
struct ConnectionInfo {
    server_version: String,
    database_name: String,
    current_user: String,
    connection_count: i64,
}

#[derive(Deserialize)]
struct QueryRequest {
    query: String,
}

#[derive(Serialize, Clone)]
struct EnvDatabaseConfig {
    server: String,
    database: String,
    username: String,
    port: u16,
    ssl: bool,
}

#[derive(Serialize)]
struct EnvConfigResponse {
    database: Option<EnvDatabaseConfig>,
    database_connections: Vec<DatabaseConnection>,
    gemini_api_key_present: bool,
    google_project_id: Option<String>,
    google_user_email: Option<String>,
    google_org_id: Option<String>,
    google_billing_id: Option<String>,
    google_service_key: Option<String>,
}

#[derive(Serialize)]
struct DatabaseConnection {
    name: String,
    display_name: String,
    config: EnvDatabaseConfig,
}

#[derive(Deserialize)]
struct SaveEnvConfigRequest {
    google_project_id: Option<String>,
    google_user_email: Option<String>,
    google_org_id: Option<String>,
    google_billing_id: Option<String>,
    google_service_key: Option<String>,
}

#[derive(Deserialize)]
struct FetchCsvRequest {
    url: String,
}

// Health check endpoint
async fn health_check(data: web::Data<Arc<ApiState>>) -> Result<HttpResponse> {
    match sqlx::query("SELECT 1").fetch_one(&data.db).await {
        Ok(_) => Ok(HttpResponse::Ok().json(json!({
            "status": "healthy",
            "database_connected": true
        }))),
        Err(e) => Ok(HttpResponse::Ok().json(json!({
            "status": "unhealthy",
            "database_connected": false,
            "error": e.to_string()
        }))),
    }
}

// Get environment configuration
async fn get_env_config() -> Result<HttpResponse> {
    let mut database_config = None;
    let mut database_connections = Vec::new();
    
    // Scan for all database URLs in environment variables
    for (key, value) in std::env::vars() {
        if key.ends_with("_URL") && value.starts_with("postgres://") {
            if let Ok(url) = Url::parse(&value) {
                let server = format!("{}:{}", 
                    url.host_str().unwrap_or("unknown"), 
                    url.port().unwrap_or(5432)
                );
                let database = url.path().trim_start_matches('/').to_string();
                let username = url.username().to_string();
                let ssl = value.contains("sslmode=require");
                
                let config = EnvDatabaseConfig {
                    server,
                    database,
                    username,
                    port: url.port().unwrap_or(5432),
                    ssl,
                };
                
                // Set the default database (DATABASE_URL) as the main config
                if key == "DATABASE_URL" {
                    database_config = Some(config.clone());
                }
                
                // Add to connections list with display name
                let display_name = match key.as_str() {
                    "DATABASE_URL" => "MemberCommons Database (Default)".to_string(),
                    "EXIOBASE_URL" => "EXIOBASE Database".to_string(),
                    _ => {
                        let name = key.replace("_URL", "").replace("_", " ");
                        format!("{} Database", name.split_whitespace()
                            .map(|word| {
                                let mut chars = word.chars();
                                match chars.next() {
                                    Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
                                    None => String::new(),
                                }
                            })
                            .collect::<Vec<_>>()
                            .join(" "))
                    }
                };
                
                database_connections.push(DatabaseConnection {
                    name: key,
                    display_name,
                    config,
                });
            }
        }
    }
    
    // Check if Gemini API key is present (but don't expose the actual key)
    let gemini_api_key_present = std::env::var("GEMINI_API_KEY").is_ok();
    
    // Get Google configuration values
    let google_project_id = std::env::var("GOOGLE_PROJECT_ID").ok();
    let google_user_email = std::env::var("GOOGLE_USER_EMAIL").ok();
    let google_org_id = std::env::var("GOOGLE_ORG_ID").ok();
    let google_billing_id = std::env::var("GOOGLE_BILLING_ID").ok();
    let google_service_key = std::env::var("GOOGLE_SERVICE_KEY").ok();
    
    Ok(HttpResponse::Ok().json(EnvConfigResponse {
        database: database_config,
        database_connections,
        gemini_api_key_present,
        google_project_id,
        google_user_email,
        google_org_id,
        google_billing_id,
        google_service_key,
    }))
}

// Save environment configuration to .env file
async fn save_env_config(req: web::Json<SaveEnvConfigRequest>) -> Result<HttpResponse> {
    use std::fs::OpenOptions;
    use std::io::{BufRead, BufReader, Write};
    
    let env_path = ".env";
    let mut env_lines = Vec::new();
    let mut updated_keys = std::collections::HashSet::<String>::new();
    
    // Read existing .env file if it exists
    if let Ok(file) = std::fs::File::open(env_path) {
        let reader = BufReader::new(file);
        for line in reader.lines() {
            if let Ok(line) = line {
                env_lines.push(line);
            }
        }
    }
    
    // Helper function to update or add environment variable
    let update_env_var = |env_lines: &mut Vec<String>, updated_keys: &mut std::collections::HashSet<String>, key: &str, value: &Option<String>| {
        if let Some(val) = value {
            if !val.is_empty() {
                let new_line = format!("{}={}", key, val);
                
                // Find and update existing key, or mark for addition
                let mut found = false;
                for line in env_lines.iter_mut() {
                    if line.starts_with(&format!("{}=", key)) {
                        *line = new_line.clone();
                        found = true;
                        break;
                    }
                }
                
                if !found {
                    env_lines.push(new_line);
                }
                updated_keys.insert(key.to_string());
            }
        }
    };
    
    // Update or add new values
    update_env_var(&mut env_lines, &mut updated_keys, "GOOGLE_PROJECT_ID", &req.google_project_id);
    update_env_var(&mut env_lines, &mut updated_keys, "GOOGLE_USER_EMAIL", &req.google_user_email);
    update_env_var(&mut env_lines, &mut updated_keys, "GOOGLE_ORG_ID", &req.google_org_id);
    update_env_var(&mut env_lines, &mut updated_keys, "GOOGLE_BILLING_ID", &req.google_billing_id);
    update_env_var(&mut env_lines, &mut updated_keys, "GOOGLE_SERVICE_KEY", &req.google_service_key);
    
    // Write back to .env file
    match OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(env_path)
    {
        Ok(mut file) => {
            for line in env_lines {
                writeln!(file, "{}", line).map_err(|e| {
                    actix_web::error::ErrorInternalServerError(format!("Failed to write to .env file: {}", e))
                })?;
            }
            
            // Update environment variables in current process
            let set_env_var = |key: &str, value: &Option<String>| {
                if let Some(val) = value {
                    if !val.is_empty() {
                        std::env::set_var(key, val);
                    }
                }
            };
            
            set_env_var("GOOGLE_PROJECT_ID", &req.google_project_id);
            set_env_var("GOOGLE_USER_EMAIL", &req.google_user_email);
            set_env_var("GOOGLE_ORG_ID", &req.google_org_id);
            set_env_var("GOOGLE_BILLING_ID", &req.google_billing_id);
            set_env_var("GOOGLE_SERVICE_KEY", &req.google_service_key);
            
            Ok(HttpResponse::Ok().json(json!({
                "success": true,
                "message": "Configuration saved to .env file",
                "updated_keys": updated_keys.into_iter().collect::<Vec<_>>()
            })))
        }
        Err(e) => {
            Ok(HttpResponse::InternalServerError().json(json!({
                "success": false,
                "error": format!("Failed to write .env file: {}", e)
            })))
        }
    }
}

// Fetch CSV data from external URL (proxy for CORS)
async fn fetch_csv(req: web::Json<FetchCsvRequest>) -> Result<HttpResponse> {
    let url = &req.url;
    
    // Validate URL is from Google Sheets
    if !url.contains("docs.google.com/spreadsheets") {
        return Ok(HttpResponse::BadRequest().json(json!({
            "success": false,
            "error": "Only Google Sheets URLs are allowed"
        })));
    }
    
    match reqwest::get(url).await {
        Ok(response) => {
            if response.status().is_success() {
                match response.text().await {
                    Ok(csv_data) => {
                        if csv_data.trim().is_empty() {
                            Ok(HttpResponse::Ok().json(json!({
                                "success": false,
                                "error": "The spreadsheet appears to be empty or not publicly accessible"
                            })))
                        } else {
                            Ok(HttpResponse::Ok().json(json!({
                                "success": true,
                                "data": csv_data
                            })))
                        }
                    }
                    Err(e) => {
                        Ok(HttpResponse::Ok().json(json!({
                            "success": false,
                            "error": format!("Failed to read response data: {}", e)
                        })))
                    }
                }
            } else {
                Ok(HttpResponse::Ok().json(json!({
                    "success": false,
                    "error": format!("HTTP {}: The spreadsheet may not be publicly accessible or the URL is incorrect", response.status())
                })))
            }
        }
        Err(e) => {
            Ok(HttpResponse::Ok().json(json!({
                "success": false,
                "error": format!("Network error: {}", e)
            })))
        }
    }
}

// Test specific database connection
async fn test_database_connection(path: web::Path<String>) -> Result<HttpResponse> {
    let connection_name = path.into_inner();
    
    // Get the database URL for this connection
    let database_url = match std::env::var(&connection_name) {
        Ok(url) => url,
        Err(_) => {
            return Ok(HttpResponse::BadRequest().json(json!({
                "success": false,
                "error": format!("Connection '{}' not found in environment variables", connection_name)
            })));
        }
    };
    
    // Test the connection
    match PgPoolOptions::new()
        .max_connections(1)
        .connect(&database_url)
        .await
    {
        Ok(pool) => {
            // Test with a simple query
            match sqlx::query("SELECT 1").fetch_one(&pool).await {
                Ok(_) => {
                    // Parse URL for display info
                    if let Ok(url) = Url::parse(&database_url) {
                        let server = format!("{}:{}", 
                            url.host_str().unwrap_or("unknown"), 
                            url.port().unwrap_or(5432)
                        );
                        let database = url.path().trim_start_matches('/').to_string();
                        let username = url.username().to_string();
                        let ssl = database_url.contains("sslmode=require");
                        
                        Ok(HttpResponse::Ok().json(json!({
                            "success": true,
                            "message": "Database connection successful",
                            "connection_name": connection_name,
                            "config": {
                                "server": server,
                                "database": database,
                                "username": username,
                                "port": url.port().unwrap_or(5432),
                                "ssl": ssl
                            }
                        })))
                    } else {
                        Ok(HttpResponse::Ok().json(json!({
                            "success": true,
                            "message": "Database connection successful",
                            "connection_name": connection_name
                        })))
                    }
                }
                Err(e) => {
                    Ok(HttpResponse::Ok().json(json!({
                        "success": false,
                        "error": format!("Query failed: {}", e),
                        "connection_name": connection_name
                    })))
                }
            }
        }
        Err(e) => {
            Ok(HttpResponse::Ok().json(json!({
                "success": false,
                "error": format!("Connection failed: {}", e),
                "connection_name": connection_name
            })))
        }
    }
}



#[derive(Debug, Deserialize)]
struct ClaudeAnalysisRequest {
    prompt: String,
    dataset_info: Option<serde_json::Value>,
}

#[derive(Debug, Serialize)]
struct ClaudeAnalysisResponse {
    success: bool,
    analysis: Option<String>,
    error: Option<String>,
}






// Analyze data with Claude Code CLI
async fn analyze_with_claude_cli(
    req: web::Json<ClaudeAnalysisRequest>,
) -> Result<HttpResponse> {
    match call_claude_code_cli(&req.prompt, &req.dataset_info).await {
        Ok(analysis) => Ok(HttpResponse::Ok().json(ClaudeAnalysisResponse {
            success: true,
            analysis: Some(analysis),
            error: None,
        })),
        Err(e) => {
            eprintln!("Claude Code CLI Error: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(ClaudeAnalysisResponse {
                success: false,
                analysis: None,
                error: Some(e.to_string()),
            }))
        }
    }
}


// Call Claude Code CLI for dataset analysis
async fn call_claude_code_cli(prompt: &str, dataset_info: &Option<serde_json::Value>) -> anyhow::Result<String> {
    use std::process::Command;
    
    // Build the full prompt with dataset context
    let full_prompt = if let Some(dataset) = dataset_info {
        format!("{}\n\nDataset Context:\n{}", prompt, serde_json::to_string_pretty(dataset)?)
    } else {
        prompt.to_string()
    };
    
    println!("Executing Claude Code CLI analysis...");
    
    // Execute claude command with the prompt directly
    let output = Command::new("claude")
        .arg("--print")
        .arg(&full_prompt)
        .output()
        .context("Failed to execute claude command. Make sure Claude Code CLI is installed and accessible.")?;
    
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(anyhow::anyhow!("Claude Code CLI failed: {}", stderr));
    }
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    let analysis = stdout.trim().to_string();
    
    if analysis.is_empty() {
        return Err(anyhow::anyhow!("Claude Code CLI returned empty response"));
    }
    
    println!("Claude Code CLI analysis completed - Length: {} chars", analysis.len());
    
    Ok(analysis)
}

// Get list of tables with row counts - returns real database tables with accurate counts
async fn get_tables(data: web::Data<Arc<ApiState>>, query: web::Query<std::collections::HashMap<String, String>>) -> Result<HttpResponse> {
    // Check if a specific connection is requested
    let pool = if let Some(connection_name) = query.get("connection") {
        // Use the specified connection
        match std::env::var(connection_name) {
            Ok(database_url) => {
                match sqlx::postgres::PgPool::connect(&database_url).await {
                    Ok(pool) => pool,
                    Err(e) => {
                        return Ok(HttpResponse::InternalServerError().json(json!({
                            "error": format!("Failed to connect to {}: {}", connection_name, e)
                        })));
                    }
                }
            }
            Err(_) => {
                return Ok(HttpResponse::BadRequest().json(json!({
                    "error": format!("Connection '{}' not found in environment variables", connection_name)
                })));
            }
        }
    } else {
        // Use default connection
        data.db.clone()
    };
    
    match get_database_tables(&pool, None).await {
        Ok(tables) => {
            let mut table_info = Vec::new();
            
            // Get actual row counts for each table
            for table in tables {
                let query = format!("SELECT COUNT(*) FROM {}", table.name);
                match sqlx::query(&query).fetch_one(&pool).await {
                    Ok(row) => {
                        let count: i64 = row.get(0);
                        table_info.push(TableInfo {
                            name: table.name.clone(),
                            row_count: count,
                        });
                    }
                    Err(_) => {
                        // Table might not be accessible, use estimated count
                        table_info.push(TableInfo {
                            name: table.name.clone(),
                            row_count: table.rows.unwrap_or(0),
                        });
                    }
                }
            }
            
            Ok(HttpResponse::Ok().json(json!({ "tables": table_info })))
        }
        Err(e) => {
            Ok(HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to fetch tables: {}", e)
            })))
        }
    }
}

// Get list of mock tables - returns hardcoded placeholder data
async fn get_tables_mock() -> Result<HttpResponse> {
    let tables = vec![
        "users", "accounts", "contacts", "opportunities", "activities",
        "campaigns", "documents", "events", "roles", "projects",
        "products", "prospects", "calls", "leads", "surveyquestionoptions",
        "tags", "taggables"
    ];
    
    let table_info: Vec<TableInfo> = tables.iter().map(|table_name| {
        TableInfo {
            name: table_name.to_string(),
            row_count: 0, // Mock data shows 0 rows
        }
    }).collect();
    
    Ok(HttpResponse::Ok().json(json!({ "tables": table_info })))
}

// Test database connection
async fn db_test_connection(data: web::Data<Arc<ApiState>>) -> Result<HttpResponse> {
    match test_db_connection(&data.db).await {
        Ok(info) => Ok(HttpResponse::Ok().json(DatabaseResponse {
            success: true,
            message: Some("Database connection successful".to_string()),
            error: None,
            data: Some(serde_json::to_value(info).unwrap()),
        })),
        Err(e) => Ok(HttpResponse::InternalServerError().json(DatabaseResponse {
            success: false,
            message: None,
            error: Some(format!("Connection failed: {}", e)),
            data: None,
        })),
    }
}

// List database tables with detailed info
async fn db_list_tables(
    data: web::Data<Arc<ApiState>>,
    query: web::Query<std::collections::HashMap<String, String>>,
) -> Result<HttpResponse> {
    let limit = query.get("limit").and_then(|s| s.parse::<i32>().ok());
    match get_database_tables(&data.db, limit).await {
        Ok(tables) => Ok(HttpResponse::Ok().json(DatabaseResponse {
            success: true,
            message: Some(format!("Found {} tables", tables.len())),
            error: None,
            data: Some(serde_json::json!({ "tables": tables })),
        })),
        Err(e) => Ok(HttpResponse::InternalServerError().json(DatabaseResponse {
            success: false,
            message: None,
            error: Some(format!("Failed to list tables: {}", e)),
            data: None,
        })),
    }
}

// Get table information
async fn db_get_table_info(
    data: web::Data<Arc<ApiState>>,
    path: web::Path<String>,
) -> Result<HttpResponse> {
    let table_name = path.into_inner();
    
    match get_table_details(&data.db, &table_name).await {
        Ok(info) => Ok(HttpResponse::Ok().json(DatabaseResponse {
            success: true,
            message: Some(format!("Table {} found", table_name)),
            error: None,
            data: Some(serde_json::to_value(info).unwrap()),
        })),
        Err(e) => Ok(HttpResponse::InternalServerError().json(DatabaseResponse {
            success: false,
            message: None,
            error: Some(format!("Failed to get table info: {}", e)),
            data: None,
        })),
    }
}

// Execute custom query (use with caution!)
async fn db_execute_query(
    data: web::Data<Arc<ApiState>>,
    query_req: web::Json<QueryRequest>,
) -> Result<HttpResponse> {
    // Only allow safe SELECT queries for security
    let query = query_req.query.trim().to_lowercase();
    if !query.starts_with("select") {
        return Ok(HttpResponse::BadRequest().json(DatabaseResponse {
            success: false,
            message: None,
            error: Some("Only SELECT queries are allowed".to_string()),
            data: None,
        }));
    }

    match execute_safe_query(&data.db, &query_req.query).await {
        Ok(result) => Ok(HttpResponse::Ok().json(DatabaseResponse {
            success: true,
            message: Some("Query executed successfully".to_string()),
            error: None,
            data: Some(result),
        })),
        Err(e) => Ok(HttpResponse::InternalServerError().json(DatabaseResponse {
            success: false,
            message: None,
            error: Some(format!("Query failed: {}", e)),
            data: None,
        })),
    }
}

// Create a new project
async fn create_project(
    data: web::Data<Arc<ApiState>>,
    req: web::Json<CreateProjectRequest>,
) -> Result<HttpResponse> {
    let id = Uuid::new_v4();
    let now = Utc::now();
    
    // Parse date strings into NaiveDate
    let start_date = req.estimated_start_date.as_ref()
        .and_then(|s| if s.is_empty() { None } else { Some(s) })
        .and_then(|s| NaiveDate::parse_from_str(s, "%Y-%m-%d").ok());
    
    let end_date = req.estimated_end_date.as_ref()
        .and_then(|s| if s.is_empty() { None } else { Some(s) })
        .and_then(|s| NaiveDate::parse_from_str(s, "%Y-%m-%d").ok());
    
    let result = sqlx::query(
        r#"
        INSERT INTO projects (
            id, name, description, status, 
            estimated_start_date, estimated_end_date,
            date_entered, date_modified, created_by, modified_user_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        "#
    )
    .bind(id)
    .bind(&req.name)
    .bind(&req.description)
    .bind(&req.status)
    .bind(start_date)
    .bind(end_date)
    .bind(now)
    .bind(now)
    .bind("1") // Default user ID
    .bind("1") // Default user ID
    .execute(&data.db)
    .await;
    
    match result {
        Ok(_) => Ok(HttpResponse::Created().json(json!({
            "id": id.to_string(),
            "message": "Project created successfully"
        }))),
        Err(e) => Ok(HttpResponse::BadRequest().json(json!({
            "error": e.to_string()
        }))),
    }
}

// Initialize database schema (simplified version with core tables)
async fn init_database(pool: &Pool<Postgres>) -> anyhow::Result<()> {
    // Create users table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_name VARCHAR(60),
            first_name VARCHAR(30),
            last_name VARCHAR(30),
            email VARCHAR(100),
            status VARCHAR(100),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
        "#
    ).execute(pool).await?;
    
    // Create accounts table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS accounts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(150),
            account_type VARCHAR(50),
            industry VARCHAR(50),
            phone_office VARCHAR(100),
            website VARCHAR(255),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create contacts table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS contacts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            salutation VARCHAR(255),
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            title VARCHAR(100),
            department VARCHAR(255),
            account_id UUID REFERENCES accounts(id),
            phone_work VARCHAR(100),
            phone_mobile VARCHAR(100),
            email VARCHAR(100),
            primary_address_street VARCHAR(150),
            primary_address_city VARCHAR(100),
            primary_address_state VARCHAR(100),
            primary_address_postalcode VARCHAR(20),
            primary_address_country VARCHAR(255),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create projects table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS projects (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            description TEXT,
            status VARCHAR(50),
            priority VARCHAR(255),
            estimated_start_date DATE,
            estimated_end_date DATE,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create opportunities table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS opportunities (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            account_id UUID REFERENCES accounts(id),
            opportunity_type VARCHAR(255),
            lead_source VARCHAR(50),
            amount DECIMAL(26,6),
            currency_id VARCHAR(36),
            date_closed DATE,
            sales_stage VARCHAR(255),
            probability DECIMAL(3,0),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create activities table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS activities (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(255),
            date_due TIMESTAMP WITH TIME ZONE,
            date_start TIMESTAMP WITH TIME ZONE,
            parent_type VARCHAR(255),
            parent_id UUID,
            status VARCHAR(100),
            priority VARCHAR(255),
            description TEXT,
            contact_id UUID REFERENCES contacts(id),
            account_id UUID REFERENCES accounts(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create leads table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS leads (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            salutation VARCHAR(255),
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            title VARCHAR(100),
            company VARCHAR(100),
            phone_work VARCHAR(100),
            phone_mobile VARCHAR(100),
            email VARCHAR(100),
            status VARCHAR(100),
            lead_source VARCHAR(100),
            description TEXT,
            converted BOOLEAN DEFAULT false,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create campaigns table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS campaigns (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            campaign_type VARCHAR(100),
            status VARCHAR(100),
            start_date DATE,
            end_date DATE,
            budget DECIMAL(26,6),
            expected_cost DECIMAL(26,6),
            actual_cost DECIMAL(26,6),
            expected_revenue DECIMAL(26,6),
            objective TEXT,
            content TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create documents table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS documents (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            document_name VARCHAR(255),
            filename VARCHAR(255),
            file_ext VARCHAR(100),
            file_mime_type VARCHAR(100),
            revision VARCHAR(100),
            category_id VARCHAR(100),
            subcategory_id VARCHAR(100),
            status VARCHAR(100),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create events table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS events (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(255),
            date_start TIMESTAMP WITH TIME ZONE,
            date_end TIMESTAMP WITH TIME ZONE,
            duration_hours INTEGER,
            duration_minutes INTEGER,
            location VARCHAR(255),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create products table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS products (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            product_code VARCHAR(50),
            category VARCHAR(100),
            manufacturer VARCHAR(50),
            cost DECIMAL(26,6),
            price DECIMAL(26,6),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create roles table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS roles (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(150),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create calls table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS calls (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            date_start TIMESTAMP WITH TIME ZONE,
            date_end TIMESTAMP WITH TIME ZONE,
            duration_hours INTEGER,
            duration_minutes INTEGER,
            status VARCHAR(100),
            direction VARCHAR(100),
            parent_type VARCHAR(255),
            parent_id UUID,
            contact_id UUID REFERENCES contacts(id),
            account_id UUID REFERENCES accounts(id),
            description TEXT,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create surveyquestionoptions table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS surveyquestionoptions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(50),
            survey_question_id UUID,
            sort_order INTEGER,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by VARCHAR(36),
            modified_user_id VARCHAR(36)
        )
        "#
    ).execute(pool).await?;
    
    // Create tags table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS tags (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name VARCHAR(255),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date_modified TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
        "#
    ).execute(pool).await?;
    
    // Create taggables table (polymorphic relationship)
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS taggables (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            tag_id UUID REFERENCES tags(id),
            taggable_type VARCHAR(100),
            taggable_id UUID,
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(tag_id, taggable_type, taggable_id)
        )
        "#
    ).execute(pool).await?;
    
    // Create relationship tables
    
    // User roles relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users_roles (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id),
            role_id UUID REFERENCES roles(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, role_id)
        )
        "#
    ).execute(pool).await?;
    
    // Account contacts relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS accounts_contacts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            account_id UUID REFERENCES accounts(id),
            contact_id UUID REFERENCES contacts(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(account_id, contact_id)
        )
        "#
    ).execute(pool).await?;
    
    // Account opportunities relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS accounts_opportunities (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            account_id UUID REFERENCES accounts(id),
            opportunity_id UUID REFERENCES opportunities(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(account_id, opportunity_id)
        )
        "#
    ).execute(pool).await?;
    
    // Contact opportunities relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS contacts_opportunities (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            contact_id UUID REFERENCES contacts(id),
            opportunity_id UUID REFERENCES opportunities(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(contact_id, opportunity_id)
        )
        "#
    ).execute(pool).await?;
    
    // Campaign leads relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS campaigns_leads (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            campaign_id UUID REFERENCES campaigns(id),
            lead_id UUID REFERENCES leads(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(campaign_id, lead_id)
        )
        "#
    ).execute(pool).await?;
    
    // Project contacts relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS projects_contacts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            project_id UUID REFERENCES projects(id),
            contact_id UUID REFERENCES contacts(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(project_id, contact_id)
        )
        "#
    ).execute(pool).await?;
    
    // Project accounts relationship
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS projects_accounts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            project_id UUID REFERENCES projects(id),
            account_id UUID REFERENCES accounts(id),
            date_entered TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(project_id, account_id)
        )
        "#
    ).execute(pool).await?;
    
    println!("Database schema initialized successfully!");
    Ok(())
}

// Helper functions for database admin endpoints
async fn test_db_connection(pool: &Pool<Postgres>) -> Result<ConnectionInfo, sqlx::Error> {
    let row = sqlx::query(
        r#"
        SELECT 
            version() as server_version,
            current_database() as database_name,
            current_user as current_user,
            (SELECT count(*) FROM pg_stat_activity) as connection_count
        "#,
    )
    .fetch_one(pool)
    .await?;

    Ok(ConnectionInfo {
        server_version: row.get("server_version"),
        database_name: row.get("database_name"),
        current_user: row.get("current_user"),
        connection_count: row.get("connection_count"),
    })
}

async fn get_database_tables(pool: &Pool<Postgres>, limit: Option<i32>) -> Result<Vec<TableInfoDetailed>, sqlx::Error> {
    let query = if let Some(limit_val) = limit {
        format!(
            r#"
            SELECT 
                table_name,
                (
                    SELECT reltuples::bigint 
                    FROM pg_class 
                    WHERE relname = table_name
                ) as estimated_rows
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
                AND table_type = 'BASE TABLE'
            ORDER BY table_name
            LIMIT {}
            "#,
            limit_val
        )
    } else {
        r#"
        SELECT 
            table_name,
            (
                SELECT reltuples::bigint 
                FROM pg_class 
                WHERE relname = table_name
            ) as estimated_rows
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
        ORDER BY table_name
        "#.to_string()
    };
    
    let rows = sqlx::query(&query)
    .fetch_all(pool)
    .await?;

    let mut tables = Vec::new();
    for row in rows {
        let table_name: String = row.get("table_name");
        let estimated_rows: Option<i64> = row.get("estimated_rows");
        
        // Add description based on table name
        let description = get_table_description(&table_name);
        
        tables.push(TableInfoDetailed {
            name: table_name,
            rows: estimated_rows,
            description,
        });
    }

    Ok(tables)
}

async fn get_table_details(pool: &Pool<Postgres>, table_name: &str) -> Result<HashMap<String, serde_json::Value>, sqlx::Error> {
    // Get basic table info
    let row = sqlx::query(
        r#"
        SELECT 
            (SELECT reltuples::bigint FROM pg_class WHERE relname = $1) as estimated_rows,
            (SELECT count(*) FROM information_schema.columns WHERE table_name = $1) as column_count
        "#,
    )
    .bind(table_name)
    .fetch_one(pool)
    .await?;

    let mut info = HashMap::new();
    info.insert("table_name".to_string(), serde_json::Value::String(table_name.to_string()));
    info.insert("estimated_rows".to_string(), serde_json::json!(row.get::<Option<i64>, _>("estimated_rows")));
    info.insert("column_count".to_string(), serde_json::json!(row.get::<i64, _>("column_count")));
    info.insert("description".to_string(), serde_json::Value::String(
        get_table_description(table_name).unwrap_or_else(|| "No description available".to_string())
    ));

    Ok(info)
}

async fn execute_safe_query(pool: &Pool<Postgres>, query: &str) -> Result<serde_json::Value, sqlx::Error> {
    let rows = sqlx::query(query).fetch_all(pool).await?;
    
    let mut results = Vec::new();
    for row in rows {
        let mut row_map = serde_json::Map::new();
        
        // This is a simplified approach - in production you'd want to handle types properly
        for (i, column) in row.columns().iter().enumerate() {
            let value = match row.try_get_raw(i) {
                Ok(raw_value) => {
                    // Try to convert to string for simplicity
                    if raw_value.is_null() {
                        serde_json::Value::Null
                    } else {
                        // For demo purposes, try to get as string or show type info
                        match row.try_get::<String, _>(i) {
                            Ok(s) => serde_json::Value::String(s),
                            Err(_) => serde_json::Value::String("Non-string value".to_string()),
                        }
                    }
                }
                Err(_) => serde_json::Value::String("Error reading value".to_string()),
            };
            
            row_map.insert(column.name().to_string(), value);
        }
        
        results.push(serde_json::Value::Object(row_map));
    }

    Ok(serde_json::Value::Array(results))
}

fn get_table_description(table_name: &str) -> Option<String> {
    match table_name {
        "accounts" => Some("Customer accounts and organizations".to_string()),
        "contacts" => Some("Individual contact records".to_string()),
        "users" => Some("System users and administrators".to_string()),
        "opportunities" => Some("Sales opportunities and deals".to_string()),
        "cases" => Some("Customer support cases".to_string()),
        "leads" => Some("Sales leads and prospects".to_string()),
        "campaigns" => Some("Marketing campaigns".to_string()),
        "meetings" => Some("Scheduled meetings and appointments".to_string()),
        "calls" => Some("Phone calls and communications".to_string()),
        "tasks" => Some("Tasks and activities".to_string()),
        "projects" => Some("Project management records".to_string()),
        "project_task" => Some("Individual project tasks".to_string()),
        "documents" => Some("Document attachments and files".to_string()),
        "emails" => Some("Email communications".to_string()),
        "notes" => Some("Notes and comments".to_string()),
        "activities" => Some("Activities and tasks".to_string()),
        "surveyquestionoptions" => Some("Survey question options".to_string()),
        "tags" => Some("Tags for categorization".to_string()),
        "taggables" => Some("Polymorphic tag relationships".to_string()),
        "roles" => Some("User roles and permissions".to_string()),
        _ => None,
    }
}

// Run the API server
async fn run_api_server(config: Config) -> anyhow::Result<()> {
    println!("Attempting to connect to database: {}", &config.database_url);
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&config.database_url)
        .await
        .context("Failed to connect to database")?;
    
    println!("Database connection successful!");
    
    let state = Arc::new(ApiState {
        db: pool,
        config,
    });
    
    println!("Starting API server on {}:{}", state.config.server_host, state.config.server_port);
    
    // Capture server binding info before moving state into closure
    let server_host = state.config.server_host.clone();
    let server_port = state.config.server_port;
    
    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);
        
        App::new()
            .app_data(web::Data::new(state.clone()))
            .wrap(cors)
            .wrap(middleware::Logger::default())
            .service(
                web::scope("/api")
                    .route("/health", web::get().to(health_check))
                    .route("/tables", web::get().to(get_tables))
                    .route("/tables/mock", web::get().to(get_tables_mock))
                    .route("/projects", web::post().to(create_project))
                    .service(
                        web::scope("/db")
                            .route("/test-connection", web::get().to(db_test_connection))
                            .route("/tables", web::get().to(db_list_tables))
                            .route("/table/{table_name}", web::get().to(db_get_table_info))
                            .route("/query", web::post().to(db_execute_query))
                    )
                    .service(
                        web::scope("/import")
                            .route("/excel", web::post().to(import::import_excel_data))
                            .route("/excel/preview", web::post().to(import::preview_excel_data))
                            .route("/excel/sheets", web::post().to(import::get_excel_sheets))
                            .route("/data", web::post().to(import::import_data))
                    )
                    .service(
                        web::scope("/config")
                            .route("/env", web::get().to(get_env_config))
                            .route("/save-env", web::post().to(save_env_config))
                            .route("/gemini", web::get().to(google::test_gemini_config))
                            .route("/database/{connection_name}", web::get().to(test_database_connection))
                    )
                    .service(
                        web::scope("/gemini")
                            .route("/analyze", web::post().to(google::analyze_with_gemini))
                    )
                    .service(
                        web::scope("/claude")
                            .route("/analyze", web::post().to(analyze_with_claude_cli))
                    )
                    .service(
                        web::scope("/google")
                            .route("/meetup/participants", web::post().to(google::get_meetup_participants))
                            .route("/fetch-csv", web::post().to(fetch_csv))
                    )
            )
            // Add health check route at root level as well
            .route("/health", web::get().to(health_check))
    })
    .bind((server_host, server_port))?
    .run()
    .await?;
    
    Ok(())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::init();
    
    let cli = Cli::parse();
    let config = Config::from_env()?;
    
    match cli.command {
        Commands::Serve => {
            run_api_server(config).await?;
        }
        Commands::InitDb => {
            let pool = PgPoolOptions::new()
                .max_connections(5)
                .connect(&config.database_url)
                .await
                .context("Failed to connect to database")?;
            
            init_database(&pool).await?;
        }
    }
    
    Ok(())
}