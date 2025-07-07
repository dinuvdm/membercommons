// Shared Navigation System for MemberCommons
class NavigationSystem {
    constructor(options = {}) {
        this.config = null;
        this.currentSection = options.defaultSection || 'home';
        this.currentTab = options.defaultTab || 'welcome';
        this.sidebarCollapsed = false;
        this.sidebarLocked = false; // Default to unlocked (allows hover expansion)
        this.tooltips = new Map();
        this.router = null;
        this.isMobile = false;
        this.isNarrow = false;
        this.isDesktop = true;
        this.mobileOpen = false;
        this.callbacks = {
            onSectionChange: options.onSectionChange || null,
            onTabChange: options.onTabChange || null,
            onSidebarToggle: options.onSidebarToggle || null
        };
        
        this.init();
    }

    async init() {
        try {
            await this.loadConfig();
            this.checkMobileState();
            this.createNavigationHTML();
            this.setupEventListeners();
            this.initializeRouter();
            this.initializeClosedSections(); // Start with all subnav sections closed
            this.restoreSidebarState(); // This might override the closed sections if needed
            this.updateNavigationState(this.currentSection, this.currentTab);
            this.updateLockUI(); // Ensure lock UI is properly initialized
            this.setupResizeListener(); // Handle screen size changes
        } catch (error) {
            console.error('Failed to initialize navigation:', error);
        }
    }

    checkMobileState() {
        const width = window.innerWidth;
        this.isMobile = width <= 500;
        this.isNarrow = width <= 700; // Narrow screens use overlay behavior
        this.isDesktop = width > 700; // Desktop screens push content
    }

    setupResizeListener() {
        window.addEventListener('resize', () => {
            const wasMobile = this.isMobile;
            const wasNarrow = this.isNarrow;
            this.checkMobileState();
            
            // If switching from mobile to desktop, ensure proper state
            if (wasMobile && !this.isMobile) {
                this.handleMobileToDesktop();
            } else if (!wasMobile && this.isMobile) {
                this.handleDesktopToMobile();
            }
            
            // Handle narrow to desktop transition
            if (wasNarrow && this.isDesktop) {
                this.handleNarrowToDesktop();
            } else if (!wasNarrow && this.isNarrow) {
                this.handleDesktopToNarrow();
            }
        });
    }

    handleNarrowToDesktop() {
        // Ensure proper hover behavior for desktop
        const sidebar = document.getElementById('sidebar');
        if (sidebar) {
            sidebar.classList.remove('mobile-open');
            this.mobileOpen = false;
        }
    }

    handleDesktopToNarrow() {
        // Handle transition to narrow screen
        if (this.isMobile) {
            this.closeMobileSidebar();
        }
    }

    handleMobileToDesktop() {
        const sidebar = document.getElementById('sidebar');
        if (sidebar) {
            sidebar.classList.remove('mobile-open');
            this.mobileOpen = false;
        }
    }

    handleDesktopToMobile() {
        // Close sidebar when switching to mobile
        this.closeMobileSidebar();
    }

    async loadConfig() {
        try {
            // Calculate path to repo root based on current page depth
            const currentPath = window.location.pathname;
            const pathSegments = currentPath.split('/').filter(segment => segment && segment !== 'index.html');
            const depth = pathSegments.length - 1; // Subtract 1 since we're already in a directory
            const upLevels = '../'.repeat(depth);
            const configPath = `${upLevels}config/navigation.json`;
            
            const response = await fetch(configPath);
            
            if (!response.ok) {
                throw new Error(`Failed to load navigation config: HTTP ${response.status}: ${response.statusText}`);
            }
            
            this.config = await response.json();
        } catch (error) {
            console.error('Error loading navigation config:', error);
            
            // Fallback to embedded config
            this.config = this.getFallbackConfig();
            console.warn('Using fallback navigation config');
        }
    }

    getFallbackConfig() {
        return {
            "navigation": {
                "sidebar": {
                    "brand": {
                        "logo": "MC",
                        "text": "MemberCommons"
                    },
                    "sections": [
                        {
                            "id": "home",
                            "label": "Home",
                            "icon": "home",
                            "default_tab": "welcome",
                            "subnav": [
                                {"id": "welcome", "label": "Welcome", "icon": "smile"},
                                {"id": "documentation", "label": "Documentation", "icon": "book"},
                                {"id": "dashboard", "label": "Dashboard", "icon": "bar-chart-2"}
                            ]
                        },
                        {
                            "id": "projects", 
                            "label": "Projects",
                            "icon": "folder",
                            "default_tab": "opportunities",
                            "subnav": [
                                {"id": "opportunities", "label": "Opportunities", "icon": "target"},
                                {"id": "assigned-tasks", "label": "Assigned Tasks", "icon": "check-square"},
                                {"id": "timelines", "label": "Timelines", "icon": "calendar"}
                            ]
                        },
                        {
                            "id": "people",
                            "label": "People & Teams", 
                            "icon": "users",
                            "default_tab": "people",
                            "subnav": [
                                {"id": "people", "label": "People", "icon": "user"},
                                {"id": "teams", "label": "Teams", "icon": "users"},
                                {"id": "organizations", "label": "Organizations", "icon": "grid"}
                            ]
                        },
                        {
                            "id": "account",
                            "label": "My Account",
                            "icon": "settings", 
                            "default_tab": "preferences",
                            "subnav": [
                                {"id": "preferences", "label": "Preferences", "icon": "sliders"},
                                {"id": "skills", "label": "Skills", "icon": "award"},
                                {"id": "interests", "label": "Interests", "icon": "heart"}
                            ]
                        },
                        {
                            "id": "admin",
                            "label": "Admin Tools",
                            "icon": "tool",
                            "default_tab": "database",
                            "subnav": [
                                {"id": "database", "label": "Database Admin", "icon": "database"},
                                {"id": "log-output", "label": "Log Output", "icon": "monitor"}
                            ]
                        }
                    ]
                },
                "settings": {
                    "sidebar_width": "280px",
                    "sidebar_collapsed": "64px",
                    "transition": "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)",
                    "enable_tooltips": true,
                    "enable_routing": true,
                    "default_section": "home",
                    "default_tab": "welcome"
                }
            }
        };
    }

    createNavigationHTML() {
        if (!this.config) return;

        const nav = this.config.navigation;
        
        // Create sidebar HTML
        const sidebarHTML = `
            <div class="sidebar" id="sidebar">
                <div class="sidebar-header">
                    <div class="logo">${nav.sidebar.brand.logo}</div>
                    <div class="logo-text">${nav.sidebar.brand.text}</div>
                    <button class="sidebar-toggle" id="sidebar-toggle">
                        <i data-feather="chevrons-left"></i>
                    </button>
                </div>
                <nav class="sidebar-nav">
                    ${this.createSectionNavHTML(nav.sidebar.sections)}
                </nav>
                <div class="sidebar-footer">
                    <button class="nav-lock-toggle" id="nav-lock-toggle" title="Lock navigation">
                        <i data-feather="unlock" class="lock-icon"></i>
                        <span class="nav-text">Lock Navigation</span>
                    </button>
                </div>
            </div>
        `;

        // Create main content area wrapper  
        const mainContentHTML = `
            <div class="main-content" id="main-content">
                <div class="top-bar">
                    <h1 class="page-title" id="page-title">Welcome</h1>
                    <div class="user-menu">
                        <div class="auth-container">
                            <button class="btn btn-secondary" id="auth-signin">Sign In</button>
                            <button class="btn btn-primary" id="admin-demo">Admin Demo</button>
                        </div>
                    </div>
                </div>
                <div class="content-header">
                    <div class="section-tabs" id="section-tabs">
                        ${this.createTabsHTML()}
                    </div>
                </div>
                <div class="tab-content" id="tab-content">
                    <!-- Content will be injected here by individual pages -->
                </div>
            </div>
        `;

        // Find app container or create one
        let appContainer = document.querySelector('.app-container');
        if (!appContainer) {
            // Store existing content before creating app container
            const existingContent = Array.from(document.body.children);
            
            appContainer = document.createElement('div');
            appContainer.className = 'app-container';
            
            // Clear body and add app container first
            document.body.innerHTML = '';
            document.body.appendChild(appContainer);
            
            // Add navigation HTML
            appContainer.innerHTML = sidebarHTML + mainContentHTML;
            
            // Move existing content to tab-content area
            const tabContent = document.getElementById('tab-content');
            if (tabContent && existingContent.length > 0) {
                existingContent.forEach(element => {
                    tabContent.appendChild(element);
                });
            }
        } else {
            // App container exists, just update navigation
            appContainer.innerHTML = sidebarHTML + mainContentHTML;
        }

        // Initialize feather icons
        if (window.initializeFeatherIcons) {
            window.initializeFeatherIcons();
        }
    }

    createSectionNavHTML(sections) {
        return sections.map(section => {
            const subnavHTML = section.subnav.map(item => `
                <a href="#${item.id}" class="subnav-link" data-tab="${item.id}" data-section="${section.id}">
                    <i class="subnav-icon" data-feather="${item.icon}"></i>
                    <span>${item.label}</span>
                </a>
            `).join('');

            return `
                <div class="nav-section">
                    <div class="nav-item">
                        <button class="nav-link" data-section="${section.id}">
                            <i class="nav-icon" data-feather="${section.icon}"></i>
                            <span class="nav-text">${section.label}</span>
                            <i class="nav-arrow" data-feather="chevron-right"></i>
                        </button>
                        <div class="subnav" data-section="${section.id}">
                            ${subnavHTML}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }

    createTabsHTML() {
        if (!this.config) return '';
        
        const sections = this.config.navigation.sidebar.sections;
        return sections.map(section => {
            const tabsHTML = section.subnav.map(tab => `
                <div class="tab" data-tab="${tab.id}" data-section="${section.id}">
                    <i data-feather="${tab.icon}"></i>
                    <span>${tab.label}</span>
                </div>
            `).join('');

            return `
                <div class="tab-group" data-section="${section.id}" style="display: none;">
                    ${tabsHTML}
                </div>
            `;
        }).join('');
    }

    setupEventListeners() {
        // Sidebar toggle
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => this.toggleSidebar());
        }

        // Navigation lock toggle
        const navLockToggle = document.getElementById('nav-lock-toggle');
        if (navLockToggle) {
            navLockToggle.addEventListener('click', () => this.toggleNavLock());
        }

        // Section navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                const section = e.currentTarget.dataset.section;
                if (section) {
                    // Handle subnav expansion/collapse (allow multiple open)
                    const subnav = e.currentTarget.parentElement.querySelector('.subnav');
                    const arrow = e.currentTarget.querySelector('.nav-arrow');
                    
                    if (subnav && arrow) {
                        subnav.classList.toggle('expanded');
                        arrow.classList.toggle('expanded');
                    }
                    
                    this.switchSection(section);
                }
            });
        });

        // Sub-navigation (tabs)
        document.querySelectorAll('.subnav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const section = e.currentTarget.dataset.section;
                const tab = e.currentTarget.dataset.tab;
                
                // Find parent nav link and ensure its section is active
                const parentNavLink = e.currentTarget.closest('.nav-section').querySelector('.nav-link');
                const targetSection = parentNavLink?.getAttribute('data-section');
                
                // Check if this is a link to the current page on mobile
                const isCurrentPage = targetSection === this.currentSection;
                
                if (targetSection !== this.currentSection) {
                    this.switchSection(targetSection);
                    setTimeout(() => this.switchTab(tab), 50);
                } else {
                    this.switchTab(tab);
                }
                
                // Auto-collapse on mobile if clicking a link on the current page
                if (this.isMobile && isCurrentPage) {
                    this.closeMobileSidebar();
                }
            });
        });

        // Tab clicks
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                const tabId = e.currentTarget.dataset.tab;
                this.switchTab(tabId);
            });
        });

        // Sidebar hover for collapsed state
        const sidebar = document.getElementById('sidebar');
        const sidebarFooter = document.querySelector('.sidebar-footer');
        
        if (sidebar) {
            sidebar.addEventListener('mouseenter', () => {
                if (this.sidebarCollapsed && !this.sidebarLocked) {
                    sidebar.classList.add('hover-expanded');
                }
            });

            sidebar.addEventListener('mouseleave', () => {
                if (this.sidebarCollapsed && !this.sidebarLocked) {
                    sidebar.classList.remove('hover-expanded', 'footer-hovered');
                }
            });
        }

        // Block expansion when hovering over footer
        if (sidebarFooter) {
            sidebarFooter.addEventListener('mouseenter', () => {
                if (this.sidebarCollapsed && !this.sidebarLocked) {
                    sidebar.classList.add('footer-hovered');
                    sidebar.classList.remove('hover-expanded');
                }
            });

            sidebarFooter.addEventListener('mouseleave', () => {
                if (this.sidebarCollapsed && !this.sidebarLocked) {
                    sidebar.classList.remove('footer-hovered');
                    // Check if still hovering over sidebar to restore expansion
                    const rect = sidebar.getBoundingClientRect();
                    const mouseX = event.clientX;
                    const mouseY = event.clientY;
                    if (mouseX >= rect.left && mouseX <= rect.right && 
                        mouseY >= rect.top && mouseY <= rect.bottom) {
                        sidebar.classList.add('hover-expanded');
                    }
                }
            });
        }

        // Click outside to collapse sidebar
        document.addEventListener('click', (e) => {
            const sidebar = document.getElementById('sidebar');
            const sidebarToggle = document.getElementById('sidebar-toggle');
            
            // Check if click is outside sidebar and not on toggle button
            if (sidebar && !sidebar.contains(e.target) && e.target !== sidebarToggle) {
                if (this.isMobile) {
                    // On mobile, close if open
                    if (this.mobileOpen) {
                        this.closeMobileSidebar();
                    }
                } else {
                    // On desktop, collapse if expanded (regardless of lock state)
                    if (!this.sidebarCollapsed) {
                        this.toggleSidebar(true); // Force collapse
                    }
                }
            }
        });

        // Handle clicks on sidebar
        if (sidebar) {
            sidebar.addEventListener('click', (e) => {
                // Check if click is on sidebar background areas (not on interactive elements)
                const isBackgroundClick = e.target === sidebar || 
                    e.target.classList.contains('sidebar-nav') ||
                    e.target.classList.contains('sidebar-footer') ||
                    e.target.closest('.nav-section') === null;
                
                if (isBackgroundClick) {
                    if (this.isMobile) {
                        // On mobile, close sidebar when clicking background
                        this.closeMobileSidebar();
                        return;
                    } else {
                        // Desktop behavior
                        // If navigation is expanded, clicking background should collapse it
                        if (!this.sidebarCollapsed) {
                            this.toggleSidebar(true); // Force collapse
                            return;
                        }
                        
                        // If sidebar is locked and collapsed, clicking background unlocks it
                        if (this.sidebarLocked) {
                            this.toggleNavLock(); // Unlock the navigation
                            return;
                        }
                    }
                } else {
                    // Prevent sidebar from collapsing when clicking on interactive elements
                    e.stopPropagation();
                }
            });
        }

        // Setup tooltips for collapsed sidebar
        this.setupTooltips();
    }

    setupTooltips() {
        document.querySelectorAll('.nav-link, .subnav-link, .nav-lock-toggle').forEach(item => {
            const text = item.querySelector('.nav-text')?.textContent || item.querySelector('span')?.textContent;
            if (text) {
                item.addEventListener('mouseenter', (e) => {
                    // Show tooltips only when collapsed and locked (since no hover expansion when locked)
                    // When unlocked and collapsed, hover expansion shows the text instead
                    if (this.sidebarCollapsed && this.sidebarLocked) {
                        this.showTooltip(e.currentTarget, text);
                    }
                });

                item.addEventListener('mouseleave', () => {
                    this.hideTooltips();
                });
            }
        });
    }

    showTooltip(element, text) {
        const rect = element.getBoundingClientRect();
        const tooltip = document.createElement('div');
        tooltip.className = 'nav-tooltip';
        tooltip.textContent = text;
        tooltip.style.cssText = `
            position: fixed;
            left: ${rect.right + 10}px;
            top: ${rect.top + (rect.height / 2)}px;
            transform: translateY(-50%);
            background: var(--text-primary);
            color: var(--bg-secondary);
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            white-space: nowrap;
            z-index: 10000;
            pointer-events: none;
        `;

        document.body.appendChild(tooltip);
        this.tooltips.set(element, tooltip);
    }

    hideTooltips() {
        this.tooltips.forEach((tooltip, element) => {
            if (tooltip.parentNode) {
                tooltip.parentNode.removeChild(tooltip);
            }
        });
        this.tooltips.clear();
    }

    toggleSidebar(forceState = null) {
        // Handle mobile differently
        if (this.isMobile) {
            return this.toggleMobileSidebar(forceState);
        }

        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        
        if (!sidebar || !mainContent) return;

        // Don't allow toggle if locked (unless it's a force command)
        if (this.sidebarLocked && forceState === null) {
            return !this.sidebarCollapsed;
        }

        const isCurrentlyCollapsed = sidebar.classList.contains('collapsed');
        
        // Determine target state
        let shouldCollapse;
        if (forceState === true) {
            shouldCollapse = true;  // Force collapse
        } else if (forceState === false) {
            shouldCollapse = false; // Force expand
        } else {
            shouldCollapse = !isCurrentlyCollapsed; // Toggle
        }

        if (shouldCollapse && !isCurrentlyCollapsed) {
            sidebar.classList.add('collapsed');
            mainContent.style.marginLeft = this.config?.navigation?.settings?.sidebar_collapsed || '64px';
            this.sidebarCollapsed = true;
        } else if (!shouldCollapse && isCurrentlyCollapsed) {
            sidebar.classList.remove('collapsed', 'hover-expanded');
            mainContent.style.marginLeft = this.config?.navigation?.settings?.sidebar_width || '280px';
            this.sidebarCollapsed = false;
        }

        // Store state in localStorage
        localStorage.setItem('sidebarCollapsed', this.sidebarCollapsed.toString());

        // Trigger callback
        if (this.callbacks.onSidebarToggle) {
            this.callbacks.onSidebarToggle(this.sidebarCollapsed);
        }

        return !this.sidebarCollapsed; // Return expanded state
    }

    toggleMobileSidebar(forceState = null) {
        const sidebar = document.getElementById('sidebar');
        if (!sidebar) return;

        let shouldOpen;
        if (forceState === true) {
            shouldOpen = false; // Force close
        } else if (forceState === false) {
            shouldOpen = true; // Force open
        } else {
            shouldOpen = !this.mobileOpen; // Toggle
        }

        if (shouldOpen) {
            sidebar.classList.add('mobile-open');
            this.mobileOpen = true;
        } else {
            sidebar.classList.remove('mobile-open');
            this.mobileOpen = false;
        }

        return this.mobileOpen;
    }

    closeMobileSidebar() {
        if (this.isMobile) {
            this.toggleMobileSidebar(true); // Force close
        }
    }

    toggleNavLock() {
        this.sidebarLocked = !this.sidebarLocked;
        
        const sidebar = document.getElementById('sidebar');
        const lockToggle = document.getElementById('nav-lock-toggle');
        const lockIcon = lockToggle?.querySelector('.lock-icon');
        
        if (this.sidebarLocked) {
            // Lock is ON - immediately collapse sidebar to narrow and lock it there
            sidebar?.classList.add('locked');
            lockToggle?.classList.add('locked');
            lockToggle?.setAttribute('title', 'Unlock navigation');
            if (lockIcon) lockIcon.setAttribute('data-feather', 'lock');
            
            // Update the text content for the lock toggle
            const lockText = lockToggle?.querySelector('.nav-text');
            if (lockText) lockText.textContent = 'Unlock Navigation';
            
            // Force collapse the sidebar to narrow position
            this.toggleSidebar(true);
        } else {
            // Lock is OFF - immediately expand sidebar to wide and allow normal toggling
            sidebar?.classList.remove('locked');
            lockToggle?.classList.remove('locked');
            lockToggle?.setAttribute('title', 'Lock navigation');
            if (lockIcon) lockIcon.setAttribute('data-feather', 'unlock');
            
            // Update the text content for the lock toggle
            const lockText = lockToggle?.querySelector('.nav-text');
            if (lockText) lockText.textContent = 'Lock Navigation';
            
            // Force expand the sidebar to wide position
            this.toggleSidebar(false);
        }
        
        // Update icon
        if (window.feather) {
            feather.replace();
        }
        
        // Store lock state in localStorage
        localStorage.setItem('sidebarLocked', this.sidebarLocked.toString());
    }

    updateLockUI() {
        // Ensure lock UI is properly synchronized with current state
        const sidebar = document.getElementById('sidebar');
        const lockToggle = document.getElementById('nav-lock-toggle');
        const lockIcon = lockToggle?.querySelector('.lock-icon');
        const lockText = lockToggle?.querySelector('.nav-text');

        if (this.sidebarLocked) {
            // Locked state
            sidebar?.classList.add('locked');
            lockToggle?.classList.add('locked');
            lockToggle?.setAttribute('title', 'Unlock navigation');
            if (lockIcon) lockIcon.setAttribute('data-feather', 'lock');
            if (lockText) lockText.textContent = 'Unlock Navigation';
        } else {
            // Unlocked state
            sidebar?.classList.remove('locked');
            lockToggle?.classList.remove('locked');
            lockToggle?.setAttribute('title', 'Lock navigation');
            if (lockIcon) lockIcon.setAttribute('data-feather', 'unlock');
            if (lockText) lockText.textContent = 'Lock Navigation';
        }

        // Update feather icons
        if (window.initializeFeatherIcons) {
            window.initializeFeatherIcons();
        }
    }

    updatePageTitle(section, tab) {
        const pageTitle = document.getElementById('page-title');
        if (!pageTitle) return;

        const titles = {
            'home': {
                'welcome': 'Welcome',
                'documentation': 'Documentation',
                'dashboard': 'Dashboard'
            },
            'projects': {
                'opportunities': 'Opportunities',
                'assigned-tasks': 'Assigned Tasks',
                'timelines': 'Timelines'
            },
            'people': {
                'people': 'People',
                'teams': 'Teams',
                'organizations': 'Organizations'
            },
            'account': {
                'preferences': 'Preferences',
                'skills': 'Skills',
                'interests': 'Interests'
            },
            'admin': {
                'database': 'Database Admin',
                'log-output': 'Log Output'
            }
        };

        const title = titles[section]?.[tab] || 'MemberCommons';
        pageTitle.textContent = title;
    }

    initializeClosedSections() {
        // Ensure all subnav sections start closed (sidebar stays wide, but subnav items hidden)
        document.querySelectorAll('.nav-section').forEach(navSection => {
            const subnav = navSection.querySelector('.subnav');
            const arrow = navSection.querySelector('.nav-arrow');
            
            // Remove expanded classes to hide subnav items (main nav sections remain visible)
            subnav?.classList.remove('expanded');
            arrow?.classList.remove('expanded');
        });
    }

    restoreSidebarState() {
        // Restore lock state first (this affects sidebar behavior)
        const savedLockState = localStorage.getItem('sidebarLocked');
        if (savedLockState === 'true') {
            // Restore locked state - this will collapse and lock the sidebar
            this.sidebarLocked = false; // Set to false first so toggle works
            this.toggleNavLock(); // This will set it to true, collapse sidebar, and update UI
        } else {
            // Default unlocked state - ensure sidebar is expanded unless user specifically collapsed it
            const savedState = localStorage.getItem('sidebarCollapsed');
            if (savedState === 'true') {
                this.toggleSidebar(true); // Force collapse (but still allow hover expansion)
            } else {
                // Default to expanded state (sidebar wide, unlocked)
                this.toggleSidebar(false); // Ensure sidebar is expanded
            }
        }
    }

    switchSection(sectionName) {
        if (this.currentSection === sectionName) return;

        // Update section state
        this.currentSection = sectionName;
        
        // Find default tab for section
        const section = this.config?.navigation?.sidebar?.sections?.find(s => s.id === sectionName);
        const defaultTab = section?.default_tab || section?.subnav?.[0]?.id;
        
        if (defaultTab) {
            this.currentTab = defaultTab;
        }

        this.updateNavigationState(this.currentSection, this.currentTab);

        // Trigger callback
        if (this.callbacks.onSectionChange) {
            this.callbacks.onSectionChange(this.currentSection, this.currentTab);
        }

        // Update router
        if (this.router) {
            this.router.navigate(this.currentSection, this.currentTab);
        }
    }

    switchTab(tabName) {
        if (this.currentTab === tabName) return;

        this.currentTab = tabName;
        this.updateNavigationState(this.currentSection, this.currentTab);

        // Trigger callback
        if (this.callbacks.onTabChange) {
            this.callbacks.onTabChange(this.currentTab, this.currentSection);
        }

        // Update router
        if (this.router) {
            this.router.navigate(this.currentSection, this.currentTab);
        }
    }

    updateNavigationState(section, tab) {
        // Update active section
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.toggle('active', link.dataset.section === section);
        });

        // Update active subnav item
        document.querySelectorAll('.subnav-link').forEach(link => {
            link.classList.toggle('active', 
                link.dataset.section === section && link.dataset.tab === tab);
        });

        // Show/hide section tabs
        document.querySelectorAll('.tab-group').forEach(group => {
            group.style.display = group.dataset.section === section ? 'flex' : 'none';
        });

        // Update active tab
        document.querySelectorAll('.tab').forEach(tabEl => {
            tabEl.classList.toggle('active', 
                tabEl.dataset.section === section && tabEl.dataset.tab === tab);
        });

        // Expand active section subnav (but don't close others - allow multiple open)
        document.querySelectorAll('.nav-section').forEach(navSection => {
            const navLink = navSection.querySelector('.nav-link');
            const subnav = navSection.querySelector('.subnav');
            const arrow = navSection.querySelector('.nav-arrow');
            const isActive = navLink?.dataset.section === section;
            
            // Only ensure the active section is expanded, don't close others
            if (isActive && tab) {
                // Only expand if we have a specific tab (not just switching sections)
                subnav?.classList.add('expanded');
                arrow?.classList.add('expanded');
            }
        });

        // Update page title
        this.updatePageTitle(section, tab);
    }

    initializeRouter() {
        // Simple hash-based router
        this.router = {
            navigate: (section, tab, params = {}) => {
                const hash = `#${section}/${tab}`;
                window.location.hash = hash;
            },
            
            parseHash: () => {
                const hash = window.location.hash.slice(1);
                const [section, tab] = hash.split('/');
                return { section: section || 'home', tab: tab || 'welcome' };
            },
            
            handleHashChange: () => {
                const { section, tab } = this.router.parseHash();
                if (section !== this.currentSection || tab !== this.currentTab) {
                    this.currentSection = section;
                    this.currentTab = tab;
                    this.updateNavigationState(section, tab);
                    
                    // Trigger callbacks
                    if (this.callbacks.onSectionChange) {
                        this.callbacks.onSectionChange(section, tab);
                    }
                }
            }
        };

        // Listen for hash changes
        window.addEventListener('hashchange', this.router.handleHashChange);
        
        // Initialize from current hash
        const { section, tab } = this.router.parseHash();
        if (section && tab) {
            this.currentSection = section;
            this.currentTab = tab;
        }
    }

    // Public API methods
    getCurrentSection() {
        return this.currentSection;
    }

    getCurrentTab() {
        return this.currentTab;
    }

    getSidebarState() {
        return this.sidebarCollapsed;
    }

    // Method to add custom navigation styles
    addCustomStyles(styles) {
        const styleSheet = document.createElement('style');
        styleSheet.textContent = styles;
        document.head.appendChild(styleSheet);
    }

    // Method to update navigation config
    updateConfig(newConfig) {
        this.config = { ...this.config, ...newConfig };
        this.createNavigationHTML();
        this.setupEventListeners();
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NavigationSystem;
}

// Global initialization function
window.initializeNavigation = function(options = {}) {
    return new NavigationSystem(options);
};