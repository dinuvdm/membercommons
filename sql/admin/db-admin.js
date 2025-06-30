// Database Admin Panel JavaScript
class DatabaseAdmin {
    constructor() {
        // Use config from settings.js if available, otherwise fallback
        this.apiBaseUrl = (typeof CONFIG !== 'undefined' && CONFIG.API) 
            ? CONFIG.API.BASE_URL 
            : 'http://localhost:8081/api';
        this.log = [];
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.displayConfig();
        this.addLog('Database Admin Panel initialized');
    }

    setupEventListeners() {
        // Only add event listeners if elements exist (allows reuse on different pages)
        const testConnectionBtn = document.getElementById('test-connection');
        if (testConnectionBtn) {
            testConnectionBtn.addEventListener('click', () => this.testConnection());
        }

        const listTablesBtn = document.getElementById('list-tables');
        if (listTablesBtn) {
            listTablesBtn.addEventListener('click', () => this.listTables());
        }

        const clearLogBtn = document.getElementById('clear-log');
        if (clearLogBtn) {
            clearLogBtn.addEventListener('click', () => this.clearLog());
        }

        const checkUsersBtn = document.getElementById('check-users');
        if (checkUsersBtn) {
            checkUsersBtn.addEventListener('click', () => this.checkTable('users'));
        }

        const checkAccountsBtn = document.getElementById('check-accounts');
        if (checkAccountsBtn) {
            checkAccountsBtn.addEventListener('click', () => this.checkTable('accounts'));
        }

        const testQueryBtn = document.getElementById('test-query');
        if (testQueryBtn) {
            testQueryBtn.addEventListener('click', () => this.testSimpleQuery());
        }
    }

    displayConfig() {
        const configDisplay = document.getElementById('config-display');
        if (!configDisplay) {
            // Element doesn't exist on this page, skip config display
            return;
        }
        
        if (typeof CONFIG !== 'undefined' && CONFIG.DATABASE) {
            const config = CONFIG.DATABASE;
            configDisplay.innerHTML = `<div class="config-item"><strong>Server:</strong> ${config.SERVER}</div><div class="config-item"><strong>Database:</strong> ${config.DATABASE}</div><div class="config-item"><strong>Username:</strong> ${config.USERNAME}</div><div class="config-item"><strong>Port:</strong> ${config.PORT}</div><div class="config-item"><strong>SSL:</strong> ${config.SSL ? 'Enabled' : 'Disabled'}</div><div class="config-item"><strong>Connection:</strong> ${config.CONNECTION_INFO}</div><div class="config-item"><strong>API Endpoint:</strong> ${this.apiBaseUrl}</div>`;
        } else {
            configDisplay.innerHTML = `<div class="config-error"><strong>⚠️ Configuration not loaded</strong><br>Make sure settings.js is properly included and accessible.<br><br><strong>Fallback API URL:</strong> ${this.apiBaseUrl}</div>`;
        }
    }

    async testConnection() {
        this.setLoading('test-connection', true);
        this.updateConnectionStatus('loading');
        this.addLog('Testing database connection...');
        
        try {
            // Try to create a test endpoint for database connection
            const response = await this.makeRequest('/db/test-connection', {
                method: 'GET'
            });

            if (response.success) {
                this.updateConnectionStatus('connected');
                this.showSuccess('Database connection successful!', 'connection-result');
                this.addLog(`✅ Connection successful: ${response.message}`);
                if (response.server_info) {
                    this.addLog(`📊 Server info: ${JSON.stringify(response.server_info, null, 2)}`);
                }
            } else {
                throw new Error(response.error || 'Connection failed');
            }
        } catch (error) {
            this.updateConnectionStatus('error');
            this.showError(`Connection failed: ${error.message}`, 'connection-result');
            this.addLog(`❌ Connection failed: ${error.message}`);
            
            // Try direct database connection test
            await this.tryDirectConnection();
        } finally {
            this.setLoading('test-connection', false);
        }
    }

    async tryDirectConnection() {
        this.addLog('🔄 Attempting direct database connection test...');
        
        try {
            // Since we can't directly connect to PostgreSQL from browser,
            // we'll try to make a request to our Rust backend
            const testData = {
                server: CONFIG.DATABASE.SERVER,
                database: CONFIG.DATABASE.DATABASE,
                username: CONFIG.DATABASE.USERNAME,
                port: CONFIG.DATABASE.PORT,
                ssl: CONFIG.DATABASE.SSL
            };

            this.addLog(`📡 Testing connection with parameters: ${JSON.stringify(testData, null, 2)}`);
            
            // Try alternative endpoints
            const endpoints = ['/health', '/api/health', '/db/status', '/api/db/status'];
            
            for (const endpoint of endpoints) {
                try {
                    this.addLog(`🔍 Trying endpoint: ${endpoint}`);
                    const response = await fetch(`${this.apiBaseUrl.replace('/api', '')}${endpoint}`);
                    
                    if (response.ok) {
                        const data = await response.json();
                        this.addLog(`✅ Endpoint ${endpoint} responded: ${JSON.stringify(data)}`);
                        return;
                    } else {
                        this.addLog(`⚠️ Endpoint ${endpoint} returned ${response.status}: ${response.statusText}`);
                    }
                } catch (err) {
                    this.addLog(`❌ Endpoint ${endpoint} failed: ${err.message}`);
                }
            }
            
            throw new Error('All backend endpoints failed. Make sure the Rust server is running on port 8081.');
            
        } catch (error) {
            this.addLog(`❌ Direct connection test failed: ${error.message}`);
            this.showConnectionHelp();
        }
    }

    showConnectionHelp() {
        const helpMessage = `
<div style="margin-top: 16px; padding: 16px; background: var(--bg-tertiary); border-radius: var(--radius-md);">
    <h4>Connection Troubleshooting:</h4>
    <ol style="margin: 8px 0 0 20px; color: var(--text-secondary);">
        <li>Make sure the Rust backend server is running: <code>cargo run -- serve</code></li>
        <li>Verify the server is listening on port 8081</li>
        <li>Check that your Azure PostgreSQL credentials are correct</li>
        <li>Ensure your IP is allowed in Azure PostgreSQL firewall rules</li>
        <li>Verify SSL certificate settings for Azure connection</li>
    </ol>
</div>`;
        
        document.getElementById('connection-result').innerHTML += helpMessage;
    }

    async listTables() {
        this.setLoading('list-tables', true);
        this.addLog('Fetching database tables...');
        
        try {
            const response = await this.makeRequest('/db/tables', {
                method: 'GET'
            });

            if (response.success && response.tables) {
                this.displayTables(response.tables);
                this.addLog(`✅ Found ${response.tables.length} tables`);
            } else {
                throw new Error(response.error || 'Failed to fetch tables');
            }
        } catch (error) {
            this.showError(`Failed to list tables: ${error.message}`, 'tables-result');
            this.addLog(`❌ Table listing failed: ${error.message}`);
            
            // Show mock data for demonstration
            this.showMockTables();
        } finally {
            this.setLoading('list-tables', false);
        }
    }

    showMockTables() {
        this.addLog('📋 Showing expected SuiteCRM tables based on schema...');
        
        const mockTables = [
            { name: 'accounts', rows: '~1,250', description: 'Customer accounts and organizations' },
            { name: 'contacts', rows: '~3,400', description: 'Individual contact records' },
            { name: 'users', rows: '~45', description: 'System users and administrators' },
            { name: 'opportunities', rows: '~890', description: 'Sales opportunities and deals' },
            { name: 'cases', rows: '~567', description: 'Customer support cases' },
            { name: 'leads', rows: '~234', description: 'Sales leads and prospects' },
            { name: 'campaigns', rows: '~67', description: 'Marketing campaigns' },
            { name: 'meetings', rows: '~1,123', description: 'Scheduled meetings and appointments' },
            { name: 'calls', rows: '~2,456', description: 'Phone calls and communications' },
            { name: 'tasks', rows: '~3,567', description: 'Tasks and activities' }
        ];

        this.displayTables(mockTables);
        
        document.getElementById('tables-result').innerHTML = `
            <div class="error-message">
                Note: These are expected tables based on the SuiteCRM schema. 
                Actual counts will be available when database connection is established.
            </div>
        `;
    }

    displayTables(tables) {
        const tablesList = document.getElementById('tables-list');
        const first10Tables = tables.slice(0, 10);
        
        tablesList.innerHTML = first10Tables.map(table => `
            <div class="table-item">
                <div class="table-name">${table.name}</div>
                <div class="table-info">
                    ${table.rows ? `Rows: ${table.rows}` : 'Rows: Unknown'}
                    ${table.description ? `<br>${table.description}` : ''}
                </div>
            </div>
        `).join('');

        this.showSuccess(`Displaying first ${first10Tables.length} tables`, 'tables-result');
    }

    async checkTable(tableName) {
        this.addLog(`🔍 Checking table: ${tableName}`);
        
        try {
            const response = await this.makeRequest(`/db/table/${tableName}`, {
                method: 'GET'
            });

            if (response.success) {
                this.showSuccess(`Table ${tableName}: ${response.info}`, 'quick-actions-result');
                this.addLog(`✅ Table ${tableName} check successful`);
            } else {
                throw new Error(response.error || 'Table check failed');
            }
        } catch (error) {
            this.showError(`Table ${tableName} check failed: ${error.message}`, 'quick-actions-result');
            this.addLog(`❌ Table ${tableName} check failed: ${error.message}`);
        }
    }

    async testSimpleQuery() {
        this.addLog('🔍 Testing simple database query...');
        
        try {
            const response = await this.makeRequest('/db/query', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    query: 'SELECT version() as db_version, current_database() as db_name, current_user as db_user;'
                })
            });

            if (response.success && response.result) {
                this.showSuccess(`Query executed successfully: ${JSON.stringify(response.result)}`, 'quick-actions-result');
                this.addLog(`✅ Query result: ${JSON.stringify(response.result, null, 2)}`);
            } else {
                throw new Error(response.error || 'Query execution failed');
            }
        } catch (error) {
            this.showError(`Query failed: ${error.message}`, 'quick-actions-result');
            this.addLog(`❌ Query failed: ${error.message}`);
        }
    }

    async makeRequest(endpoint, options = {}) {
        const url = `${this.apiBaseUrl}${endpoint}`;
        this.addLog(`📡 Making request to: ${url}`);
        
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            ...options
        };

        try {
            const response = await fetch(url, defaultOptions);
            
            this.addLog(`📥 Response status: ${response.status} ${response.statusText}`);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            this.addLog(`📄 Response data: ${JSON.stringify(data, null, 2)}`);
            
            return data;
        } catch (error) {
            this.addLog(`❌ Request failed: ${error.message}`);
            throw error;
        }
    }

    updateConnectionStatus(status) {
        const indicator = document.getElementById('connection-status');
        if (indicator) {
            indicator.className = `status-indicator ${status}`;
        }
    }

    setLoading(buttonId, isLoading) {
        const button = document.getElementById(buttonId);
        const spinner = document.getElementById(`${buttonId.includes('connection') ? 'connection' : 'tables'}-spinner`);
        
        if (button) {
            if (isLoading) {
                button.disabled = true;
                if (spinner) spinner.style.display = 'inline-block';
            } else {
                button.disabled = false;
                if (spinner) spinner.style.display = 'none';
            }
        }
    }

    showError(message, containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = `<div class="error-message">${message}</div>`;
        }
    }

    showSuccess(message, containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = `<div class="success-message">${message}</div>`;
        }
    }

    addLog(message) {
        const timestamp = new Date().toLocaleTimeString();
        const logEntry = `[${timestamp}] ${message}`;
        this.log.push(logEntry);
        
        const logOutput = document.getElementById('log-output');
        if (logOutput) {
            logOutput.style.display = 'block';
            logOutput.textContent = this.log.join('\n');
            logOutput.scrollTop = logOutput.scrollHeight;
        }
    }

    clearLog() {
        this.log = [];
        const logOutput = document.getElementById('log-output');
        if (logOutput) {
            logOutput.textContent = '';
            logOutput.style.display = 'none';
        }
        
        // Clear result containers (only if they exist)
        const connectionResult = document.getElementById('connection-result');
        if (connectionResult) connectionResult.innerHTML = '';
        
        const tablesResult = document.getElementById('tables-result');
        if (tablesResult) tablesResult.innerHTML = '';
        
        const quickActionsResult = document.getElementById('quick-actions-result');
        if (quickActionsResult) quickActionsResult.innerHTML = '';
        
        const tablesList = document.getElementById('tables-list');
        if (tablesList) tablesList.innerHTML = '';
        
        this.updateConnectionStatus('');
        this.addLog('Log cleared - ready for new tests');
    }

    // Enhanced displayFile function - improved version of your original
    async displayFile(pagePath, divID, target, callback, enableLogging = true) {
        // Wait for initialization if needed
        if (!this.log) {
            setTimeout(() => this.displayFile(pagePath, divID, target, callback, enableLogging), 100);
            return;
        }
        
        if (enableLogging) {
            this.addLog(`📄 Loading file: ${pagePath}`);
        }
        
        try {
            // Load dependencies with better management
            await this.loadDependencies(enableLogging);
            
            // Process the file path and folder structure
            const pathInfo = this.processFilePath(pagePath);
            
            // Fetch and process the markdown file
            const content = await this.fetchFileContent(pagePath, enableLogging);
            const processedHTML = await this.processMarkdownContent(content, pathInfo, enableLogging);
            
            // Load content into target div
            this.loadContentIntoDiv(divID, processedHTML, target);
            
            if (enableLogging) {
                this.addLog(`✅ File loaded successfully: ${pagePath}`);
            }
            
            // Execute callback if provided
            if (typeof callback === 'function') {
                setTimeout(callback, 50);
            }
            
        } catch (error) {
            if (enableLogging) {
                this.addLog(`❌ Failed to load file: ${error.message}`);
            }
            this.showError(`Failed to load ${pagePath}: ${error.message}`, divID);
        }
    }

    // Load required dependencies (showdown for markdown, d3 for data processing)
    async loadDependencies(enableLogging = true) {
        const dependencies = [
            {
                url: 'https://cdn.jsdelivr.net/npm/showdown@2.1.0/dist/showdown.min.js',
                check: () => window.showdown,
                name: 'showdown'
            }
        ];

        for (const dep of dependencies) {
            if (!dep.check()) {
                await this.loadScript(dep.url, dep.name, enableLogging);
            }
        }
    }

    // Load external script with promise
    loadScript(src, name, enableLogging = true) {
        return new Promise((resolve, reject) => {
            if (enableLogging) {
                this.addLog(`📥 Loading dependency: ${name}`);
            }
            
            const script = document.createElement('script');
            script.src = src;
            script.onload = () => {
                if (enableLogging) {
                    this.addLog(`✅ Loaded dependency: ${name}`);
                }
                resolve();
            };
            script.onerror = () => {
                const error = `Failed to load ${name} from ${src}`;
                if (enableLogging) {
                    this.addLog(`❌ ${error}`);
                }
                reject(new Error(error));
            };
            
            document.head.appendChild(script);
        });
    }

    // Process file path to extract folder information
    processFilePath(pagePath) {
        let pageFolder = pagePath;
        
        // Remove query parameters
        if (pageFolder.lastIndexOf('?') > 0) {
            pageFolder = pageFolder.substring(0, pageFolder.lastIndexOf('?'));
        }
        
        // Extract folder path (remove filename if present)
        if (pageFolder.lastIndexOf('.') > pageFolder.lastIndexOf('/')) {
            pageFolder = pageFolder.substring(0, pageFolder.lastIndexOf('/')) + "/";
        }
        
        if (pageFolder === "/") {
            pageFolder = "";
        }
        
        // Handle GitHub wiki URLs
        if (pageFolder.indexOf('https://raw.githubusercontent.com/wiki') >= 0) {
            pageFolder = pageFolder.replace("https://raw.githubusercontent.com/wiki/", "https://github.com/") + "/wiki/";
        }
        
        return {
            originalPath: pagePath,
            folderPath: pageFolder,
            fileName: pagePath.split('/').pop()
        };
    }

    // Fetch file content
    async fetchFileContent(pagePath, enableLogging = true) {
        if (enableLogging) {
            this.addLog(`🔍 Fetching content from: ${pagePath}`);
        }
        
        try {
            const response = await fetch(pagePath);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const content = await response.text();
            if (enableLogging) {
                this.addLog(`📊 Content loaded: ${content.length} characters`);
            }
            return content;
            
        } catch (error) {
            throw new Error(`Failed to fetch ${pagePath}: ${error.message}`);
        }
    }

    // Process markdown content with showdown
    async processMarkdownContent(content, pathInfo, enableLogging = true) {
        if (!window.showdown) {
            throw new Error('Showdown markdown processor not loaded');
        }
        
        if (enableLogging) {
            this.addLog(`🔄 Processing markdown content...`);
        }
        
        // Configure showdown converter with enhanced options
        const converter = new showdown.Converter({
            tables: true,
            metadata: true,
            simpleLineBreaks: true,
            ghCodeBlocks: true,
            tasklists: true,
            strikethrough: true,
            emoji: true,
            underline: true
        });
        
        // Convert markdown to HTML
        const html = converter.makeHtml(content);
        const metadata = converter.getMetadata(true);
        
        // Add edit link for GitHub files
        const editLink = this.createEditLink(pathInfo.originalPath);
        
        // Combine edit link with content
        return editLink + html;
    }

    // Create edit link for GitHub files
    createEditLink(pagePath) {
        if (pagePath.includes('github.com') || pagePath.includes('raw.githubusercontent.com')) {
            return `<div class='edit-link' style='float:right;z-index:1;cursor:pointer;text-decoration:none;opacity:.7;margin-bottom:10px'>
                        <a href='${pagePath}' target='_blank' style='color:var(--text-secondary);text-decoration:none;font-size:14px'>
                            📝 Edit on GitHub
                        </a>
                    </div>`;
        }
        return '';
    }

    // Load content into specified div
    loadContentIntoDiv(divID, html, target) {
        const targetDiv = document.getElementById(divID);
        if (!targetDiv) {
            throw new Error(`Target div with ID '${divID}' not found`);
        }
        
        // Handle different target options
        switch (target) {
            case '_parent':
                targetDiv.innerHTML = html;
                break;
            case '_append':
                targetDiv.innerHTML += html;
                break;
            case '_prepend':
                targetDiv.innerHTML = html + targetDiv.innerHTML;
                break;
            default:
                targetDiv.innerHTML = html;
        }
        
        // Add some basic styling to the loaded content
        targetDiv.style.lineHeight = '1.6';
        targetDiv.style.color = 'var(--text-primary)';
        
        // Style code blocks
        const codeBlocks = targetDiv.querySelectorAll('pre code');
        codeBlocks.forEach(block => {
            block.style.background = '#f6f8fa';
            block.style.padding = '16px';
            block.style.borderRadius = '6px';
            block.style.fontSize = '14px';
            block.style.fontFamily = 'monospace';
        });
        
        // Style tables
        const tables = targetDiv.querySelectorAll('table');
        tables.forEach(table => {
            table.style.borderCollapse = 'collapse';
            table.style.width = '100%';
            table.style.margin = '16px 0';
        });
        
        const cells = targetDiv.querySelectorAll('td, th');
        cells.forEach(cell => {
            cell.style.border = '1px solid var(--border-light)';
            cell.style.padding = '8px 12px';
            cell.style.textAlign = 'left';
        });
        
        const headers = targetDiv.querySelectorAll('th');
        headers.forEach(header => {
            header.style.background = 'var(--bg-tertiary)';
            header.style.fontWeight = '600';
        });
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.dbAdmin = new DatabaseAdmin();
});

// Global displayFile function for easy one-line usage
function displayFile(pagePath, divID, target, callback, enableLogging = true) {
    // Wait for dbAdmin to be initialized
    if (window.dbAdmin) {
        window.dbAdmin.displayFile(pagePath, divID, target, callback, enableLogging);
    } else {
        // Wait and try again
        setTimeout(() => displayFile(pagePath, divID, target, callback, enableLogging), 100);
    }
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DatabaseAdmin;
}