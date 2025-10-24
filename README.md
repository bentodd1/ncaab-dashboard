# NCAA Basketball Prediction Tracker

An interactive dashboard for analyzing ESPN's NCAA basketball prediction strategy, built with Python Dash and SQL Server.

## Overview

This project analyzes a betting strategy: **When ESPN significantly disagrees with consensus predictions, favoring the underdog by 3+ points, should you bet on ESPN's pick?**

The dashboard tracks performance across:
- 3 seasons of NCAA basketball data (2021-22, 2022-23, 2023-24)
- ~16,000 games with predictions from ESPN, Sagarin, Massey, and other models
- Major, Mid-Major, and Minor conference classifications

## Key Findings

**ESPN vs Consensus Model Strategy:**
- 56.4% win rate
- +$11,490 profit (betting $100 per game)
- Most profitable strategy tested

**ESPN vs Opening Line:**
- 52.5% win rate
- +$520 profit (marginal)

**ESPN vs Closing Line:**
- 51.7% win rate
- -$3,350 loss (unprofitable - market efficiency)

## Features

### Interactive Dashboard
- **Season Filter**: Analyze specific seasons or all data combined
- **Minimum Edge Filter**: Filter by disagreement threshold (3, 5, or 7 points)
- **Conference Type Filter**: Compare performance across Major, Mid-Major, and Minor conferences
- **Strategy Comparison**: Visual comparison of ESPN vs Consensus/Opening Line/Closing Line
- **Performance by Season**: Track profitability and win rates over time
- **Conference Analysis**: Compare win rates by conference type
- **Recent Picks Table**: Color-coded results (green=covered, red=missed)

### Database Features
- Multi-sport capable design (NCAAB, NFL, NBA, etc.)
- Comprehensive views and stored procedures for analysis
- Team-to-conference mappings with 350+ D1 basketball teams
- Conference classifications: Major (Power 6), Mid-Major (MW, A-10, AAC, WCC), Minor (all others)

## Technology Stack

- **Backend**: SQL Server Express
- **Frontend**: Python Dash with Plotly
- **Database**: T-SQL (Views, Stored Procedures)
- **Deployment**: Azure-ready (App Service + Azure SQL)

## Project Structure

```
ncaab-prediction-tracker/
├── dashboard/
│   ├── app.py                    # Main Dash application
│   ├── requirements.txt          # Python dependencies
│   └── DEPLOYMENT_GUIDE.md       # Azure deployment instructions
├── sql/
│   ├── 01_CreateDatabase.sql     # Database creation
│   ├── 02_CreateTables.sql       # Schema definition
│   ├── 03_InsertReferenceData.sql # Sports, seasons, models
│   ├── 05_CreateViews.sql        # Analytical views
│   ├── 06_CreateStoredProcedures.sql # Analysis procedures
│   ├── 11-23_Import*.sql         # Data import scripts
│   ├── 25-29_Conference*.sql     # Conference classification
│   └── RUN_SETUP_FIXED.ps1       # Automated setup script
├── docs/
│   ├── PROJECT_SUMMARY.md        # Comprehensive documentation
│   ├── SETUP_GUIDE.md            # Step-by-step setup
│   └── TELERIK_REPORT_GUIDE.md   # Telerik reporting (legacy)
├── ncaabb22.csv                  # 2021-22 season data
├── ncaabb23.csv                  # 2022-23 season data
├── ncaabb24.csv                  # 2023-24 season data
└── README.md                     # This file
```

## Quick Start

### Prerequisites

- Windows with SQL Server Express installed
- Python 3.9+ with pip
- PowerShell

### 1. Database Setup

```powershell
# Run the automated setup script
.\sql\RUN_SETUP_FIXED.ps1
```

Or manually execute SQL scripts in order (01-29).

### 2. Dashboard Setup

```powershell
# Create Python virtual environment
python -m venv venv
.\venv\Scripts\activate

# Install dependencies
cd dashboard
pip install -r requirements.txt

# Run the dashboard
python app.py
```

Navigate to http://localhost:8050

## Database Schema

### Core Tables

- **Sports**: Multi-sport support (NCAAB, NFL, NBA, etc.)
- **Seasons**: Season definitions (2021-22, 2022-23, etc.)
- **Games**: Game results with scores and metadata
- **PredictionModels**: ESPN, Sagarin, Massey, etc.
- **GamePredictions**: Model predictions for each game
- **GameLines**: Opening and closing betting lines
- **Conferences**: Conference definitions with type classification
- **Teams**: Team-to-conference mappings

### Key Views

- **vw_GamesWithPredictions**: Games joined with all predictions
- **vw_ESPNFavorsUnderdog**: Games where ESPN disagrees by 3+ points
- **vw_ESPNvsOpeningLine**: ESPN vs opening betting line
- **vw_ESPNvsClosingLine**: ESPN vs closing betting line
- **vw_GamesWithConferences**: Games with conference classifications

### Stored Procedures

- **usp_GetESPNUnderdogPicks**: Retrieve ESPN underdog picks with filters
- **usp_CalculateStrategyPerformance**: Calculate win rates and profitability
- **usp_CompareModelAccuracy**: Compare all prediction models

## Conference Classifications

**Major Conferences (Power 6):**
- SEC, Big Ten, Big 12, ACC, Big East, Pac-12

**Mid-Major Conferences:**
- Mountain West, Atlantic 10, American Athletic, West Coast Conference

**Minor Conferences:**
- All other D1 conferences (22 conferences total)

## Data Files

CSV files contain the following columns:
- `date`: Game date
- `home`, `road`: Team names
- `hscore`, `rscore`: Final scores
- `neutral`: Neutral site indicator
- `espn`, `massey`, `sagarin`, etc.: Model predictions (positive = home favored)
- `line`: Closing betting line
- `open`: Opening betting line

## Development Notes

### SQL Server Specifics

- `GO` statements are batch separators (required for SSMS/sqlcmd)
- `SET IDENTITY_INSERT` allows manual insertion into auto-increment columns
- Stored procedures use `@Parameter` syntax for inputs
- Views are virtual tables computed on-the-fly

### Python Dash Structure

- `app.py` contains all layout and callback definitions
- Callbacks respond to dropdown changes and update charts/tables
- `pyodbc` connects to SQL Server using trusted authentication
- Plotly creates interactive charts with dual-axis support

### Known Issues

- Team name variations between CSV files required alias mappings (58 variations handled)
- Telerik Reporting had XML schema issues (switched to Dash instead)
- Conference realignment means some historical mappings may be approximate

## Deployment

### Local Development
Currently configured for local SQL Server (`MSI\SQLEXPRESS`)

### Azure Deployment
See [dashboard/DEPLOYMENT_GUIDE.md](dashboard/DEPLOYMENT_GUIDE.md) for:
- Azure App Service setup
- SQL Server to Azure SQL migration
- Environment variable configuration
- Cost estimates (~$28/month for production)

## Future Enhancements

- [ ] Add more sports (NFL, NBA)
- [ ] Real-time data ingestion
- [ ] Machine learning model training
- [ ] User authentication and saved filters
- [ ] Email alerts for high-value picks
- [ ] Mobile-responsive design improvements
- [ ] Export functionality (PDF reports, CSV downloads)

## Business Value

This project demonstrates:
- **Data Engineering**: Complex ETL, data cleaning, schema design
- **Analytics**: Statistical analysis, profitability calculations
- **Visualization**: Interactive dashboards with multiple filter dimensions
- **SQL Proficiency**: Views, stored procedures, joins, aggregations
- **Full-Stack Development**: Backend (SQL) + Frontend (Python/Dash)
- **Cloud Readiness**: Azure deployment capability

## License

MIT License - feel free to use for learning or commercial purposes.

## Acknowledgments

- Data sourced from prediction tracker CSV files (2021-2024)
- Built as a learning project for SQL Server, T-SQL, and Dash
- Inspired by sports analytics and betting strategy research

## Contact

For questions or collaboration opportunities, please open an issue on GitHub.

---

**Disclaimer**: This project is for educational and analytical purposes only. Sports betting involves risk. Past performance does not guarantee future results.
