use serde::{Deserialize, Serialize};
use calamine::{open_workbook, Reader, Xlsx, DataType};
use std::collections::HashMap;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Project {
    pub id: f64,
    #[serde(rename = "Project Name")]
    pub project_name: String,
    #[serde(rename = "Project Description")]
    pub project_description: String,
    #[serde(rename = "Country")]
    pub country: String,
    #[serde(rename = "NAICS Sector")]
    pub naics_sector: String,
    #[serde(rename = "Committed")]
    pub committed: f64,
    #[serde(rename = "Department")]
    pub department: String,
    #[serde(rename = "Project Type")]
    pub project_type: String,
    #[serde(rename = "Region")]
    pub region: String,
    #[serde(rename = "Fiscal Year")]
    pub fiscal_year: String,
    #[serde(rename = "Project Number")]
    pub project_number: String,
    #[serde(rename = "Framework")]
    pub framework: String,
    #[serde(rename = "Project Profile URL")]
    pub project_profile_url: String,
    pub tags: Vec<String>,
    pub starred: bool,
    pub comment: String,
}

#[derive(Deserialize, Debug)]
pub struct RecommendationRequest {
    pub preferences: Vec<String>,
}

fn get_preference_to_filter_mappings() -> HashMap<String, serde_json::Value> {
    let mut mappings = HashMap::new();
    mappings.insert("Agriculture".to_string(), serde_json::json!({ "naicsSectors": ["Agriculture"], "departments": ["Technical Assistance"] }));
    mappings.insert("Education".to_string(), serde_json::json!({ "naicsSectors": ["Educational Services"], "departments": ["Technical Assistance"] }));
    mappings.insert("Healthcare Access".to_string(), serde_json::json!({ "naicsSectors": ["Health Care"], "departments": ["Equity Investments"] }));
    mappings.insert("Financial Inclusion".to_string(), serde_json::json!({ "naicsSectors": ["Finance and Insurance"], "departments": ["Investment Funds", "Finance"] }));
    mappings.insert("Infrastructure Development".to_string(), serde_json::json!({ "naicsSectors": ["Utilities"], "departments": ["Finance"] }));
    mappings.insert("Technology Innovation".to_string(), serde_json::json!({ "naicsSectors": ["Information"], "departments": ["Investment Funds"] }));
    mappings.insert("Small Business Support".to_string(), serde_json::json!({ "naicsSectors": ["Finance and Insurance"], "departments": ["Investment Funds"] }));
    mappings.insert("Rural Development".to_string(), serde_json::json!({ "departments": ["Technical Assistance"] }));
    mappings.insert("Environmental Sustainability".to_string(), serde_json::json!({ "naicsSectors": ["Utilities"], "departments": ["Finance"] }));
    mappings.insert("Renewable Energy".to_string(), serde_json::json!({ "naicsSectors": ["Utilities"], "departments": ["Finance"] }));
    mappings.insert("Water & Sanitation".to_string(), serde_json::json!({ "naicsSectors": ["Utilities"], "departments": ["Finance"] }));
    mappings.insert("Digital Inclusion".to_string(), serde_json::json!({ "naicsSectors": ["Information", "Educational Services"], "departments": ["Technical Assistance"] }));
    mappings.insert("Economic Growth".to_string(), serde_json::json!({ "naicsSectors": ["Finance and Insurance"], "departments": ["Investment Funds"] }));
    mappings.insert("Food Security".to_string(), serde_json::json!({ "naicsSectors": ["Agriculture"], "departments": ["Technical Assistance"] }));
    mappings
}

pub fn get_recommendations(preferences: &[String], excel_file_path: &str) -> Result<Vec<Project>, anyhow::Error> {
    let mut excel: Xlsx<_> = open_workbook(excel_file_path)?;
    let mut projects = Vec::new();

    if let Some(Ok(range)) = excel.worksheet_range_at(0) {
        let mut rows = range.rows();
        let headers = rows.next().unwrap().iter().map(|c| c.to_string()).collect::<Vec<String>>();

        for (i, row) in rows.enumerate() {
            let project_name = row.get(headers.iter().position(|h| h == "Project Name").unwrap()).and_then(|c| c.as_string()).unwrap_or_default();
            if project_name.is_empty() {
                continue;
            }
            let project = Project {
                id: (i + 1) as f64,
                project_name: project_name.to_string(),
                project_description: row.get(headers.iter().position(|h| h == "Project Description").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                country: row.get(headers.iter().position(|h| h == "Country").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                naics_sector: row.get(headers.iter().position(|h| h == "NAICS Sector").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                committed: row.get(headers.iter().position(|h| h == "Committed").unwrap()).and_then(|c| c.as_f64()).unwrap_or_default(),
                department: row.get(headers.iter().position(|h| h == "Department").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                project_type: row.get(headers.iter().position(|h| h == "Project Type").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                region: row.get(headers.iter().position(|h| h == "Region").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                fiscal_year: row.get(headers.iter().position(|h| h == "Fiscal Year").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                project_number: row.get(headers.iter().position(|h| h == "Project Number").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                framework: row.get(headers.iter().position(|h| h == "Framework").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                project_profile_url: row.get(headers.iter().position(|h| h == "Project Profile URL").unwrap()).and_then(|c| c.as_string()).unwrap_or_default().to_string(),
                tags: vec![], // Simplified for now
                starred: false,
                comment: "".to_string(),
            };
            projects.push(project);
        }
    }

    let mappings = get_preference_to_filter_mappings();
    let mut recommended_projects = Vec::new();

    for project in projects {
        for preference in preferences {
            if let Some(mapping) = mappings.get(preference) {
                let naics_sectors = mapping.get("naicsSectors").and_then(|v| v.as_array()).map(|a| a.iter().map(|s| s.as_str().unwrap().to_string()).collect::<Vec<String>>()).unwrap_or_default();
                let departments = mapping.get("departments").and_then(|v| v.as_array()).map(|a| a.iter().map(|s| s.as_str().unwrap().to_string()).collect::<Vec<String>>()).unwrap_or_default();

                if (!naics_sectors.is_empty() && naics_sectors.contains(&project.naics_sector)) ||
                   (!departments.is_empty() && departments.contains(&project.department)) {
                    recommended_projects.push(project.clone());
                    break; // Avoid duplicate projects
                }
            }
        }
    }

    Ok(recommended_projects)
}