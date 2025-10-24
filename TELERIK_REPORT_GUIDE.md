# Telerik Report Setup Guide - ESPN Underdog Strategy

## Installation
1. Download from: https://www.telerik.com/products/reporting.aspx
2. Install **Standalone Report Designer**
3. Launch **Telerik Report Designer**

## Creating Your First Report: ESPN Underdog Performance Dashboard

### Step 1: Create New Report
1. Open Telerik Report Designer
2. Click **File → New → Report**
3. Choose **Blank Report** template
4. Click **OK**

### Step 2: Connect to SQL Server
1. In the **Report Data** panel (left side), right-click **Data Sources**
2. Click **Add New Data Source**
3. Choose **SQL Data Source**
4. Click **Next**

**Connection Settings:**
- Click **Build new data connection**
- Server: `MSI\SQLEXPRESS`
- Authentication: **Windows Authentication**
- Database: `SportsAnalytics`
- Click **Test Connection** (should succeed!)
- Click **OK**

### Step 3: Create Data Source for Performance Summary

1. After connection is created, click **Next**
2. Choose **Stored Procedure**
3. Select: `dbo.usp_CalculateStrategyPerformance`
4. Click **Next**

**Add Parameters:**
- Click **Add Parameter**
- Name: `@MinEdge`
- Type: `Float`
- Default Value: `3.0`
- Click **Next**

5. Preview the data (should show your profitability stats!)
6. Click **Finish**
7. Name it: `PerformanceData`

### Step 4: Design the Report Layout

#### Add Report Title
1. From **Toolbox** (right panel), drag a **TextBox** to the top of the report
2. Double-click the textbox and type: **ESPN Underdog Strategy - Performance Report**
3. In **Properties** panel:
   - Font Size: `18pt`
   - Font Weight: `Bold`
   - Text Align: `Center`

#### Add Performance Table
1. Drag a **Table** component from Toolbox onto the report body
2. Right-click the table → **Properties**
3. Set **DataSource** to `PerformanceData`

**Configure Columns:**
- Column 1: `=Fields.Period` (Header: "Season")
- Column 2: `=Fields.TotalGames` (Header: "Games")
- Column 3: `=Fields.Wins` (Header: "Wins")
- Column 4: `=Fields.Losses` (Header: "Losses")
- Column 5: `=Fields.WinPercentage` (Header: "Win %")
  - Format: Click the cell → Properties → Format: `N2` (shows 2 decimals)
- Column 6: `=Fields.ProfitLoss_Per100Units` (Header: "Profit/Loss")
  - Format: `C0` (currency, no decimals)

**Style the Table:**
1. Click table header row
2. Properties:
   - BackgroundColor: `DarkBlue`
   - Color (text): `White`
   - Font Weight: `Bold`
3. Click data rows
4. Properties:
   - Add alternating row colors:
     - Select row → Properties → BackgroundColor: `=IIF(RowNumber() Mod 2 = 0, "LightGray", "White")`

#### Add Conditional Formatting (Highlight Profitable Seasons)
1. Click the Profit/Loss cell in the detail row
2. Properties → Conditional Formatting
3. Add rule:
   - Expression: `=Fields.ProfitLoss_Per100Units > 0`
   - Color: `Green`
   - Font Weight: `Bold`
4. Add second rule:
   - Expression: `=Fields.ProfitLoss_Per100Units < 0`
   - Color: `Red`

### Step 5: Add Chart for Visual Impact

1. Drag a **Chart** component below the table
2. Chart Wizard opens:
   - Chart Type: **Bar Chart** (horizontal bars)
   - Click **Next**

**Configure Chart:**
- DataSource: `PerformanceData`
- Categories: `=Fields.Period`
- Series 1:
  - Name: "Profit/Loss"
  - Values: `=Fields.ProfitLoss_Per100Units`
  - Color: Green
- Click **Finish**

**Chart Title:**
- Double-click chart title
- Change to: **Profitability by Season**

### Step 6: Add Parameter Panel (User Input)

1. Click **Report** → **Report Parameters**
2. Add parameter:
   - Name: `MinEdge`
   - Text: `Minimum Edge (Points)`
   - Type: `Float`
   - Default Value: `3.0`
   - Visible: `True`

This allows users to adjust the minimum edge threshold when running the report!

### Step 7: Preview and Test

1. Click **Preview** tab at bottom
2. You should see:
   - Title
   - Performance table with your data
   - Bar chart showing profit by season
3. Try changing the MinEdge parameter and click **Preview** again

### Step 8: Save the Report

1. File → **Save As**
2. Save to: `C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\reports\`
3. Name: `ESPN_Strategy_Performance.trdp`

---

## Report #2: Detailed Picks Report

Now let's create a second report showing individual game picks!

### Step 1: Create New Report
1. File → New → Report
2. Blank Report

### Step 2: Add Data Source
1. Add SQL Data Source (same connection as before)
2. Choose **Stored Procedure**: `dbo.usp_GetESPNUnderdogPicks`
3. Add parameters:
   - `@MinEdge`: Float, default `3.0`
   - `@SeasonYear`: String, default `NULL` (leave empty)
4. Name it: `PicksData`

### Step 3: Design Layout

**Title:**
- TextBox: **ESPN Underdog Picks - Detailed Report**

**Table with Picks:**
Drag a Table and configure columns:
1. `=Fields.GameDate` (Header: "Date", Format: `d` for short date)
2. `=Fields.HomeTeam + " vs " + Fields.RoadTeam` (Header: "Matchup")
3. `=Fields.ConsensusLine` (Header: "Consensus", Format: `N1`)
4. `=Fields.ESPNLine` (Header: "ESPN", Format: `N1`)
5. `=Fields.ESPNEdge` (Header: "Edge", Format: `N2`)
6. `=Fields.HomeScore + "-" + Fields.RoadScore` (Header: "Score")
7. `=Fields.CoverResult` (Header: "Result")

**Conditional Formatting:**
- CoverResult cell:
  - If `=Fields.CoverResult = "COVERED"`: Green background
  - If `=Fields.CoverResult = "MISSED"`: Red background

**Grouping by Season:**
1. Right-click table → **Insert Group** → **Parent Group**
2. Group by: `=Fields.SeasonYear`
3. Add group header with: `="Season: " + Fields.SeasonYear`

### Step 4: Add Summary Statistics

In the group footer, add textboxes:
- `="Total Games: " + Count(Fields.GameID)`
- `="Win Rate: " + (Sum(IIF(Fields.CoverResult="COVERED",1,0)) / Count(Fields.GameID) * 100).ToString("N2") + "%"`

### Step 5: Save
- File → Save As
- Name: `ESPN_Picks_Detail.trdp`

---

## Exporting Reports

Once your reports are created, you can export to:
- **PDF**: File → Export → PDF (great for presentations)
- **Excel**: File → Export → Excel (for further analysis)
- **HTML**: File → Export → HTML (web viewing)
- **Word**: File → Export → DOCX

## Next Steps for Your Boss

Show your boss:
1. **Performance Report** - Shows overall profitability (~$11k profit!)
2. **Picks Report** - Shows individual games and hit rate

**Key talking points:**
- 56.4% win rate (need only 52.4% to break even)
- Consistent profitability across 3 seasons
- Based on rigorous data analysis (16,000+ games)
- Scalable SQL database for future expansion

---

## Tips

- **Refresh Data**: When new games are added to the database, just click Preview again
- **Parameter Flexibility**: Users can adjust MinEdge to find optimal threshold
- **Scheduling**: Can set up automated report generation/emailing (ask if interested)
- **Embedding**: Reports can be embedded in .NET applications for real-time viewing

Good luck impressing your new boss!
