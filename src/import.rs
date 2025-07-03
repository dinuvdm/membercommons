// src/import.rs
use calamine::{Reader, Xlsx, open_workbook, Data};
use serde::{Deserialize, Serialize};
use sqlx::{Pool, Postgres};
use std::collections::HashMap;
use actix_web::{web, HttpResponse, Result};
use uuid::Uuid;
use chrono::Utc;

#[derive(Debug, Serialize, Deserialize)]
pub struct ImportRequest {
    pub file_path: String,
    pub sheet_name: Option<String>,
    pub table_name: String,
    pub column_mappings: Option<HashMap<String, String>>,
}

#[derive(Debug, Serialize)]
pub struct ImportResponse {
    pub success: bool,
    pub message: String,
    pub records_processed: Option<usize>,
    pub records_inserted: Option<usize>,
    pub errors: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ProjectRecord {
    pub fiscal_year: Option<String>,
    pub project_number: Option<String>,
    pub project_type: Option<String>,
    pub region: Option<String>,
    pub country: Option<String>,
    pub department: Option<String>,
    pub framework: Option<String>,
    pub project_name: Option<String>,
    pub committed: Option<f64>,
    pub naics_sector: Option<String>,
    pub project_description: Option<String>,
    pub project_profile_url: Option<String>,
}

/// Import Excel data into the projects table
pub async fn import_excel_data(
    pool: web::Data<std::sync::Arc<crate::ApiState>>,
    req: web::Json<ImportRequest>,
) -> Result<HttpResponse> {
    let mut errors = Vec::new();
    
    // Read Excel file
    let records = match read_excel_file(&req.file_path, req.sheet_name.as_deref()) {
        Ok(data) => data,
        Err(e) => {
            return Ok(HttpResponse::BadRequest().json(ImportResponse {
                success: false,
                message: format!("Failed to read Excel file: {}", e),
                records_processed: None,
                records_inserted: None,
                errors: vec![e.to_string()],
            }));
        }
    };

    // Process and insert records
    let mut inserted_count = 0;
    let total_records = records.len();

    for (index, record) in records.iter().enumerate() {
        match insert_project_record(&pool.db, record).await {
            Ok(_) => inserted_count += 1,
            Err(e) => {
                errors.push(format!("Row {}: {}", index + 1, e));
            }
        }
    }

    Ok(HttpResponse::Ok().json(ImportResponse {
        success: errors.is_empty() || inserted_count > 0,
        message: if errors.is_empty() {
            format!("Successfully imported {} records", inserted_count)
        } else {
            format!("Imported {} of {} records with {} errors", inserted_count, total_records, errors.len())
        },
        records_processed: Some(total_records),
        records_inserted: Some(inserted_count),
        errors,
    }))
}

/// Preview Excel data without importing
pub async fn preview_excel_data(
    req: web::Json<ImportRequest>,
) -> Result<HttpResponse> {
    let records = match read_excel_file(&req.file_path, req.sheet_name.as_deref()) {
        Ok(data) => data,
        Err(e) => {
            return Ok(HttpResponse::BadRequest().json(ImportResponse {
                success: false,
                message: format!("Failed to read Excel file: {}", e),
                records_processed: None,
                records_inserted: None,
                errors: vec![e.to_string()],
            }));
        }
    };

    // Return first 10 records for preview
    let preview_records: Vec<&ProjectRecord> = records.iter().take(10).collect();
    
    Ok(HttpResponse::Ok().json(serde_json::json!({
        "success": true,
        "message": format!("Preview of {} records (showing first 10)", records.len()),
        "total_records": records.len(),
        "preview": preview_records
    })))
}

/// Get Excel file sheets
pub async fn get_excel_sheets(
    req: web::Json<serde_json::Value>,
) -> Result<HttpResponse> {
    let file_path = match req.get("file_path").and_then(|v| v.as_str()) {
        Some(path) => path,
        None => {
            return Ok(HttpResponse::BadRequest().json(serde_json::json!({
                "success": false,
                "message": "file_path is required"
            })));
        }
    };

    match get_excel_sheet_names(file_path) {
        Ok(sheets) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "success": true,
            "sheets": sheets
        }))),
        Err(e) => Ok(HttpResponse::BadRequest().json(serde_json::json!({
            "success": false,
            "message": format!("Failed to read Excel file: {}", e)
        })))
    }
}

fn read_excel_file(file_path: &str, sheet_name: Option<&str>) -> Result<Vec<ProjectRecord>, Box<dyn std::error::Error>> {
    let mut workbook: Xlsx<_> = open_workbook(file_path)?;
    
    let sheet_name = match sheet_name {
        Some(name) => name.to_string(),
        None => workbook.sheet_names().get(0).unwrap_or(&"Sheet1".to_string()).clone(),
    };

    let range = workbook.worksheet_range(&sheet_name)
        .map_err(|e| format!("Error reading sheet: {}", e))?;

    let mut records = Vec::new();
    let mut headers = HashMap::new();
    
    // Get headers from first row
    if let Some(first_row) = range.rows().next() {
        for (col_idx, cell) in first_row.iter().enumerate() {
            let header = cell.to_string().to_lowercase().trim().to_string();
            headers.insert(col_idx, header);
        }
    }

    // Process data rows (skip header row)
    for row in range.rows().skip(1) {
        let mut record = ProjectRecord {
            fiscal_year: None,
            project_number: None,
            project_type: None,
            region: None,
            country: None,
            department: None,
            framework: None,
            project_name: None,
            committed: None,
            naics_sector: None,
            project_description: None,
            project_profile_url: None,
        };

        for (col_idx, cell) in row.iter().enumerate() {
            if let Some(header) = headers.get(&col_idx) {
                let value = match cell {
                    Data::Empty => None,
                    Data::String(s) => if s.trim().is_empty() { None } else { Some(s.trim().to_string()) },
                    Data::Float(f) => Some(f.to_string()),
                    Data::Int(i) => Some(i.to_string()),
                    Data::Bool(b) => Some(b.to_string()),
                    _ => Some(cell.to_string()),
                };

                match header.as_str() {
                    "fiscal year" => record.fiscal_year = value,
                    "project number" => record.project_number = value,
                    "project type" => record.project_type = value,
                    "region" => record.region = value,
                    "country" => record.country = value,
                    "department" => record.department = value,
                    "framework" => record.framework = value,
                    "project name" => record.project_name = value,
                    "committed" => {
                        record.committed = value.and_then(|v| v.parse::<f64>().ok());
                    }
                    "naics sector" => record.naics_sector = value,
                    "project description" => record.project_description = value,
                    "project profile url" => record.project_profile_url = value,
                    _ => {} // Ignore unknown columns
                }
            }
        }

        // Only include records with at least a project name
        if record.project_name.is_some() {
            records.push(record);
        }
    }

    Ok(records)
}

fn get_excel_sheet_names(file_path: &str) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let workbook: Xlsx<_> = open_workbook(file_path)?;
    Ok(workbook.sheet_names().clone())
}

async fn insert_project_record(
    pool: &Pool<Postgres>,
    record: &ProjectRecord,
) -> Result<(), sqlx::Error> {
    let id = Uuid::new_v4();
    let now = Utc::now();
    
    // Create a description combining multiple fields
    let mut description_parts = Vec::new();
    
    if let Some(desc) = &record.project_description {
        description_parts.push(desc.clone());
    }
    
    if let Some(dept) = &record.department {
        description_parts.push(format!("Department: {}", dept));
    }
    
    if let Some(region) = &record.region {
        description_parts.push(format!("Region: {}", region));
    }
    
    if let Some(country) = &record.country {
        description_parts.push(format!("Country: {}", country));
    }
    
    if let Some(framework) = &record.framework {
        description_parts.push(format!("Framework: {}", framework));
    }
    
    if let Some(naics) = &record.naics_sector {
        description_parts.push(format!("NAICS Sector: {}", naics));
    }
    
    if let Some(url) = &record.project_profile_url {
        description_parts.push(format!("Profile URL: {}", url));
    }
    
    let description = if description_parts.is_empty() {
        None
    } else {
        Some(description_parts.join("\n\n"))
    };

    // Set priority based on committed amount
    let priority = match record.committed {
        Some(amount) if amount >= 10_000_000.0 => Some("High".to_string()),
        Some(amount) if amount >= 1_000_000.0 => Some("Medium".to_string()),
        Some(_) => Some("Low".to_string()),
        None => None,
    };

    // Set status based on project type
    let status = match &record.project_type {
        Some(pt) if pt.to_lowercase().contains("active") => Some("Active".to_string()),
        Some(pt) if pt.to_lowercase().contains("planned") => Some("Planning".to_string()),
        Some(pt) if pt.to_lowercase().contains("completed") => Some("Completed".to_string()),
        _ => Some("Active".to_string()), // Default status
    };

    sqlx::query(
        r#"
        INSERT INTO projects (
            id, name, description, status, priority,
            date_entered, date_modified, created_by, modified_user_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        "#
    )
    .bind(id)
    .bind(&record.project_name)
    .bind(&description)
    .bind(&status)
    .bind(&priority)
    .bind(now)
    .bind(now)
    .bind("excel-import") // Creator identifier
    .bind("excel-import") // Modifier identifier
    .execute(pool)
    .await?;

    Ok(())
}