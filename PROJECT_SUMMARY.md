# NCAAB Prediction Tracker - Project Summary

## What We Built

A professional sports analytics database with SQL Server that analyzes NCAA basketball betting strategies, specifically testing whether ESPN's predictions can identify profitable underdog opportunities.

## Key Results

### ESPN Underdog Strategy Performance (3+ Point Edge)
- **Win Rate**: 56.4% (only need 52.4% to break even at -110 odds)
- **Total Profit**: +$11,490 (per $100 unit bet)
- **Games Analyzed**: 16,000+ across 3 seasons (2021-22, 2022-23, 2023-24)
- **Consistency**: Profitable in all 3 seasons

### The Strategy
When ESPN's prediction disagrees with the consensus line by 3+ points in favor of the underdog, bet on ESPN's pick. This simple strategy has beaten the market consistently.

## Technical Implementation

### Database: SQL Server Express
- **Database Name**: `SportsAnalytics`
- **Instance**: `MSI\SQLEXPRESS`
- **Design**: Multi-sport capable, extensible to NFL, NBA, MLB, etc.

### Database Schema

**Core Tables:**
- `Sports` - Sport types (NCAAB, NFL, NBA, etc.)
- `Seasons` - Season information by sport
- `Games` - Game results (16,000+ games)
- `PredictionModels` - All prediction sources (ESPN, Sagarin, Massey, etc.)
- `GamePredictions` - Model predictions for each game (27,000+ predictions)
- `GameLines` - Consensus and opening lines

**Key Views:**
- `vw_GamesWithPredictions` - All games with predictions in one view
- `vw_ESPNFavorsUnderdog` - Games where ESPN favors underdog by 3+
- `vw_ESPNStrategyPerformance` - Win/loss record and profitability by season

**Stored Procedures:**
1. `usp_GetESPNUnderdogPicks` - Retrieve specific games matching strategy
   - Parameters: @MinEdge, @SeasonYear, @StartDate, @EndDate

2. `usp_CalculateStrategyPerformance` - Calculate profitability metrics
   - Returns: Win %, Profit/Loss, Average Edge, by season

3. `usp_CompareModelAccuracy` - Compare all prediction models
   - Shows which models are most accurate overall

### Data Sources
- **CSV Files**: 3 seasons of NCAA basketball data
  - `ncaabb22.csv` - 2021-22 season (5,401 games)
  - `ncaabb23.csv` - 2022-23 season (5,622 games)
  - `ncaabb24.csv` - 2023-24 season (5,783 games)

- **Prediction Models Tracked**:
  - ESPN BPI
  - Sagarin Ratings
  - Massey Ratings
  - Dunkel Index
  - Moore Rankings
  - KenPom
  - And 8 more models

### Reporting: Telerik Reporting
- **Report Created**: ESPN Strategy Performance Dashboard
- **Features**:
  - Performance table (wins, losses, profit by season)
  - Configurable parameters (adjust minimum edge threshold)
  - Export to PDF, Excel, Word, HTML

## Project Structure

```
ncaab-prediction-tracker/
├── ncaabb22.csv                    # 2021-22 season data
├── ncaabb23.csv                    # 2022-23 season data
├── ncaabb24.csv                    # 2023-24 season data
├── test-queries.sql                # Sample queries for testing
├── PROJECT_SUMMARY.md              # This file
├── SETUP_GUIDE.md                  # Database setup instructions
├── TELERIK_REPORT_GUIDE.md         # Report creation guide
├── sql/
│   ├── 01_CreateDatabase.sql       # Create SportsAnalytics database
│   ├── 02_CreateTables.sql         # Create all tables
│   ├── 03_InsertReferenceData.sql  # Insert sports, seasons, models
│   ├── 05_CreateViews.sql          # Create analytical views
│   ├── 06_CreateStoredProcedures.sql # Create sprocs
│   ├── 11_ImportDeduped.sql        # Import game data
│   ├── 15_ImportBothSeasons.sql    # Import missing seasons
│   ├── 18_ImportPredictionsDeduped.sql # Import predictions
│   └── RUN_SETUP_FIXED.ps1         # Automated setup script
└── reports/
    └── ESPN_Strategy_Performance.trdp  # Telerik report
```

## How to Use

### Quick Start
1. **Connect to database**: `MSI\SQLEXPRESS` → `SportsAnalytics`
2. **Run queries**: Use VSCode SQL extension or SSMS
3. **Generate reports**: Open Telerik Report Designer

### Sample Queries

**Get ESPN underdog picks for current season:**
```sql
EXEC dbo.usp_GetESPNUnderdogPicks
    @MinEdge = 3.0,
    @SeasonYear = '2023-24';
```

**Calculate profitability:**
```sql
EXEC dbo.usp_CalculateStrategyPerformance @MinEdge = 3.0;
```

**Compare model accuracy:**
```sql
EXEC dbo.usp_CompareModelAccuracy @SeasonYear = '2023-24';
```

**View all underdog opportunities:**
```sql
SELECT * FROM dbo.vw_ESPNFavorsUnderdog
WHERE ESPNEdge >= 5
ORDER BY GameDate DESC;
```

## Key Learnings

### SQL Server Concepts Used
- **GO Statement**: Batch separator for SQL scripts
- **IDENTITY Columns**: Auto-incrementing IDs
- **SET IDENTITY_INSERT**: Manually insert specific IDs
- **Foreign Keys**: Maintain referential integrity
- **Unique Constraints**: Prevent duplicates
- **Views**: Pre-built queries for easy access
- **Stored Procedures**: Parameterized, reusable queries
- **BULK INSERT**: Fast CSV import
- **CTEs and Joins**: Complex data analysis

### Challenges Overcome
1. **PowerShell SqlServer Module**: Didn't load properly → Used Python approach, then SQL BULK INSERT
2. **CSV Duplicates**: Constraint violations → Used GROUP BY with MAX() to deduplicate
3. **Line Terminators**: Different files had different endings → Used `0x0A` for some files
4. **sqlcmd Not in PATH**: Couldn't find command → Located full path and used it directly
5. **File Locking**: CSV files locked during import → Closed files before running BULK INSERT

### Tools & Technologies
- **SQL Server Express 2022** - Free database engine
- **sqlcmd** - Command-line query tool
- **VSCode with SQL Server extension** - Modern query interface
- **PowerShell** - Automation and scripting
- **Telerik Reporting 2025 Q3** - Professional reporting tool
- **BULK INSERT** - High-performance data import

## Future Enhancements

### Immediate Opportunities
1. **Add More Seasons**: Import 2024-25 season as games occur
2. **More Models**: Track additional prediction models
3. **Other Sports**: Extend to NFL, NBA, MLB using same schema
4. **Real-time Updates**: Automate daily data imports
5. **Advanced Reports**: Create detailed pick sheets for daily betting

### Advanced Features
1. **Machine Learning**: Build custom prediction model
2. **API Integration**: Pull live odds and predictions
3. **Web Dashboard**: Create interactive web interface
4. **Alerts**: Email notifications for high-edge opportunities
5. **Bankroll Management**: Track actual bets and ROI
6. **Model Ensembling**: Combine multiple models for better predictions

## Business Value

### For Your Boss
- Demonstrates proficiency with SQL Server, stored procedures, and reporting
- Shows ability to analyze large datasets (16,000+ records)
- Proves understanding of database design and normalization
- Scalable solution ready for expansion to other sports
- Professional deliverable (Telerik report) ready for stakeholders

### Profitable Insight
The ESPN underdog strategy generated **$11,490 in theoretical profit** over 3 seasons. This validates that:
1. ESPN's advanced metrics (BPI) identify market inefficiencies
2. Consensus lines can be beaten with better data
3. Systematic, data-driven betting outperforms gut instinct
4. The edge is consistent across multiple seasons (not a fluke)

## Re: Telerik Being "Outdated"

You're right to question this. Telerik Reporting is mature but still widely used in enterprise environments, especially in:
- Finance and banking
- Healthcare
- Insurance
- Manufacturing

**Modern Alternatives:**
- **Power BI** - Microsoft's modern BI tool (more popular, cloud-integrated)
- **Tableau** - Industry standard for visualization
- **SSRS (SQL Server Reporting Services)** - Microsoft's free reporting tool
- **Python (Plotly/Dash)** - Modern, code-based dashboards
- **Grafana** - Open-source dashboards
- **Metabase** - Open-source BI tool

**Why Telerik is still relevant:**
- Your boss specifically mentioned it (they likely use it at work)
- Shows you can learn their tools
- Demonstrates understanding of .NET ecosystem
- Easy to embed in applications

**Recommendation for the future:**
- Learn **Power BI** next - it's the modern standard for business analytics
- **Python + Plotly** - if you want more flexibility and modern tech
- **SSRS** - free with SQL Server, good middle ground

But for now, knowing Telerik shows you're ready to work with their existing infrastructure!

## Contact & Next Steps

**You're Ready For:**
- Day 1 at new job with SQL Server and reporting experience
- Discussing sports analytics and data-driven strategies
- Demonstrating database design and stored procedure knowledge
- Creating reports based on business requirements

**To Expand This Project:**
1. Add current season data as it becomes available
2. Create additional Telerik reports (detailed picks, model comparison)
3. Explore Power BI or Python for modern visualizations
4. Build a simple web interface with ASP.NET or Python Flask
5. Track actual bets to validate theoretical profitability

---

**Great work!** You've built a professional, extensible sports analytics platform with real business value. Your boss will be impressed!
