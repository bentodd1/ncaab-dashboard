# Sports Analytics Database Setup Guide

## Prerequisites
- SQL Server Express installed (✓ You have this!)
- SQL Server Management Studio (SSMS) - Optional but recommended
- PowerShell with SqlServer module

## Step-by-Step Setup

### 1. Create the Database
Open Command Prompt and run:
```cmd
sqlcmd -S MSI\SQLEXPRESS -E -i "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql\01_CreateDatabase.sql"
```

### 2. Create Tables
```cmd
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql\02_CreateTables.sql"
```

### 3. Insert Reference Data
```cmd
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql\03_InsertReferenceData.sql"
```

### 4. Import CSV Data
Open PowerShell as Administrator and run:
```powershell
# First, install SQL Server module if needed
Install-Module -Name SqlServer -AllowClobber -Force

# Then run the import script
cd "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql"
.\04_ImportNCAABData.ps1
```

### 5. Create Views
```cmd
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql\05_CreateViews.sql"
```

### 6. Create Stored Procedures
```cmd
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql\06_CreateStoredProcedures.sql"
```

## Quick Run All (PowerShell)
```powershell
cd "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql"

# Run all SQL scripts in order
sqlcmd -S MSI\SQLEXPRESS -E -i .\01_CreateDatabase.sql
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i .\02_CreateTables.sql
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i .\03_InsertReferenceData.sql
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i .\05_CreateViews.sql
sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i .\06_CreateStoredProcedures.sql

# Import data
.\04_ImportNCAABData.ps1
```

## Testing the Database

### View ESPN Underdog Picks (3+ point edge)
```sql
-- Get all ESPN underdog picks with 3+ edge
EXEC dbo.usp_GetESPNUnderdogPicks @MinEdge = 3.0;

-- Get only 2023-24 season
EXEC dbo.usp_GetESPNUnderdogPicks @MinEdge = 3.0, @SeasonYear = '2023-24';

-- Get picks from a specific date range
EXEC dbo.usp_GetESPNUnderdogPicks
    @MinEdge = 3.0,
    @StartDate = '2024-01-01',
    @EndDate = '2024-03-31';
```

### Check Strategy Performance
```sql
-- Overall performance
EXEC dbo.usp_CalculateStrategyPerformance @MinEdge = 3.0;

-- Performance for specific season
EXEC dbo.usp_CalculateStrategyPerformance @MinEdge = 3.0, @SeasonYear = '2023-24';
```

### Compare All Models
```sql
-- See which prediction model is most accurate
EXEC dbo.usp_CompareModelAccuracy;

-- For a specific season
EXEC dbo.usp_CompareModelAccuracy @SeasonYear = '2023-24';
```

### Query Views Directly
```sql
-- See all ESPN underdog opportunities
SELECT * FROM dbo.vw_ESPNFavorsUnderdog
WHERE ESPNEdge >= 3
ORDER BY GameDate DESC;

-- Performance summary by season
SELECT * FROM dbo.vw_ESPNStrategyPerformance
ORDER BY SeasonYear DESC;

-- All games with predictions
SELECT TOP 100 * FROM dbo.vw_GamesWithPredictions
ORDER BY GameDate DESC;
```

## Understanding the Data

### Positive vs Negative Lines
- **Positive Line**: Home team is favored (e.g., +7 means home team favored by 7)
- **Negative Line**: Road team is favored (e.g., -5 means road team favored by 5)

### Your ESPN Underdog Strategy
The strategy looks for games where:
1. The consensus (average of all models) has a favorite
2. ESPN disagrees by 3+ points, favoring the underdog

**Example:**
- Consensus Line: +8 (Home team favored by 8)
- ESPN Line: -5 (ESPN thinks Road team should be favored by 5)
- ESPN Edge: 13 points (8 - (-5) = 13)
- Strategy: Bet on the Road team (ESPN's pick)

### Key Tables
- **Games**: All game results
- **GamePredictions**: Each model's prediction for each game
- **GameLines**: Consensus, opening, and closing lines
- **PredictionModels**: List of all prediction models (ESPN, Sagarin, etc.)

### Key Views
- **vw_ESPNFavorsUnderdog**: Games where ESPN disagrees with consensus by 3+
- **vw_ESPNStrategyPerformance**: Win/loss record by season
- **vw_GamesWithPredictions**: All games with all their predictions in one view

### Stored Procedures Explained

#### 1. usp_GetESPNUnderdogPicks
**What it does**: Retrieves games where ESPN favors the underdog

**Parameters**:
- `@MinEdge` (default 3.0): Minimum point difference between consensus and ESPN
- `@SeasonYear`: Filter to specific season (NULL = all)
- `@StartDate` / `@EndDate`: Date range filter
- `@IncludePending`: Include games not yet played (1 = yes, 0 = no)

**Example**: "Show me all games where ESPN disagreed by 5+ points in 2023-24"
```sql
EXEC usp_GetESPNUnderdogPicks @MinEdge = 5.0, @SeasonYear = '2023-24'
```

#### 2. usp_CalculateStrategyPerformance
**What it does**: Calculates profitability metrics for the ESPN underdog strategy

**Returns**:
- Overall performance across all filtered games
- Per-season breakdown

**Metrics**:
- Win/Loss record and percentage
- Profit/Loss assuming $100 bets at -110 odds
- Average, min, and max ESPN edge

**Example**: "How profitable is a 3-point minimum edge strategy?"
```sql
EXEC usp_CalculateStrategyPerformance @MinEdge = 3.0
```

#### 3. usp_CompareModelAccuracy
**What it does**: Compares all prediction models to see which is most accurate

**Returns**:
- Winner prediction accuracy (who wins the game)
- Cover accuracy (who covers the spread)
- Average error and prediction stats

**Example**: "Which model is best at predicting spreads?"
```sql
EXEC usp_CompareModelAccuracy
-- Results ordered by CoverAccuracy (best to worst)
```

## Next Steps: Telerik Reporting

### 1. Install Telerik Reporting
1. Download free version: https://www.telerik.com/products/reporting.aspx
2. During install, select "Standalone Report Designer"
3. Launch Telerik Report Designer

### 2. Connect to Your Database
1. Open Report Designer
2. Click **Data** → **Add New Data Source**
3. Select **SQL Data Source**
4. Configure connection:
   - **Server**: `MSI\SQLEXPRESS`
   - **Authentication**: Windows Authentication
   - **Database**: `SportsAnalytics`
5. Test connection - should succeed!

### 3. Create Your First Report: ESPN Underdog Picks

#### Report #1: Daily Picks Report
1. **Data Source**: Use stored procedure `usp_GetESPNUnderdogPicks`
2. **Add Parameters**:
   - `MinEdge` (Number, default: 3.0)
   - `SeasonYear` (Dropdown with: NULL, '2021-22', '2022-23', '2023-24')
   - `StartDate` (Date picker)
   - `EndDate` (Date picker)
3. **Layout**:
   - Title: "ESPN Underdog Betting Opportunities"
   - Table/Grid showing:
     - Game Date
     - Matchup (Home vs Road)
     - Consensus Line
     - ESPN Line
     - ESPN Edge
     - Result (if completed)
     - Cover Result
4. **Styling**:
   - Highlight rows where `ESPNEdge >= 5` (strong picks)
   - Color code `CoverResult`: Green = Covered, Red = Missed

#### Report #2: Strategy Performance Dashboard
1. **Data Source**: Use stored procedure `usp_CalculateStrategyPerformance`
2. **Add Parameter**: `MinEdge` (Number, default: 3.0)
3. **Layout**:
   - Title: "ESPN Strategy Performance Analysis"
   - Top section: Overall stats
     - Win Percentage (large font)
     - Profit/Loss
     - Total Games
   - Bottom section: Table by season
     - Season
     - Games
     - W-L Record
     - Win %
     - P/L
4. **Add Chart**:
   - Bar chart showing profit/loss by season
   - Line chart showing win percentage trend

#### Report #3: Model Comparison Report
1. **Data Source**: Use stored procedure `usp_CompareModelAccuracy`
2. **Add Parameter**: `SeasonYear` (optional filter)
3. **Layout**:
   - Title: "Prediction Model Accuracy Comparison"
   - Sorted table showing all models
   - Columns:
     - Model Name
     - Total Predictions
     - Cover Accuracy % (main metric)
     - Winner Accuracy %
     - Average Error
4. **Add Chart**:
   - Horizontal bar chart comparing Cover Accuracy
   - Highlight ESPN's position

### 4. Report Designer Tips
- Use **Table Wizard** for quick layouts
- Add **conditional formatting** for wins/losses
- Use **chart wizard** for visualizations
- Save reports as `.trdp` files
- Export to PDF, Excel, or HTML

### 5. Advanced: Embedding in Applications
Once comfortable with reports, you can:
- Embed in .NET applications (WinForms, WPF, ASP.NET)
- Schedule reports to run automatically
- Email reports on game days
- Create mobile-friendly HTML reports

## Troubleshooting

### PowerShell SqlServer Module Won't Install
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name SqlServer -AllowClobber -Force
```

### Can't Connect to SQL Server
- Verify service is running: Windows Services → SQL Server (SQLEXPRESS)
- Confirm instance name: `MSI\SQLEXPRESS`
- Check Windows Firewall isn't blocking

### CSV Import Fails
- Check file paths in PowerShell script
- Verify CSV files are in the correct directory
- Check for data formatting issues (dates, numbers)

### No Data in Reports
- Run test queries in sqlcmd first
- Check that CSV import completed successfully
- Verify views and sprocs return data:
  ```sql
  SELECT COUNT(*) FROM dbo.Games;
  SELECT COUNT(*) FROM dbo.GamePredictions;
  ```

## What You've Built

You now have:
- ✅ Professional sports analytics database
- ✅ Extensible to multiple sports
- ✅ Historical NCAAB data (2022-2024)
- ✅ Multiple prediction models
- ✅ Pre-built views for analysis
- ✅ Stored procedures for reporting
- ✅ Foundation for Telerik reports
- ✅ Profitability analysis tools

Ready to impress your new boss!
