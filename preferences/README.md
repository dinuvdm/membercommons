  Excel Data Source

  The application loads data from DFC-ActiveProjects.xlsx located in the projects/ folder. This appears to be US Development
  Finance Corporation (DFC) funded projects data.

  Data Structure

  The Excel file contains project data with these fields:
  - Fiscal Year - When the project was funded
  - Project Number - Unique identifier
  - Project Type - Category of project
  - Region - Geographic region
  - Country - Specific country
  - Department - Funding department
  - Framework - Project framework/program
  - Project Name - Title of the project
  - Committed - Financial commitment amount
  - NAICS Sector - North American Industry Classification System sector
  - Project Description - Detailed description
  - Project Profile URL - Link to more information

  Data Processing

  The application:
  1. Loads the first sheet (workbook.SheetNames[0]) from the Excel file
  2. Converts it to JSON format
  3. Transforms and filters to only include rows with project names
  4. Generates tags automatically based on sector, department, region, and keywords
  5. Adds functionality for starring projects and voting/rating

  Auto-Generated Tags

  The system automatically creates tags from:
  - Sector categories: renewable energy, healthcare, education, agriculture, water & sanitation, technology, financial
  services, infrastructure
  - Geographic data: region and department information
  - Content analysis: keywords from project names and descriptions

  Data Categories

  The code shows predefined mappings for major sectors like:
  - Utilities (green energy focus)
  - Health Care (blue medical focus)
  - Educational Services (purple education focus)
  - Agriculture (yellow farming focus)
  - Finance and Insurance (orange financial focus)
  - Information/Technology (indigo tech focus)

  The application uses this data to create a project preferences and voting system where users can rate projects, filter by
  various criteria, and manage their interests in DFC-funded development projects.

