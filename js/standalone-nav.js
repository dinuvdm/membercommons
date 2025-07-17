// Standalone Navigation System - JavaScript

class StandaloneNavigation {
    constructor(options = {}) {
        this.options = {
            basePath: options.basePath || '',
            currentPage: options.currentPage || 'admin',
            ...options
        };
        
        this.isCollapsed = false;
        this.isMobile = window.innerWidth <= 768;
        this.mobileOpen = false;
        
        this.init();
    }
    
    init() {
        this.checkMobile();
        this.createNavigation();
        this.setupEventListeners();
        this.setupMobileHandlers();
        this.initializeFeatherIcons();
        
        // Handle window resize
        window.addEventListener('resize', () => {
            this.checkMobile();
        });
    }
    
    checkMobile() {
        const wasMobile = this.isMobile;
        this.isMobile = window.innerWidth <= 768;
        
        if (wasMobile !== this.isMobile) {
            this.handleMobileChange();
        }
    }
    
    handleMobileChange() {
        const sidebar = document.querySelector('.sidebar');
        const overlay = document.querySelector('.mobile-overlay');
        
        if (this.isMobile) {
            sidebar?.classList.remove('collapsed', 'hovered');
            overlay?.classList.remove('active');
        } else {
            sidebar?.classList.remove('mobile-open');
            this.mobileOpen = false;
        }
    }
    
    createNavigation() {
        // Calculate paths for navigation links
        const basePath = this.options.basePath || '';
        const rootPath = basePath ? `${basePath}/` : './';
        const adminPath = basePath ? `${basePath}/admin/` : './admin/';
        
        const navHTML = `
            <div class="sidebar" id="standalone-sidebar">
                <div class="sidebar-header">
                    <div class="logo">
                        <a href="${rootPath}"><img src="${rootPath}img/logo/neighborhood/favicon.png" alt="Up" /></a>
                    </div>
                    <span class="logo-text">MemberCommons</span>
                </div>
                
                <div class="nav-menu">
                    <div class="nav-section">
                        <div class="nav-item">
                            <button class="nav-link" data-section="home" onclick="window.location.href='${rootPath}#home/welcome'">
                                <i class="nav-icon" data-feather="home"></i>
                                <span class="nav-text">Home</span>
                                <i class="nav-arrow" data-feather="chevron-right"></i>
                            </button>
                            <div class="subnav">
                                <a href="${rootPath}#home/welcome" class="subnav-link">
                                    <i class="subnav-icon" data-feather="smile"></i>
                                    <span>Welcome</span>
                                </a>
                                <a href="${rootPath}#home/documentation" class="subnav-link">
                                    <i class="subnav-icon" data-feather="book"></i>
                                    <span>Getting Started</span>
                                </a>
                                <a href="${rootPath}#home/dashboard" class="subnav-link">
                                    <i class="subnav-icon" data-feather="bar-chart-2"></i>
                                    <span>Dashboard</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="nav-section">
                        <div class="nav-item">
                            <button class="nav-link" data-section="projects" onclick="window.location.href='${rootPath}#projects/opportunities'">
                                <i class="nav-icon" data-feather="folder"></i>
                                <span class="nav-text">Projects</span>
                                <i class="nav-arrow" data-feather="chevron-right"></i>
                            </button>
                            <div class="subnav">
                                <a href="${rootPath}#projects/opportunities" class="subnav-link">
                                    <i class="subnav-icon" data-feather="target"></i>
                                    <span>Opportunities</span>
                                </a>
                                <a href="${rootPath}#projects/assigned-tasks" class="subnav-link">
                                    <i class="subnav-icon" data-feather="check-square"></i>
                                    <span>Assigned Tasks</span>
                                </a>
                                <a href="${rootPath}#projects/timelines" class="subnav-link">
                                    <i class="subnav-icon" data-feather="calendar"></i>
                                    <span>Timelines</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="nav-section">
                        <div class="nav-item">
                            <button class="nav-link" data-section="people" onclick="window.location.href='${rootPath}#people/people'">
                                <i class="nav-icon" data-feather="users"></i>
                                <span class="nav-text">People & Teams</span>
                                <i class="nav-arrow" data-feather="chevron-right"></i>
                            </button>
                            <div class="subnav">
                                <a href="${rootPath}#people/people" class="subnav-link">
                                    <i class="subnav-icon" data-feather="user"></i>
                                    <span>People</span>
                                </a>
                                <a href="${rootPath}#people/teams" class="subnav-link">
                                    <i class="subnav-icon" data-feather="users"></i>
                                    <span>Teams</span>
                                </a>
                                <a href="${rootPath}#people/organizations" class="subnav-link">
                                    <i class="subnav-icon" data-feather="grid"></i>
                                    <span>Organizations</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="nav-section">
                        <div class="nav-item">
                            <button class="nav-link" data-section="account" onclick="window.location.href='${rootPath}#account/preferences'">
                                <i class="nav-icon" data-feather="settings"></i>
                                <span class="nav-text">My Account</span>
                                <i class="nav-arrow" data-feather="chevron-right"></i>
                            </button>
                            <div class="subnav">
                                <a href="${rootPath}#account/preferences" class="subnav-link">
                                    <i class="subnav-icon" data-feather="sliders"></i>
                                    <span>Preferences</span>
                                </a>
                                <a href="${rootPath}#account/skills" class="subnav-link">
                                    <i class="subnav-icon" data-feather="award"></i>
                                    <span>Skills</span>
                                </a>
                                <a href="${rootPath}#account/interests" class="subnav-link">
                                    <i class="subnav-icon" data-feather="heart"></i>
                                    <span>Interests</span>
                                </a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="nav-section">
                        <div class="nav-item">
                            <button class="nav-link ${this.options.currentPage === 'admin' ? 'active' : ''}" data-section="admin" onclick="window.location.href='${adminPath}'">
                                <i class="nav-icon" data-feather="tool"></i>
                                <span class="nav-text">Admin Dashboard</span>
                                <i class="nav-arrow" data-feather="chevron-right"></i>
                            </button>
                            <div class="subnav">
                                <a href="${adminPath}" class="subnav-link">
                                    <i class="subnav-icon" data-feather="database"></i>
                                    <span>Admin Tools</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="sidebar-footer">
                    <button class="sidebar-toggle" id="sidebar-toggle">
                        <i data-feather="chevrons-left"></i>
                    </button>
                </div>
            </div>
            
            <div class="mobile-overlay" id="mobile-overlay"></div>
        `;
        
        // Create app container if it doesn't exist
        let appContainer = document.querySelector('.app-container');
        if (!appContainer) {
            // Store existing content
            const existingContent = Array.from(document.body.children);
            
            // Create app container
            appContainer = document.createElement('div');
            appContainer.className = 'app-container';
            
            // Clear body and add app container
            document.body.innerHTML = '';
            document.body.appendChild(appContainer);
            
            // Add navigation
            appContainer.innerHTML = navHTML;
            
            // Create main content area
            const mainContent = document.createElement('div');
            mainContent.className = 'main-content';
            appContainer.appendChild(mainContent);
            
            // Move existing content to main content
            existingContent.forEach(element => {
                mainContent.appendChild(element);
            });
        }
    }
    
    setupEventListeners() {
        // Sidebar toggle
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => this.toggleSidebar());
        }
        
        // Navigation hover effects
        const sidebar = document.getElementById('standalone-sidebar');
        if (sidebar) {
            sidebar.addEventListener('mouseenter', () => {
                if (this.isCollapsed && !this.isMobile) {
                    sidebar.classList.add('hovered');
                }
            });
            
            sidebar.addEventListener('mouseleave', () => {
                if (this.isCollapsed && !this.isMobile) {
                    sidebar.classList.remove('hovered');
                }
            });
        }
        
        // Subnav toggle
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                if (e.target.closest('.nav-arrow') || e.target.classList.contains('nav-arrow')) {
                    e.preventDefault();
                    e.stopPropagation();
                    this.toggleSubnav(link);
                }
            });
        });
        
        // Click outside to close mobile menu
        document.addEventListener('click', (e) => {
            if (this.isMobile && this.mobileOpen) {
                const sidebar = document.getElementById('standalone-sidebar');
                if (sidebar && !sidebar.contains(e.target)) {
                    this.closeMobileMenu();
                }
            }
        });
    }
    
    setupMobileHandlers() {
        // Mobile menu toggle button (if you want to add one)
        const mobileToggle = document.getElementById('mobile-menu-toggle');
        if (mobileToggle) {
            mobileToggle.addEventListener('click', () => this.toggleMobileMenu());
        }
        
        // Overlay click to close
        const overlay = document.getElementById('mobile-overlay');
        if (overlay) {
            overlay.addEventListener('click', () => this.closeMobileMenu());
        }
    }
    
    toggleSidebar() {
        if (this.isMobile) {
            this.toggleMobileMenu();
            return;
        }
        
        const sidebar = document.getElementById('standalone-sidebar');
        if (sidebar) {
            this.isCollapsed = !this.isCollapsed;
            sidebar.classList.toggle('collapsed', this.isCollapsed);
            
            // Update toggle icon based on state
            this.updateToggleIcon();
            
            // Store state in localStorage
            localStorage.setItem('standaloneNavCollapsed', this.isCollapsed);
        }
    }
    
    updateToggleIcon() {
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (!sidebarToggle) {
            console.log("sidebar-toggle not found");
            return;
        }
        
        // Check actual sidebar state from DOM instead of this.isCollapsed
        const sidebar = document.getElementById('standalone-sidebar');
        const actuallyCollapsed = sidebar ? sidebar.classList.contains('collapsed') : false;
        
        console.log("updateToggleIcon() - DOM collapsed:", actuallyCollapsed, "this.isCollapsed:", this.isCollapsed);
        
        // Sync the class property with actual DOM state
        this.isCollapsed = actuallyCollapsed;
        
        // Look for either <i> element (before feather processing) or <svg> element (after feather processing)
        let icon = sidebarToggle.querySelector('i') || sidebarToggle.querySelector('svg');
        
        if (!icon) {
            console.log("Neither <i> nor <svg> icon found - creating new <i> element");
            // Create new icon element
            icon = document.createElement('i');
            icon.setAttribute('data-feather', 'chevrons-left');
            sidebarToggle.appendChild(icon);
            
            // Reinitialize feather icons for the new element
            if (typeof feather !== 'undefined') {
                feather.replace();
            }
            // After feather processes it, find the new SVG
            icon = sidebarToggle.querySelector('svg');
        }
        
        const targetIcon = this.isCollapsed ? 'chevrons-right' : 'chevrons-left';
        console.log("Setting icon to:", targetIcon);
        
        // If it's an SVG (already processed by feather), we need to replace it with a new <i> element
        if (icon.tagName === 'SVG') {
            console.log("Found SVG, replacing with new <i> element");
            const newIcon = document.createElement('i');
            newIcon.setAttribute('data-feather', targetIcon);
            sidebarToggle.replaceChild(newIcon, icon);
            
            // Process the new icon with feather
            if (typeof feather !== 'undefined') {
                feather.replace();
                console.log("feather.replace() called for new icon");
            }
        } else {
            // If it's an <i> element, just update the attribute
            console.log("Found <i> element, updating data-feather attribute");
            icon.setAttribute('data-feather', targetIcon);
            
            // Refresh feather icons
            if (typeof feather !== 'undefined') {
                feather.replace();
                console.log("feather.replace() called");
            }
        }
    }
    
    toggleMobileMenu() {
        const sidebar = document.getElementById('standalone-sidebar');
        const overlay = document.getElementById('mobile-overlay');
        
        this.mobileOpen = !this.mobileOpen;
        
        if (sidebar) {
            sidebar.classList.toggle('mobile-open', this.mobileOpen);
        }
        
        if (overlay) {
            overlay.classList.toggle('active', this.mobileOpen);
        }
    }
    
    closeMobileMenu() {
        const sidebar = document.getElementById('standalone-sidebar');
        const overlay = document.getElementById('mobile-overlay');
        
        this.mobileOpen = false;
        
        if (sidebar) {
            sidebar.classList.remove('mobile-open');
        }
        
        if (overlay) {
            overlay.classList.remove('active');
        }
    }
    
    toggleSubnav(navLink) {
        const subnav = navLink.parentElement.querySelector('.subnav');
        const arrow = navLink.querySelector('.nav-arrow');
        
        if (subnav && arrow) {
            const isExpanded = subnav.classList.contains('expanded');
            
            if (isExpanded) {
                subnav.classList.remove('expanded');
                arrow.classList.remove('expanded');
            } else {
                subnav.classList.add('expanded');
                arrow.classList.add('expanded');
            }
        }
    }
    
    navigateToRoot(hash = '') {
        const basePath = this.options.basePath;
        const rootPath = basePath ? `${basePath}/index.html` : './index.html';
        window.location.href = rootPath + hash;
    }
    
    navigateToAdmin() {
        const basePath = this.options.basePath;
        const adminPath = basePath ? `${basePath}/admin/` : './admin/';
        window.location.href = adminPath;
    }
    
    initializeFeatherIcons() {
        // Initialize feather icons if available
        if (typeof feather !== 'undefined') {
            feather.replace();
        }
    }
    
    // Restore collapsed state from localStorage
    restoreState() {
        const savedCollapsed = localStorage.getItem('standaloneNavCollapsed');
        const sidebar = document.getElementById('standalone-sidebar');
        
        if (savedCollapsed === 'true' && !this.isMobile) {
            this.isCollapsed = true;
            if (sidebar) {
                sidebar.classList.add('collapsed');
            }
        } else {
            // Default to expanded state
            this.isCollapsed = false;
            if (sidebar) {
                sidebar.classList.remove('collapsed');
            }
        }
        
        console.log("restoreState() - isCollapsed:", this.isCollapsed, "savedCollapsed:", savedCollapsed);
        
        // Update icon to match current state
        this.updateToggleIcon();
    }
}

// Global instance
let standaloneNav;

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    // Determine base path based on current location
    const currentPath = window.location.pathname;
    const pathSegments = currentPath.split('/').filter(segment => segment && segment !== 'index.html');
    let basePath = '';
    
    // Calculate relative path to root (climb one less level)
    if (pathSegments.length > 1) {
        basePath = '../'.repeat(pathSegments.length - 1);
        // Remove trailing slash if present
        basePath = basePath.replace(/\/$/, '');
    }
    
    // Determine current page
    let currentPage = 'home';
    if (currentPath.includes('/admin/')) {
        currentPage = 'admin';
    }
    
    // Initialize standalone navigation
    standaloneNav = new StandaloneNavigation({
        basePath: basePath,
        currentPage: currentPage
    });
    
    // Restore state after initialization and feather icons are ready
    setTimeout(() => {
        if (typeof feather !== 'undefined') {
            feather.replace(); // Ensure feather icons are initialized
        }
        standaloneNav.restoreState();
    }, 500);
});