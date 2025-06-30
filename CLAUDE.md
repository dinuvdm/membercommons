# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Run
- `cargo build` - Build the project
- `cargo run -- serve` - Start the REST API server  
- `cargo run -- init-db` - Initialize database schema
- `cargo check` - Check code without building
- `cargo clippy` - Run linting
- `cargo test` - Run tests

### Development Mode
- `cargo run -- serve` starts server on localhost:8081 by default
- Server host/port configurable via `SERVER_HOST`/`SERVER_PORT` environment variables

## Project Vision & Requirements

This is a **project posting, assignment and to-do tracking system** - an all-in-one partner tool for managing public-facing listings with searchable directories. The system enables collaboration between teams, organizations and clients to share opportunities, handle proposals, assign projects, track progress, and manage invoices.

### Target Audience
Technical coders and programmers who deploy AI to streamline government processes while providing real-time mentoring at local projects funded by Innovation Bonds.

### Core Features Required
1. **Project Management**: Post activities, join projects, track progress
2. **Team Collaboration**: Account-based teams and organizations  
3. **Directory System**: Searchable public listings with pagination
4. **Survey System**: Policy preferences and interests with 5-star ratings
5. **Auth Integration**: Google, GitHub, LinkedIn, email login + Admin Demo bypass
6. **Gemini AI Integration**: Smart insights and natural language search

## Architecture Overview

### Backend (Rust)
- **REST API Server**: Actix-web based HTTP server at `src/main.rs`
- **Database Layer**: PostgreSQL using SQLx with async connection pooling
- **CLI Interface**: Clap-based command structure with `serve` and `init-db` subcommands
- **AI Integration**: Uses `gemini_client_rust` for Google Gemini API

### Frontend (JAM Stack JavaScript)
- **Design Philosophy**: Notion-inspired aesthetic - modular, calm, ultra-minimal
- **Color Palette**: Light green, pastel blue, muted orange accents on neutral background (#F9FAFB)
- **Navigation**: Collapsible left sidebar with smooth animations
- **Routing**: HashRouter for static compatibility with deep linking support
- **No Build Required**: Frontend works directly without compilation

### HashRouter Implementation
The application implements a sophisticated HashRouter system that enables:
- **Deep Linking**: Direct navigation to any section/tab via URL hash
- **Parameter Preservation**: URL parameters persist across navigation changes
- **State Management**: Automatic UI updates based on URL changes
- **Filter Integration**: Search terms, city filters, and project filters are reflected in URL

#### URL Structure
```
#section/tab?param1=value1&param2=value2
```

#### Examples
- `#home/welcome` - Home section, Welcome tab
- `#projects/opportunities?city=atlanta&filter=innovation_bonds` - Projects with filters
- `#people/teams?search=react` - People section with search term
- `#account/preferences` - Account preferences

#### Navigation Methods
- Click navigation elements to update URL automatically
- Use `router.navigate(section, tab, params)` programmatically
- Use `router.setParam(key, value)` to update individual parameters
- Parameters automatically applied to filters and search inputs

#### HashRouter Features
1. **Automatic Validation**: Invalid sections/tabs default to valid alternatives
2. **Parameter Persistence**: Moving from `#home/dashboard?city=Atlanta` to `#people` becomes `#people/people?city=Atlanta`
3. **Filter Synchronization**: URL parameters automatically populate form filters
4. **Browser Integration**: Full browser back/forward button support
5. **Bookmarkable URLs**: Any application state can be bookmarked and shared

#### Supported URL Parameters
- `city`: Filter by location (atlanta, portland, detroit, remote)
- `search`: Search term for projects or people
- `filter`: Project filter (all, opportunities, job_openings, innovation_bonds, high_priority)
- `skill`: Filter by technical skill
- `experience`: Filter by experience level

#### Implementation Notes
- HashRouter is initialized on DOM load and handles all navigation automatically
- Existing navigation event handlers updated to use `router.navigate()` instead of direct DOM manipulation
- Filter changes trigger URL updates with 500ms debounce for search inputs
- All application state syncs with URL parameters for consistent user experience

### Database Schema
Complete CRM schema based on SuiteCRM/Salesforce structure:
- Core entities: users, accounts, contacts, leads, opportunities, projects
- Support entities: campaigns, documents, events, products, roles, calls
- Survey system: surveys, surveyquestionoptions, surveyquestionresponses
- Relationship tables for many-to-many associations
- All tables use UUID primary keys and include audit fields

## Setup Process Improvements

### Environment Configuration
1. **Primary Database**: PostgreSQL (Azure/Google compatible)
   ```
   DATABASE_URL=postgresql://sqladmin@model-earth-server.database.windows.net/ModelEarthDB
   GEMINI_API_KEY=your_key_here
   SERVER_HOST=127.0.0.1
   SERVER_PORT=8081
   ```

2. **Fallback Handling**: When database connection fails, populate with informative placeholders rather than errors

3. **Security**: Store auth keys in separate config file excluded by `.gitignore`

### Frontend Setup Requirements
```javascript
const API_BASE = 'http://localhost:8081/api'; // Backend URL
```

### Navigation Structure
```
Home
├── Welcome
├── Documentation
├── Dashboard
Projects
├── Opportunities
├── Assigned Tasks
├── Timelines 
People and Teams
├── People
├── Teams
├── Organizations
My Account
├── Preferences
├── Skills
├── Interests
```

### Key Dependencies
- **actix-web**: Web framework
- **sqlx**: Database toolkit with PostgreSQL driver
- **gemini_client_rust**: Gemini AI integration
- **tokio**: Async runtime
- **clap**: CLI argument parsing
- **serde**: Serialization framework
- **uuid**: UUID generation
- **chrono**: Date/time handling

### File Structure
- `src/main.rs` - Single-file application containing all logic
- `sql/suitecrm-postgres.sql` - Database schema reference  
- `project/edit.html` - Frontend template
- `.bolt/prompt` - Original project specifications
- `Cargo.toml` - Project configuration and dependencies

### Database Initialization
Run `cargo run -- init-db` to create all tables with proper relationships and constraints. The schema supports full CRM functionality with foreign key relationships between entities.

### Account Management
- **accounts** table serves dual purpose for teams AND organizations
- Account creators become managers automatically
- Managers can promote users to manager/editor roles
- No separate members/managers tables needed

### AI Integration Points
1. **Smart Insights**: Analyze account/contact relationships, suggest next steps
2. **Natural Language Search**: Conversational contact queries
3. **Data Analysis**: Generate summaries and recommendations

### Survey System
- Policy preferences: 20 "hot topics" with 5-point Likert scale
- Interest ratings: 20 categories with 5-star ratings (Agriculture, Climate Resilience, etc.)
- Sankey charts showing response correlations (green=positive, mauve=negative)
- Location, age, and demographic data collection