/**
 * Shared utility functions for MemberCommons
 * Extracted from admin/import-data.html for reuse across multiple pages
 */

// =============================================================================
// CACHE MANAGEMENT FUNCTIONS
// =============================================================================

function loadCacheFromStorage() {
    try {
        const stored = localStorage.getItem('aiInsightsCache');
        const cache = stored ? JSON.parse(stored) : {};
        console.log('DEBUG: loadCacheFromStorage - loaded keys:', Object.keys(cache));
        
        // Debug: Show cache contents
        Object.keys(cache).forEach(key => {
            console.log(`DEBUG: Gemini cache key "${key}":`, {
                success: cache[key].success,
                analysisLength: cache[key].analysis?.length,
                totalRecords: cache[key].totalRecords,
                timestamp: cache[key].timestamp
            });
        });
        
        return cache;
    } catch (error) {
        console.error('Error loading cache from localStorage:', error);
        return {};
    }
}

function saveCacheToStorage(aiInsightsCache, getCurrentCacheKey) {
    try {
        const cacheKey = getCurrentCacheKey();
        console.log('DEBUG: saveCacheToStorage called for key:', cacheKey);
        console.log('DEBUG: Current aiInsightsCache contents:', Object.keys(aiInsightsCache));
        console.log('DEBUG: Current cache entry:', aiInsightsCache[cacheKey]);
        
        localStorage.setItem('aiInsightsCache', JSON.stringify(aiInsightsCache));
        console.log('Saved cache to localStorage, keys:', Object.keys(aiInsightsCache));
    } catch (error) {
        console.error('Error saving cache to localStorage:', error);
    }
}

function loadClaudeCacheFromStorage() {
    try {
        const stored = localStorage.getItem('claudeInsightsCache');
        const cache = stored ? JSON.parse(stored) : {};
        console.log('DEBUG: loadClaudeCacheFromStorage - loaded keys:', Object.keys(cache));
        
        // Debug: Show cache contents
        Object.keys(cache).forEach(key => {
            console.log(`DEBUG: Claude cache key "${key}":`, {
                success: cache[key].success,
                analysisLength: cache[key].analysis?.length,
                totalRecords: cache[key].totalRecords,
                timestamp: cache[key].timestamp
            });
        });
        
        return cache;
    } catch (error) {
        console.error('Error loading Claude cache from localStorage:', error);
        return {};
    }
}

function saveClaudeCacheToStorage(claudeInsightsCache, getCurrentCacheKey) {
    try {
        const cacheKey = getCurrentCacheKey();
        console.log('DEBUG: saveClaudeCacheToStorage called for key:', cacheKey);
        console.log('DEBUG: Current claudeInsightsCache contents:', Object.keys(claudeInsightsCache));
        console.log('DEBUG: Current cache entry:', claudeInsightsCache[cacheKey]);
        
        localStorage.setItem('claudeInsightsCache', JSON.stringify(claudeInsightsCache));
        console.log('Saved Claude cache to localStorage, keys:', Object.keys(claudeInsightsCache));
    } catch (error) {
        console.error('Error saving Claude cache to localStorage:', error);
    }
}

function getCurrentCacheKey(fileSelect, selectedFile, selectedSheet) {
    // Always use the dropdown value for consistent caching, regardless of selectedFile content
    const selectedOption = fileSelect.options[fileSelect.selectedIndex];
    let fileKey = selectedOption ? selectedOption.value : (selectedFile || 'unknown');
    
    console.log('DEBUG getCurrentCacheKey - selectedFile:', selectedFile);
    console.log('DEBUG getCurrentCacheKey - selectedOption:', selectedOption);
    console.log('DEBUG getCurrentCacheKey - selectedOption.value:', selectedOption?.value);
    console.log('DEBUG getCurrentCacheKey - data-cors:', selectedOption?.getAttribute('data-cors'));
    console.log('DEBUG: Using dropdown value for cache key:', fileKey);
    
    const sheetKey = selectedSheet || 'default';
    const cacheKey = `${fileKey}__${sheetKey}`;
    console.log('DEBUG: Generated cache key:', cacheKey, 'from file:', fileKey, 'sheet:', sheetKey);
    return cacheKey;
}

// =============================================================================
// DATA PROCESSING UTILITIES
// =============================================================================

function parseCSV(csvText) {
    const lines = csvText.split('\n').filter(line => line.trim());
    const result = [];
    
    for (let line of lines) {
        const row = [];
        let current = '';
        let inQuotes = false;
        
        for (let i = 0; i < line.length; i++) {
            const char = line[i];
            
            if (char === '"') {
                inQuotes = !inQuotes;
            } else if (char === ',' && !inQuotes) {
                row.push(current.trim());
                current = '';
            } else {
                current += char;
            }
        }
        
        row.push(current.trim());
        result.push(row);
    }
    
    return result;
}

function parseCSVToObjects(csvText) {
    const arrays = parseCSV(csvText);
    return convertArraysToObjects(arrays);
}

function parseRSS(xmlText) {
    try {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlText, "text/xml");
        
        // Check for parsing errors
        const parseError = xmlDoc.querySelector("parsererror");
        if (parseError) {
            throw new Error("XML parsing error: " + parseError.textContent);
        }
        
        // Get all item elements (RSS) or entry elements (Atom)
        const items = xmlDoc.querySelectorAll("item, entry");
        
        if (items.length === 0) {
            throw new Error("No RSS items or Atom entries found in XML");
        }
        
        // Define headers based on common RSS/Atom elements
        const headers = ['title', 'link', 'description', 'pubDate', 'guid', 'category', 'author'];
        const result = [headers]; // First row as headers
        
        items.forEach(item => {
            const row = headers.map(header => {
                let element;
                
                // Handle different element names for RSS vs Atom
                switch(header) {
                    case 'title':
                        element = item.querySelector('title');
                        break;
                    case 'link':
                        element = item.querySelector('link');
                        // For Atom feeds, link might be an attribute
                        if (!element || !element.textContent.trim()) {
                            const linkAttr = item.querySelector('link[href]');
                            return linkAttr ? linkAttr.getAttribute('href') : '';
                        }
                        break;
                    case 'description':
                        element = item.querySelector('description, summary, content');
                        break;
                    case 'pubDate':
                        element = item.querySelector('pubDate, published, updated');
                        break;
                    case 'guid':
                        element = item.querySelector('guid, id');
                        break;
                    case 'category':
                        element = item.querySelector('category');
                        break;
                    case 'author':
                        element = item.querySelector('author, creator');
                        break;
                    default:
                        element = item.querySelector(header);
                }
                
                if (element) {
                    // Strip HTML tags from content if present
                    let content = element.textContent || element.innerHTML || '';
                    content = content.replace(/<[^>]*>/g, '').trim();
                    return content;
                }
                
                return '';
            });
            
            result.push(row);
        });
        
        console.log(`Parsed ${items.length} RSS/XML items`);
        return result;
        
    } catch (error) {
        console.error('RSS parsing error:', error);
        throw new Error(`Failed to parse RSS/XML: ${error.message}`);
    }
}

function flattenObject(obj, prefix = '', maxDepth = 3, currentDepth = 0) {
    const flattened = {};
    
    if (currentDepth >= maxDepth || obj === null || obj === undefined) {
        return flattened;
    }
    
    for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
            const value = obj[key];
            const newKey = prefix ? `${prefix}_${key}` : key;
            
            if (value === null || value === undefined) {
                flattened[newKey] = null;
            } else if (Array.isArray(value)) {
                // Handle arrays by extracting useful information
                if (value.length === 0) {
                    flattened[newKey] = null;
                } else if (value.length === 1 && typeof value[0] === 'object') {
                    // If array has one object, flatten that object
                    const subFlattened = flattenObject(value[0], newKey, maxDepth, currentDepth + 1);
                    Object.assign(flattened, subFlattened);
                } else {
                    // For multiple items or primitive arrays, join them
                    flattened[newKey] = value.map(item => 
                        typeof item === 'object' ? extractObjectValues(item, 1) : String(item)
                    ).join(', ');
                }
            } else if (typeof value === 'object') {
                // Recursively flatten nested objects
                const subFlattened = flattenObject(value, newKey, maxDepth, currentDepth + 1);
                Object.assign(flattened, subFlattened);
            } else {
                // Primitive value
                flattened[newKey] = value;
            }
        }
    }
    
    return flattened;
}

function extractObjectValues(obj, maxDepth = 2, currentDepth = 0) {
    if (obj === null || obj === undefined) {
        return '';
    }
    
    if (typeof obj !== 'object') {
        return String(obj);
    }
    
    if (Array.isArray(obj)) {
        if (obj.length === 0) return '[]';
        if (obj.length === 1) return extractObjectValues(obj[0], maxDepth, currentDepth + 1);
        return `[${obj.length} items: ${obj.slice(0, 3).map(item => extractObjectValues(item, maxDepth, currentDepth + 1)).join(', ')}${obj.length > 3 ? '...' : ''}]`;
    }
    
    // Stop recursion if we've gone too deep
    if (currentDepth >= maxDepth) {
        return '{...}';
    }
    
    const keys = Object.keys(obj);
    if (keys.length === 0) return '{}';
    
    // For objects, extract key-value pairs up to a limit
    const pairs = [];
    const maxPairs = 3;
    
    for (let i = 0; i < Math.min(keys.length, maxPairs); i++) {
        const key = keys[i];
        const value = obj[key];
        const extractedValue = extractObjectValues(value, maxDepth, currentDepth + 1);
        
        // Format the key-value pair
        if (extractedValue && extractedValue !== '{}' && extractedValue !== '[]') {
            pairs.push(`${key}: ${extractedValue}`);
        }
    }
    
    if (pairs.length === 0) {
        // If no meaningful pairs found, just show the keys
        return `{${keys.slice(0, 3).join(', ')}${keys.length > 3 ? '...' : ''}}`;
    }
    
    let result = pairs.join(', ');
    if (keys.length > maxPairs) {
        result += `... (+${keys.length - maxPairs} more)`;
    }
    
    return result;
}

function isCSVFile(filePath) {
    if (typeof filePath === 'string') {
        return filePath.includes('output=csv') || filePath.endsWith('.csv');
    } else if (filePath instanceof File) {
        return filePath.name.toLowerCase().endsWith('.csv');
    }
    return false;
}

function getImportTableForFile(filePath, fileSelect) {
    if (isCSVFile(filePath)) {
        return 'accounts'; // CSV files go to accounts table
    } else {
        // Check if this is a projects data source
        const selectedOption = fileSelect.options[fileSelect.selectedIndex];
        const isProjects = selectedOption && selectedOption.getAttribute('data-projects') === 'true';
        return isProjects ? 'projects' : 'projects'; // Default to projects table
    }
}

// =============================================================================
// UI UTILITIES
// =============================================================================

function showSection(element) {
    element.classList.remove('hidden');
}

function hideSection(element) {
    element.classList.add('hidden');
}

function showLoading(button, text) {
    button.disabled = true;
    button.textContent = text;
    button.classList.add('loading');
}

function hideLoading(button, text) {
    button.disabled = false;
    button.textContent = text;
    button.classList.remove('loading');
}

function showMessage(message, type = 'info', clearPrevious = false, statusMessages = null) {
    // If statusMessages element not provided, try to find it
    if (!statusMessages) {
        statusMessages = document.getElementById('statusMessages');
        if (!statusMessages) {
            // If no status messages container, just log to console
            console.log(`[${type.toUpperCase()}] ${message}`);
            return;
        }
    }
    
    // Add timestamp to message
    const timestamp = new Date().toLocaleTimeString();
    const timestampedMessage = `[${timestamp}] ${message}`;
    
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    alertDiv.textContent = timestampedMessage;
    
    // Clear previous messages if requested
    if (clearPrevious) {
        statusMessages.innerHTML = '';
    }
    
    // Append new message to the bottom of the log
    statusMessages.appendChild(alertDiv);
    
    // Keep only the last 20 messages to prevent memory issues
    while (statusMessages.children.length > 20) {
        statusMessages.removeChild(statusMessages.firstChild);
    }
    
    // Ensure the log container is visible
    statusMessages.style.display = 'block';
    
    // Auto-scroll to the bottom to show the newest message
    statusMessages.scrollTop = statusMessages.scrollHeight;
}

function clearMessages(statusMessages = null) {
    if (!statusMessages) {
        statusMessages = document.getElementById('statusMessages');
    }
    if (statusMessages) {
        statusMessages.innerHTML = '';
    }
}

// =============================================================================
// API UTILITIES
// =============================================================================

async function fetchExternalAPI(url, options = {}, forceCorsProxy = false, API_BASE = 'http://localhost:8081/api') {
    // Check if we're on model.earth domain (allow-listed for direct access)
    const isModelEarthDomain = window.location.hostname.includes('model.earth');
    
    if (isModelEarthDomain && !forceCorsProxy) {
        // Direct fetch for model.earth domain (CORS allow-listed)
        showMessage('Using direct API access for model.earth domain...', 'info');
        const response = await fetch(url, options);
        return await response.json();
    } else if (forceCorsProxy) {
        // Skip direct fetch and go straight to proxy when CORS is known to be required
        showMessage('Using CORS proxy for external API...', 'info');
    } else {
        // For other domains, try direct fetch first and fallback to Rust backend
        try {
            showMessage('Attempting direct API access...', 'info');
            const response = await fetch(url, options);
            return await response.json();
        } catch (corsError) {
            // If CORS fails, use Rust backend to proxy the request
            console.log('CORS blocked direct access:', corsError.message);
            showMessage('Direct API access blocked by CORS. Using Rust backend proxy...', 'info');
        }
    }
    
    // Use Rust backend proxy
    try {
        // Use Rust backend to fetch the external URL
        const proxyResponse = await fetch(`${API_BASE}/proxy`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                url: url,
                method: options.method || 'GET',
                headers: options.headers || {}
            })
        });

        if (!proxyResponse.ok) {
            throw new Error(`Proxy request failed: ${proxyResponse.status} ${proxyResponse.statusText}`);
        }

        const proxyResult = await proxyResponse.json();
        
        if (proxyResult.success) {
            showMessage('Successfully fetched data via Rust backend proxy', 'success');
            
            // Check if the response might be RSS/XML
            if (typeof proxyResult.data === 'string' && 
                (proxyResult.data.includes('<rss') || proxyResult.data.includes('<feed') || 
                 proxyResult.data.includes('<?xml'))) {
                // Parse as RSS/XML instead of treating as JSON
                console.log('Detected RSS/XML content from proxy, parsing...');
                const rssData = parseRSS(proxyResult.data);
                
                // Convert RSS data to JSON-like objects for consistency
                if (rssData.length > 1) {
                    const headers = rssData[0];
                    const items = rssData.slice(1).map(row => {
                        const item = {};
                        headers.forEach((header, index) => {
                            item[header] = row[index] || '';
                        });
                        return item;
                    });
                    return items;
                }
                return [];
            }
            
            return proxyResult.data;
        } else {
            throw new Error(proxyResult.error || 'Proxy request failed');
        }
    } catch (proxyError) {
        console.error('Rust backend proxy failed:', proxyError.message);
        showMessage('Both direct access and proxy failed. Using fallback data...', 'warning');
        
        // Return mock data structure for DemocracyLab as last resort
        if (url.includes('democracylab.org')) {
            return [
                {
                    project_name: "Sample DemocracyLab Project",
                    project_description: "This is sample data. Both direct access and backend proxy failed.",
                    project_url: "https://www.democracylab.org",
                    project_location: "Various",
                    project_date_created: new Date().toISOString(),
                    project_date_modified: new Date().toISOString()
                }
            ];
        }
        throw proxyError;
    }
}

function maskApiKey(url) {
    return url.replace(/key=[^&]+/, 'key=***MASKED***');
}

// =============================================================================
// DATA FORMATTING UTILITIES
// =============================================================================

function formatBytes(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '';
    try {
        const date = new Date(timestamp);
        return date.toLocaleString();
    } catch (error) {
        return timestamp;
    }
}

// =============================================================================
// URL HASH UTILITIES
// =============================================================================

function getURLHashParam(paramName) {
    const urlParams = new URLSearchParams(window.location.hash.substring(1));
    return urlParams.get(paramName);
}

function setURLHashParam(paramName, value) {
    const urlParams = new URLSearchParams(window.location.hash.substring(1));
    if (value) {
        urlParams.set(paramName, value);
    } else {
        urlParams.delete(paramName);
    }
    
    // Update the URL without triggering a page reload
    const newHash = urlParams.toString();
    window.location.hash = newHash ? `#${newHash}` : '';
}

function updateFeedHashParam(feedValue) {
    setURLHashParam('feed', feedValue);
}

// =============================================================================
// LOCAL STORAGE UTILITIES
// =============================================================================

function savePromptToStorage(prompt, storageKey = 'membercommons_prompt') {
    if (prompt && prompt.trim()) {
        localStorage.setItem(storageKey, prompt.trim());
        console.log('Saved prompt to browser storage:', prompt.substring(0, 50) + (prompt.length > 50 ? '...' : ''));
    } else {
        // Clear storage when prompt is blank
        localStorage.removeItem(storageKey);
        console.log('Cleared prompt from browser storage (blank prompt)');
    }
}

function loadPromptFromStorage(storageKey = 'membercommons_prompt') {
    const savedPrompt = localStorage.getItem(storageKey);
    if (savedPrompt) {
        console.log('Loaded prompt from browser storage:', savedPrompt.substring(0, 50) + (savedPrompt.length > 50 ? '...' : ''));
        return savedPrompt;
    }
    return null;
}

function saveFileSelectionToStorage(fileValue, storageKey = 'membercommons_selected_file') {
    if (fileValue && fileValue !== 'custom') {
        localStorage.setItem(storageKey, fileValue);
        console.log('Saved file selection to browser storage:', fileValue);
    } else {
        // Don't store custom file selections as they won't be available on reload
        localStorage.removeItem(storageKey);
        console.log('Cleared file selection from browser storage');
    }
}

function loadFileSelectionFromStorage(storageKey = 'membercommons_selected_file') {
    const savedFileSelection = localStorage.getItem(storageKey);
    if (savedFileSelection) {
        console.log('Loaded file selection from browser storage:', savedFileSelection);
        return savedFileSelection;
    }
    return null;
}

// =============================================================================
// GOOGLE SHEET CONFIGURATION LOADING
// =============================================================================

// Load Google Sheet configuration for dynamic dropdown population
async function loadGoogleSheetConfig(fileSelect, hashParam = 'feed') {
    const SHEET_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSxfv7lxikjrmro3EJYGE_134vm5HdDszZKt4uKswHhsNJ_-afSaG9RoA4oeNV656r4mTuG3wTu38pM/pub?output=csv';
    
    try {
        console.log('Loading Google Sheet configuration...');
        const response = await fetch(SHEET_URL);
        const csvText = await response.text();
        
        // Parse CSV
        const rows = csvText.split('\n').map(row => row.split(',').map(cell => cell.replace(/"/g, '').trim()));
        const headers = rows[0];
        
        console.log('CSV headers:', headers);
        
        // Find column indices
        const titleIndex = headers.findIndex(h => h.toLowerCase() === 'title');
        const urlIndex = headers.findIndex(h => h.toLowerCase() === 'url');
        const feedIndex = headers.findIndex(h => h.toLowerCase() === 'feed');
        const corsIndex = headers.findIndex(h => h.toLowerCase() === 'cors');
        
        if (titleIndex === -1 || urlIndex === -1 || feedIndex === -1) {
            throw new Error('Required columns (Title, URL, Feed) not found in sheet');
        }
        
        console.log('Column indices - Title:', titleIndex, 'URL:', urlIndex, 'Feed:', feedIndex, 'CORS:', corsIndex);
        
        // Process data rows and add to dropdown
        const customOption = fileSelect.querySelector('option[value="custom"]');
        
        for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            if (row.length < Math.max(titleIndex, urlIndex, feedIndex) + 1) continue;
            
            const title = row[titleIndex];
            const url = row[urlIndex];
            const feed = row[feedIndex];
            const cors = corsIndex !== -1 ? row[corsIndex] : '';
            
            if (title && url && feed) {
                const option = document.createElement('option');
                option.value = feed;
                option.textContent = title;
                option.setAttribute('data-url', url);
                option.setAttribute('data-cors', cors.toLowerCase() === 'true' ? 'true' : 'false');
                
                // Add data-projects attribute for democracylab
                if (feed === 'democracylab') {
                    option.setAttribute('data-projects', 'true');
                }
                
                // Insert before the "Choose File..." option
                fileSelect.insertBefore(option, customOption);
                
                console.log(`Added option: ${title} (${feed}) - CORS: ${cors}`);
            }
        }
        
        console.log('Google Sheet configuration loaded successfully');
        return true;
        
    } catch (error) {
        console.error('Failed to load Google Sheet configuration:', error);
        showMessage('Failed to load dynamic options from Google Sheet', 'warning');
        return false;
    }
}

// Initialize file selection with Google Sheet loading and hash parameter support
async function initializeFileSelectionWithGoogleSheet(fileSelect, hashParam = 'feed', storageKey = 'fileSelection') {
    // Load Google Sheet configuration first
    await loadGoogleSheetConfig(fileSelect, hashParam);
    
    // Check for hash parameter first
    const hashParamValue = getURLHashParam(hashParam);
    let selectedOption;
    
    if (hashParamValue) {
        // Use value from URL hash parameter
        const hashOption = Array.from(fileSelect.options).find(option => option.value === hashParamValue);
        if (hashOption) {
            fileSelect.value = hashParamValue;
            selectedOption = hashOption;
            console.log(`Using ${hashParam} from URL hash parameter:`, hashParamValue);
        } else {
            // Hash parameter not found, fall back to browser storage
            const savedSelection = loadFileSelectionFromStorage(storageKey);
            if (savedSelection) {
                const savedOption = Array.from(fileSelect.options).find(option => option.value === savedSelection);
                if (savedOption) {
                    fileSelect.value = savedSelection;
                    selectedOption = savedOption;
                    console.log(`Hash ${hashParam} not found, restored from browser storage:`, savedSelection);
                } else {
                    selectedOption = fileSelect.options[fileSelect.selectedIndex];
                    console.log(`Hash ${hashParam} not found, saved selection not available, using default:`, selectedOption.value);
                }
            } else {
                selectedOption = fileSelect.options[fileSelect.selectedIndex];
                console.log(`Hash ${hashParam} not found, no saved selection, using default:`, selectedOption.value);
            }
        }
    } else {
        // No hash parameter, try to restore saved selection from browser storage
        const savedSelection = loadFileSelectionFromStorage(storageKey);
        
        if (savedSelection) {
            // Check if the saved selection is still available in the dropdown
            const savedOption = Array.from(fileSelect.options).find(option => option.value === savedSelection);
            if (savedOption) {
                fileSelect.value = savedSelection;
                selectedOption = savedOption;
                console.log('Restored file selection from browser storage:', savedSelection);
            } else {
                // Saved selection no longer available, use default
                selectedOption = fileSelect.options[fileSelect.selectedIndex];
                console.log('Saved file selection not available, using default:', selectedOption.value);
            }
        } else {
            // No saved selection, use default
            selectedOption = fileSelect.options[fileSelect.selectedIndex];
            console.log('No saved file selection, using default:', selectedOption.value);
        }
        
        // Update URL hash with the selected value
        if (hashParam === 'feed') {
            updateFeedHashParam(selectedOption.value);
        } else {
            setURLHashParam(hashParam, selectedOption.value);
        }
    }
    
    return selectedOption;
}

// =============================================================================
// UNIFIED DATA LOADING FUNCTIONS
// =============================================================================

// Function to check if a value is likely a valid column header
function isValidHeaderValue(value) {
    if (value === null || value === undefined || value === '') {
        return false;
    }
    
    const str = String(value).trim();
    if (str === '') {
        return false;
    }
    
    // Check if it's a number (not a valid header)
    if (!isNaN(parseFloat(str)) && isFinite(str)) {
        return false;
    }
    
    // Check if it looks like a date (not a valid header)
    const dateRegex = /^\d{4}-\d{2}-\d{2}|^\d{1,2}\/\d{1,2}\/\d{4}|^\d{1,2}-\d{1,2}-\d{4}/;
    if (dateRegex.test(str)) {
        return false;
    }
    
    // Check if it's too long to be a reasonable header (probably data)
    if (str.length > 100) {
        return false;
    }
    
    // Check if it contains characters that suggest it's data rather than a header
    // URLs, emails, or very long text with spaces suggesting sentences
    if (str.includes('http://') || str.includes('https://') || str.includes('@') && str.includes('.')) {
        return false;
    }
    
    // If it has more than 10 words, it's probably data, not a header
    const wordCount = str.split(/\s+/).length;
    if (wordCount > 10) {
        return false;
    }
    
    return true;
}

// Function to intelligently detect if first row should be used as headers
function shouldUseFirstRowAsHeaders(data) {
    if (!data || data.length === 0) {
        return false;
    }
    
    const firstRow = data[0];
    if (!firstRow || typeof firstRow !== 'object') {
        return false;
    }
    
    // For arrays of arrays (raw CSV data)
    if (Array.isArray(firstRow)) {
        // Check if most values in first row look like valid headers
        const validHeaderCount = firstRow.filter(value => isValidHeaderValue(value)).length;
        const totalValues = firstRow.filter(value => value !== null && value !== undefined && String(value).trim() !== '').length;
        
        // If at least 70% of non-empty values look like valid headers, use first row
        return totalValues > 0 && (validHeaderCount / totalValues) >= 0.7;
    }
    
    // For arrays of objects, headers are already the object keys
    return false;
}

// Function to convert array of arrays to array of objects using first row as headers
function convertArraysToObjects(data) {
    if (!data || data.length === 0) {
        return [];
    }
    
    // Check if we should use first row as headers
    if (!shouldUseFirstRowAsHeaders(data)) {
        // Generate generic headers: Column1, Column2, etc.
        const maxColumns = Math.max(...data.map(row => Array.isArray(row) ? row.length : 0));
        const headers = Array.from({length: maxColumns}, (_, i) => `Column${i + 1}`);
        
        return data.map(row => {
            const obj = {};
            headers.forEach((header, index) => {
                obj[header] = Array.isArray(row) ? (row[index] || '') : row;
            });
            return obj;
        });
    }
    
    // Use first row as headers
    const headers = data[0];
    const dataRows = data.slice(1);
    
    return dataRows.map(row => {
        const obj = {};
        headers.forEach((header, index) => {
            const cleanHeader = String(header || `Column${index + 1}`).trim();
            obj[cleanHeader] = Array.isArray(row) ? (row[index] || '') : row;
        });
        return obj;
    });
}

// Unified data loading function that handles JSON, RSS, CSV, and Excel formats
async function loadUnifiedData(url, options = {}) {
    const { forceCorsProxy = false, API_BASE = 'http://localhost:8081/api' } = options;
    
    try {
        console.log('Loading unified data from:', url);
        
        // Determine if this URL needs CSV parsing (Google Sheets or CSV files)
        const isCSVData = url.includes('output=csv') || url.endsWith('.csv') || url.includes('docs.google.com/spreadsheets');
        
        if (isCSVData) {
            // Handle CSV data (Google Sheets, CSV files)
            let csvText;
            
            try {
                // Try direct fetch first (works on static sites like GitHub Pages)
                console.log('Attempting direct CSV fetch...');
                const directResponse = await fetch(url, {
                    cache: 'no-cache',
                    headers: {
                        'Accept': 'text/csv'
                    }
                });
                
                if (directResponse.ok) {
                    csvText = await directResponse.text();
                    console.log('Direct CSV fetch successful');
                } else {
                    throw new Error(`Direct fetch failed: ${directResponse.status} ${directResponse.statusText}`);
                }
            } catch (directError) {
                console.log('Direct CSV fetch failed, trying backend proxy:', directError.message);
                
                // Fallback to backend proxy
                try {
                    const proxyResponse = await fetch(`${API_BASE}/google/fetch-csv`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({ url: url })
                    });
                    
                    if (proxyResponse.ok) {
                        const proxyData = await proxyResponse.json();
                        if (proxyData.success) {
                            csvText = proxyData.data;
                            console.log('Backend CSV proxy successful');
                        } else {
                            throw new Error(proxyData.error || 'Backend CSV proxy failed');
                        }
                    } else {
                        throw new Error('Backend CSV proxy not available');
                    }
                } catch (proxyError) {
                    throw new Error(`Cannot fetch CSV data. Tried both direct fetch and backend proxy.\n\nDirect error: ${directError.message}\nProxy error: ${proxyError.message}\n\nPath attempted: ${url}`);
                }
            }
            
            // Parse CSV data with intelligent header detection
            const parsedArrays = parseCSV(csvText);
            
            if (!parsedArrays || parsedArrays.length === 0) {
                throw new Error(`No data found in the spreadsheet\n\nPath attempted: ${url}`);
            }
            
            // Convert arrays to objects with intelligent header detection
            const parsedData = convertArraysToObjects(parsedArrays);
            
            if (!parsedData || parsedData.length === 0) {
                throw new Error(`No valid data rows found in the spreadsheet\n\nPath attempted: ${url}`);
            }
            
            console.log(`CSV parsed: ${parsedArrays.length} total rows, ${parsedData.length} data rows, headers detected: ${shouldUseFirstRowAsHeaders(parsedArrays) ? 'YES' : 'NO'}`);
            
            return {
                data: parsedData,
                format: 'csv',
                total_records: parsedData.length,
                source: 'csv'
            };
            
        } else {
            // Handle JSON, RSS, XML, and other formats using fetchExternalAPI
            const response = await fetchExternalAPI(url, {}, forceCorsProxy, API_BASE);
            
            // Handle different response structures
            let processedData;
            
            if (Array.isArray(response)) {
                processedData = response;
            } else if (response && response.data && Array.isArray(response.data)) {
                processedData = response.data;
            } else if (response && response.projects && Array.isArray(response.projects)) {
                processedData = response.projects;
            } else if (response && response.results && Array.isArray(response.results)) {
                processedData = response.results;
            } else if (response && Array.isArray(response.project_tiles)) {
                processedData = response.project_tiles;
            } else if (response && typeof response === 'object') {
                // Check for any array property in the response
                const keys = Object.keys(response);
                console.log('Response keys:', keys);
                
                for (const key of keys) {
                    if (Array.isArray(response[key])) {
                        console.log(`Found array at key: ${key}, length: ${response[key].length}`);
                        processedData = response[key];
                        break;
                    }
                }
            }
            
            if (!Array.isArray(processedData)) {
                console.error('Unable to find data array in response:', response);
                throw new Error(`Invalid data format received from API. Response type: ${typeof response}, keys: ${response && typeof response === 'object' ? Object.keys(response).join(', ') : 'none'}\n\nPath attempted: ${url}`);
            }
            
            // Check if this might be an array of arrays (like CSV data in JSON format)
            const isArrayOfArrays = processedData.length > 0 && Array.isArray(processedData[0]);
            
            let finalData;
            if (isArrayOfArrays) {
                // Handle as array of arrays with header detection
                console.log('Processing JSON as array of arrays...');
                finalData = convertArraysToObjects(processedData);
                console.log(`JSON array processed: ${processedData.length} total rows, ${finalData.length} data rows, headers detected: ${shouldUseFirstRowAsHeaders(processedData) ? 'YES' : 'NO'}`);
            } else {
                // Flatten nested objects in the data
                console.log('Flattening nested objects in JSON data...');
                finalData = processedData.map(item => {
                    const flattened = flattenObject(item);
                    return flattened;
                });
            }
            
            return {
                data: finalData,
                format: 'json',
                total_records: finalData.length,
                source: 'api'
            };
        }
        
    } catch (error) {
        console.error('Unified data loading error:', error);
        throw error;
    }
}

// Unified preview data formatter for consistent preview structure
function formatUnifiedPreviewData(loadResult, sourceName) {
    const { data, format, total_records } = loadResult;
    
    // Get all unique headers from data
    const allHeaders = new Set();
    data.forEach(item => {
        Object.keys(item).forEach(key => allHeaders.add(key));
    });
    const headers = Array.from(allHeaders).sort();
    
    // Create consistent preview structure
    const previewData = {
        preview: data.slice(0, 5), // Show first 5 items
        total_records: total_records,
        loaded_records: total_records,
        headers: headers,
        source: sourceName.toLowerCase().replace(/\s+/g, '_'),
        format: format
    };
    
    // Store the full dataset for later use
    const fullResult = {
        preview: previewData.preview,
        total_records: previewData.total_records,
        loaded_records: previewData.loaded_records,
        headers: previewData.headers,
        full_dataset: data,
        source: sourceName.toLowerCase().replace(/\s+/g, '_'),
        sheet_name: sourceName,
        format: format
    };
    
    return { previewData, fullResult };
}

// =============================================================================
// EXPORT FOR MODULE USAGE (if needed)
// =============================================================================

// If using as a module, export the functions
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        // Cache management
        loadCacheFromStorage,
        saveCacheToStorage,
        loadClaudeCacheFromStorage,
        saveClaudeCacheToStorage,
        getCurrentCacheKey,
        
        // Data processing
        parseCSV,
        parseCSVToObjects,
        parseRSS,
        flattenObject,
        extractObjectValues,
        isCSVFile,
        getImportTableForFile,
        
        // Header detection
        isValidHeaderValue,
        shouldUseFirstRowAsHeaders,
        convertArraysToObjects,
        
        // UI utilities
        showSection,
        hideSection,
        showLoading,
        hideLoading,
        showMessage,
        clearMessages,
        
        // API utilities
        fetchExternalAPI,
        maskApiKey,
        
        // Data formatting
        formatBytes,
        escapeHtml,
        formatTimestamp,
        
        // URL hash utilities
        getURLHashParam,
        setURLHashParam,
        updateFeedHashParam,
        
        // Local storage utilities
        savePromptToStorage,
        loadPromptFromStorage,
        saveFileSelectionToStorage,
        loadFileSelectionFromStorage,
        
        // Google Sheet configuration
        loadGoogleSheetConfig,
        initializeFileSelectionWithGoogleSheet,
        
        // Unified data loading
        loadUnifiedData,
        formatUnifiedPreviewData
    };
}