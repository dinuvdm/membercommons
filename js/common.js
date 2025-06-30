// Common utilities and shared functions for MemberCommons

// API Configuration
const API_BASE = 'http://localhost:8081/api';

// API utility function
async function apiCall(endpoint, method = 'GET', data = null) {
    try {
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            }
        };
        
        if (data) {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(`${API_BASE}${endpoint}`, options);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('API call failed:', error);
        // Return placeholder data for development
        return {
            error: true,
            message: 'Connection failed - showing placeholder data',
            data: null
        };
    }
}

// Notification utility
function showNotification(message, type = 'info') {
    // Remove existing notifications
    const existing = document.querySelector('.notification');
    if (existing) existing.remove();

    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i data-feather="${type === 'success' ? 'check-circle' : 'info'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()">
            <i data-feather="x"></i>
        </button>
    `;

    document.body.appendChild(notification);
    
    // Initialize feather icons if available
    if (window.feather) {
        feather.replace();
    }

    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Format date for display
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
    });
}

// Utility to safely get element by ID
function safeGetElement(id) {
    const element = document.getElementById(id);
    if (!element) {
        console.warn(`Element with ID '${id}' not found`);
    }
    return element;
}

// Utility to safely query selector
function safeQuerySelector(selector) {
    const element = document.querySelector(selector);
    if (!element) {
        console.warn(`Element with selector '${selector}' not found`);
    }
    return element;
}

// Initialize Feather icons safely
function initializeFeatherIcons() {
    // Wait for feather to be available
    const featherLib = (typeof feather !== 'undefined' && feather) || window.feather;
    
    if (featherLib && featherLib.replace && featherLib.icons) {
        // Always use manual processing to avoid bulk replace issues
        const featherElements = document.querySelectorAll('[data-feather]');
        
        featherElements.forEach(el => {
            const iconName = el.getAttribute('data-feather');
            
            // Skip if no icon name or already processed
            if (!iconName || !iconName.trim() || el.querySelector('svg')) {
                return;
            }
            
            // Check if icon exists in feather library
            if (featherLib.icons && featherLib.icons[iconName]) {
                try {
                    const icon = featherLib.icons[iconName];
                    if (icon && typeof icon.toSvg === 'function') {
                        el.innerHTML = icon.toSvg();
                    }
                } catch (iconError) {
                    console.warn(`Failed to render icon: ${iconName}`, iconError);
                }
            } else {
                console.warn(`Icon '${iconName}' not found in Feather library`);
            }
        });
    } else {
        // Wait a bit and try again (max 3 seconds)
        if (!initializeFeatherIcons._retryCount) {
            initializeFeatherIcons._retryCount = 0;
        }
        
        if (initializeFeatherIcons._retryCount < 30) {
            initializeFeatherIcons._retryCount++;
            setTimeout(() => {
                if (typeof feather !== 'undefined' || window.feather) {
                    initializeFeatherIcons();
                }
            }, 100);
        }
    }
}

// Wait for DOM and dependencies to be ready
function waitForDependencies(callback, dependencies = ['feather'], maxWait = 5000) {
    const startTime = Date.now();
    
    function checkDependencies() {
        const allReady = dependencies.every(dep => {
            return (typeof window[dep] !== 'undefined' && window[dep]) || 
                   (typeof globalThis[dep] !== 'undefined' && globalThis[dep]);
        });
        
        if (allReady) {
            callback();
        } else if (Date.now() - startTime < maxWait) {
            setTimeout(checkDependencies, 50);
        } else {
            console.warn('Dependencies not loaded in time:', dependencies);
            callback(); // Continue anyway
        }
    }
    
    checkDependencies();
}

// Export functions for module usage if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        apiCall,
        showNotification,
        formatDate,
        safeGetElement,
        safeQuerySelector,
        initializeFeatherIcons,
        waitForDependencies,
        API_BASE
    };
}

// Make functions globally available
window.apiCall = apiCall;
window.showNotification = showNotification;
window.formatDate = formatDate;
window.safeGetElement = safeGetElement;
window.safeQuerySelector = safeQuerySelector;
window.initializeFeatherIcons = initializeFeatherIcons;
window.waitForDependencies = waitForDependencies;