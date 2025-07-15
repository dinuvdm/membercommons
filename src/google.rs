// src/google.rs

use actix_web::{web, HttpResponse, Result};
use serde::{Deserialize, Serialize};
use serde_json::json;
use crate::ApiState;
// use google_sheets4::{Sheets, api::ValueRange};
// use google_apis_common::auth::{ServiceAccountAuthenticator, ServiceAccountKey};
use anyhow::Context;

#[derive(Deserialize)]
pub struct MeetupRequest {
    #[allow(dead_code)]
    meetup_link: String,
}

// Get participant list from Google Meetup
pub async fn get_meetup_participants(
    _data: web::Data<std::sync::Arc<ApiState>>,
    _req: web::Json<MeetupRequest>,
) -> Result<HttpResponse> {
    // TODO: Re-enable when Google Sheets dependencies are properly configured
    Ok(HttpResponse::Ok().json(json!({
        "success": false,
        "error": "Google Sheets integration not yet configured"
    })))
}

#[derive(Debug, Serialize)]
pub struct GeminiTestResponse {
    success: bool,
    message: String,
    api_key_present: bool,
    api_key_preview: Option<String>,
    error: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct GeminiAnalysisRequest {
    pub prompt: String,
    #[allow(dead_code)]
    pub data_context: Option<serde_json::Value>,
}

#[derive(Debug, Serialize)]
pub struct GeminiAnalysisResponse {
    success: bool,
    analysis: Option<String>,
    error: Option<String>,
    error_details: Option<GeminiErrorDetails>,
    token_usage: Option<TokenUsage>,
}

#[derive(Debug, Serialize)]
pub struct TokenUsage {
    prompt_tokens: Option<u32>,
    completion_tokens: Option<u32>,
    total_tokens: Option<u32>,
}

#[derive(Debug, Serialize, Clone)]
pub struct GeminiErrorDetails {
    status_code: u16,
    error_type: String,
    raw_response: Option<String>,
    request_size: usize,
    timestamp: String,
    api_endpoint: String,
}

impl std::fmt::Display for GeminiErrorDetails {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Gemini API {} ({}): {}", 
               self.error_type, 
               self.status_code,
               self.raw_response.as_deref().unwrap_or("No details"))
    }
}

impl std::error::Error for GeminiErrorDetails {}

// Test Gemini API configuration
pub async fn test_gemini_config(data: web::Data<std::sync::Arc<ApiState>>) -> Result<HttpResponse> {
    let api_key_present = !data.config.gemini_api_key.is_empty() 
        && data.config.gemini_api_key != "dummy_key"
        && data.config.gemini_api_key != "get-key-at-aistudio.google.com";
    
    let api_key_preview = if api_key_present {
        let key = &data.config.gemini_api_key;
        if key.len() > 8 {
            Some(format!("{}...{}", &key[..4], &key[key.len()-4..]))
        } else {
            Some("***".to_string())
        }
    } else {
        None
    };
    
    let (success, message, error) = if api_key_present {
        // Test the API key by making a simple request
        match test_gemini_api_key(&data.config.gemini_api_key).await {
            Ok(()) => (true, "Gemini API key is valid and working".to_string(), None),
            Err(e) => (false, "Gemini API key present but test failed".to_string(), Some(e.to_string())),
        }
    } else {
        (false, "Gemini API key not configured or is dummy value".to_string(), None)
    };
    
    Ok(HttpResponse::Ok().json(GeminiTestResponse {
        success,
        message,
        api_key_present,
        api_key_preview,
        error,
    }))
}

// Simple function to test Gemini API key
async fn test_gemini_api_key(api_key: &str) -> anyhow::Result<()> {
    let client = reqwest::Client::new();
    let url = format!("https://generativelanguage.googleapis.com/v1/models?key={}", api_key);
    
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(10))
        .send()
        .await
        .context("Failed to make request to Gemini API")?;
    
    if response.status().is_success() {
        Ok(())
    } else {
        Err(anyhow::anyhow!("Gemini API returned error: {}", response.status()))
    }
}

// Analyze data with Gemini AI
pub async fn analyze_with_gemini(
    data: web::Data<std::sync::Arc<ApiState>>,
    req: web::Json<GeminiAnalysisRequest>,
) -> Result<HttpResponse> {
    let api_key_present = !data.config.gemini_api_key.is_empty() 
        && data.config.gemini_api_key != "dummy_key"
        && data.config.gemini_api_key != "get-key-at-aistudio.google.com";
    
    if !api_key_present {
        return Ok(HttpResponse::BadRequest().json(GeminiAnalysisResponse {
            success: false,
            analysis: None,
            error: Some("Gemini API key not configured".to_string()),
            error_details: None,
            token_usage: None,
        }));
    }

    match call_gemini_api(&data.config.gemini_api_key, &req.prompt).await {
        Ok((analysis, token_usage)) => Ok(HttpResponse::Ok().json(GeminiAnalysisResponse {
            success: true,
            analysis: Some(analysis),
            error: None,
            error_details: None,
            token_usage,
        })),
        Err(e) => {
            // Log detailed error for debugging
            eprintln!("Gemini API Error: {:?}", e);
            
            // Extract GeminiErrorDetails if available
            let error_details = e.chain()
                .find_map(|err| err.downcast_ref::<GeminiErrorDetails>())
                .cloned();

            Ok(HttpResponse::InternalServerError().json(GeminiAnalysisResponse {
                success: false,
                analysis: None,
                error: Some(e.to_string()),
                error_details,
                token_usage: None,
            }))
        }
    }
}

// Call Gemini API for text generation
async fn call_gemini_api(api_key: &str, prompt: &str) -> anyhow::Result<(String, Option<TokenUsage>)> {
    let client = reqwest::Client::new();
    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key={}",
        api_key
    );
    
    let request_body = json!({
        "contents": [{
            "parts": [{
                "text": prompt
            }]
        }],
        "generationConfig": {
            "temperature": 0.3,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 8192,
        }
    });

    let request_size = serde_json::to_string(&request_body)
        .map(|s| s.len())
        .unwrap_or(0);
    
    let start_time = std::time::Instant::now();
    
    println!("Making Gemini API request - Size: {} bytes, URL: {}", request_size, url);
    
    let response = client
        .post(&url)
        .header("Content-Type", "application/json")
        .json(&request_body)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await
        .context("Failed to make request to Gemini API")?;
    
    let duration = start_time.elapsed();
    let status = response.status();
    let status_code = status.as_u16();
    
    println!("Gemini API response - Status: {}, Duration: {:?}", status, duration);
    
    if !status.is_success() {
        let error_text = response.text().await.unwrap_or_else(|_| "Unable to read error response".to_string());
        
        let error_details = GeminiErrorDetails {
            status_code,
            error_type: match status_code {
                400 => "Bad Request".to_string(),
                401 => "Unauthorized".to_string(),
                403 => "Forbidden".to_string(),
                429 => "Rate Limited".to_string(),
                500 => "Internal Server Error".to_string(),
                502 => "Bad Gateway".to_string(),
                503 => "Service Unavailable".to_string(),
                504 => "Gateway Timeout".to_string(),
                _ => "Unknown Error".to_string(),
            },
            raw_response: Some(error_text.clone()),
            request_size,
            timestamp: chrono::Utc::now().to_rfc3339(),
            api_endpoint: url.clone(),
        };
        
        println!("Gemini API Error Details: {:?}", error_details);
        
        return Err(anyhow::Error::new(error_details)
            .context(format!("Gemini API error {}: {}", status, error_text)));
    }
    
    let response_json: serde_json::Value = response.json().await
        .context("Failed to parse Gemini API response")?;
    
    println!("Gemini API response parsed successfully");
    
    // Extract the generated text from the response
    let text = response_json
        .get("candidates")
        .and_then(|candidates| candidates.get(0))
        .and_then(|candidate| candidate.get("content"))
        .and_then(|content| content.get("parts"))
        .and_then(|parts| parts.get(0))
        .and_then(|part| part.get("text"))
        .and_then(|text| text.as_str())
        .ok_or_else(|| anyhow::anyhow!("Invalid Gemini API response format. Response: {}", 
            serde_json::to_string_pretty(&response_json).unwrap_or_else(|_| "Unable to serialize response".to_string())))?;
    
    println!("Gemini API text extracted successfully - Length: {} chars", text.len());
    
    // Extract token usage information
    let token_usage = response_json
        .get("usageMetadata")
        .and_then(|usage| {
            let prompt_tokens = usage.get("promptTokenCount").and_then(|v| v.as_u64()).map(|v| v as u32);
            let completion_tokens = usage.get("candidatesTokenCount").and_then(|v| v.as_u64()).map(|v| v as u32);
            let total_tokens = usage.get("totalTokenCount").and_then(|v| v.as_u64()).map(|v| v as u32);
            
            Some(TokenUsage {
                prompt_tokens,
                completion_tokens,
                total_tokens,
            })
        });
    
    if let Some(ref usage) = token_usage {
        println!("Token usage - Prompt: {:?}, Completion: {:?}, Total: {:?}", 
                 usage.prompt_tokens, usage.completion_tokens, usage.total_tokens);
    }
    
    Ok((text.to_string(), token_usage))
}