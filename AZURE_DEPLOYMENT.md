# Azure Deployment Plan

## Overview
Deploy the NCAA Basketball Prediction Tracker to Azure for:
- **Accessibility**: Access dashboard from anywhere
- **Scalability**: Handle multiple users and larger datasets
- **Automation**: Run daily data pipelines reliably
- **Cost-Effectiveness**: Pay only for what you use

---

## Architecture

### Current Local Setup
- SQL Server Express (MSI\SQLEXPRESS) on Windows PC
- Python Dash app running locally
- Manual data imports from CSV files

### Target Azure Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Azure Cloud                          │
│                                                          │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  Azure SQL DB    │◄─────┤  Azure Functions │        │
│  │  (Database)      │      │  (Daily ETL)     │        │
│  └────────┬─────────┘      └──────────────────┘        │
│           │                                              │
│           │                ┌──────────────────┐        │
│           └───────────────►│  Azure Web App   │        │
│                            │  (Dash Dashboard)│        │
│                            └──────────────────┘        │
│                                                          │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  Key Vault       │      │  Storage Account │        │
│  │  (Secrets)       │      │  (Backups/Logs)  │        │
│  └──────────────────┘      └──────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

---

## Phase 1: Azure SQL Database Migration

### 1.1 Choose Azure SQL Tier

**Options**:

| Tier | vCores | Storage | Cost/Month | Best For |
|------|--------|---------|------------|----------|
| **Basic** | Shared | 2 GB | ~$5 | Development/Testing |
| **S0 (Standard)** | 10 DTUs | 250 GB | ~$15 | Small production apps |
| **S1 (Standard)** | 20 DTUs | 250 GB | ~$30 | Medium production apps |
| **GP (General Purpose)** | 2 vCores | 32 GB | ~$200 | High performance |

**Recommendation**: Start with **S0 Standard** (~$15/month)
- Sufficient for current data size (3 seasons, ~10K games)
- Can scale up as needed
- Supports all T-SQL features you're using

### 1.2 Create Azure SQL Database

**Using Azure Portal**:
1. Navigate to Azure Portal → Create Resource → SQL Database
2. Configuration:
   - **Resource Group**: `rg-ncaab-tracker`
   - **Database Name**: `ncaab-analytics`
   - **Server**: Create new server
     - **Server Name**: `ncaab-sql-server` (must be globally unique)
     - **Location**: East US (or closest to you)
     - **Authentication**: SQL Authentication
     - **Admin Login**: `ncaabadmin`
     - **Password**: (Strong password - store in password manager)
   - **Compute + Storage**: Standard S0 (10 DTUs)
   - **Backup Storage Redundancy**: Locally-redundant backup storage
3. Networking:
   - **Allow Azure services**: Yes
   - **Add current client IP**: Yes (for initial setup)
4. Review + Create

**Using Azure CLI**:
```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-ncaab-tracker --location eastus

# Create SQL server
az sql server create \
  --name ncaab-sql-server \
  --resource-group rg-ncaab-tracker \
  --location eastus \
  --admin-user ncaabadmin \
  --admin-password 'YourStrongPassword123!'

# Create database
az sql db create \
  --resource-group rg-ncaab-tracker \
  --server ncaab-sql-server \
  --name ncaab-analytics \
  --service-objective S0 \
  --backup-storage-redundancy Local

# Configure firewall
az sql server firewall-rule create \
  --resource-group rg-ncaab-tracker \
  --server ncaab-sql-server \
  --name AllowAllAzureIps \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### 1.3 Migrate Data to Azure SQL

**Option A: Export/Import via BACPAC**

```powershell
# Export local database to BACPAC file
sqlpackage /Action:Export `
  /SourceServerName:"MSI\SQLEXPRESS" `
  /SourceDatabaseName:"SportsAnalytics" `
  /TargetFile:"C:\Temp\SportsAnalytics.bacpac"

# Import to Azure SQL Database
sqlpackage /Action:Import `
  /SourceFile:"C:\Temp\SportsAnalytics.bacpac" `
  /TargetServerName:"ncaab-sql-server.database.windows.net" `
  /TargetDatabaseName:"ncaab-analytics" `
  /TargetUser:"ncaabadmin" `
  /TargetPassword:"YourStrongPassword123!"
```

**Option B: Schema + Data Scripts**

1. Generate schema script from local SQL Server:
```sql
-- In SSMS, right-click database → Tasks → Generate Scripts
-- Select all objects (tables, views, stored procedures)
-- Save to: sql/azure_schema_export.sql
```

2. Run schema script on Azure SQL:
```bash
sqlcmd -S ncaab-sql-server.database.windows.net \
  -d ncaab-analytics \
  -U ncaabadmin \
  -P 'YourStrongPassword123!' \
  -i sql/azure_schema_export.sql
```

3. Export data using BCP:
```powershell
# Export each table
bcp SportsAnalytics.dbo.Sports out "C:\Temp\Sports.dat" -n -S "MSI\SQLEXPRESS" -T
bcp SportsAnalytics.dbo.Seasons out "C:\Temp\Seasons.dat" -n -S "MSI\SQLEXPRESS" -T
bcp SportsAnalytics.dbo.Games out "C:\Temp\Games.dat" -n -S "MSI\SQLEXPRESS" -T
bcp SportsAnalytics.dbo.Conferences out "C:\Temp\Conferences.dat" -n -S "MSI\SQLEXPRESS" -T
bcp SportsAnalytics.dbo.Teams out "C:\Temp\Teams.dat" -n -S "MSI\SQLEXPRESS" -T

# Import to Azure SQL
bcp ncaab-analytics.dbo.Sports in "C:\Temp\Sports.dat" -n -S "ncaab-sql-server.database.windows.net" -U ncaabadmin -P 'YourStrongPassword123!'
bcp ncaab-analytics.dbo.Seasons in "C:\Temp\Seasons.dat" -n -S "ncaab-sql-server.database.windows.net" -U ncaabadmin -P 'YourStrongPassword123!'
bcp ncaab-analytics.dbo.Games in "C:\Temp\Games.dat" -n -S "ncaab-sql-server.database.windows.net" -U ncaabadmin -P 'YourStrongPassword123!'
bcp ncaab-analytics.dbo.Conferences in "C:\Temp\Conferences.dat" -n -S "ncaab-sql-server.database.windows.net" -U ncaabadmin -P 'YourStrongPassword123!'
bcp ncaab-analytics.dbo.Teams in "C:\Temp\Teams.dat" -n -S "ncaab-sql-server.database.windows.net" -U ncaabadmin -P 'YourStrongPassword123!'
```

**Option C: Azure Data Studio Migration Extension** (Easiest)

1. Install Azure Data Studio
2. Install "SQL Server Schema Compare" extension
3. Connect to local SQL Server Express
4. Right-click database → Tasks → Schema Compare → Select Azure SQL as target
5. Apply schema changes
6. Right-click database → Tasks → Data Comparison → Select Azure SQL as target
7. Sync data

### 1.4 Update Connection Strings

Create environment-specific connection strings:

**Local Development** (`.env.local`):
```
DB_SERVER=MSI\SQLEXPRESS
DB_NAME=SportsAnalytics
DB_DRIVER=ODBC Driver 17 for SQL Server
DB_TRUSTED_CONNECTION=yes
```

**Azure Production** (`.env.azure`):
```
DB_SERVER=ncaab-sql-server.database.windows.net
DB_NAME=ncaab-analytics
DB_DRIVER=ODBC Driver 17 for SQL Server
DB_USER=ncaabadmin
DB_PASSWORD=YourStrongPassword123!
```

**Update Python Connection** (`dashboard/app.py`):
```python
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def get_connection():
    """Get database connection based on environment"""
    server = os.getenv('DB_SERVER')
    database = os.getenv('DB_NAME')
    driver = os.getenv('DB_DRIVER', 'ODBC Driver 17 for SQL Server')

    if os.getenv('DB_TRUSTED_CONNECTION') == 'yes':
        # Local Windows authentication
        conn_str = (
            f'DRIVER={{{driver}}};'
            f'SERVER={server};'
            f'DATABASE={database};'
            f'Trusted_Connection=yes;'
        )
    else:
        # Azure SQL authentication
        username = os.getenv('DB_USER')
        password = os.getenv('DB_PASSWORD')
        conn_str = (
            f'DRIVER={{{driver}}};'
            f'SERVER={server};'
            f'DATABASE={database};'
            f'UID={username};'
            f'PWD={password};'
        )

    return pyodbc.connect(conn_str)
```

---

## Phase 2: Deploy Dash Dashboard to Azure Web App

### 2.1 Prepare Application for Azure

**Create `requirements.txt`**:
```txt
dash==2.14.2
dash-bootstrap-components==1.5.0
plotly==5.18.0
pandas==2.1.4
pyodbc==5.0.1
gunicorn==21.2.0
python-dotenv==1.0.0
```

**Create `startup.sh`** (for Linux App Service):
```bash
#!/bin/bash
gunicorn --bind=0.0.0.0:8000 --timeout 600 dashboard.app:server
```

**Update `dashboard/app.py`** to expose Flask server:
```python
# At the bottom of app.py
server = app.server  # Expose the Flask server for gunicorn

if __name__ == '__main__':
    app.run_server(debug=True)
```

**Create `.deployment`** (deployment configuration):
```
[config]
command = bash startup.sh
```

### 2.2 Create Azure Web App

**Using Azure Portal**:
1. Navigate to Azure Portal → Create Resource → Web App
2. Configuration:
   - **Resource Group**: `rg-ncaab-tracker`
   - **Name**: `ncaab-dashboard` (will be `ncaab-dashboard.azurewebsites.net`)
   - **Publish**: Code
   - **Runtime Stack**: Python 3.11
   - **Operating System**: Linux
   - **Region**: East US
   - **App Service Plan**: Create new
     - **Name**: `asp-ncaab`
     - **Pricing Tier**: B1 Basic (~$13/month) or F1 Free (limited)
3. Deployment:
   - **GitHub Actions**: Yes (connect to your repo)
   - **Organization**: bentodd1
   - **Repository**: ncaab-dashboard
   - **Branch**: main
4. Review + Create

**Using Azure CLI**:
```bash
# Create App Service plan
az appservice plan create \
  --name asp-ncaab \
  --resource-group rg-ncaab-tracker \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group rg-ncaab-tracker \
  --plan asp-ncaab \
  --name ncaab-dashboard \
  --runtime "PYTHON:3.11"

# Configure startup command
az webapp config set \
  --resource-group rg-ncaab-tracker \
  --name ncaab-dashboard \
  --startup-file "gunicorn --bind=0.0.0.0:8000 --timeout 600 dashboard.app:server"
```

### 2.3 Configure Environment Variables

**In Azure Portal**:
1. Navigate to Web App → Configuration → Application Settings
2. Add settings:
   - `DB_SERVER`: `ncaab-sql-server.database.windows.net`
   - `DB_NAME`: `ncaab-analytics`
   - `DB_DRIVER`: `ODBC Driver 18 for SQL Server`
   - `DB_USER`: `ncaabadmin`
   - `DB_PASSWORD`: (Click "Key Vault Reference" to securely store)

**Using Azure CLI**:
```bash
az webapp config appsettings set \
  --resource-group rg-ncaab-tracker \
  --name ncaab-dashboard \
  --settings \
    DB_SERVER="ncaab-sql-server.database.windows.net" \
    DB_NAME="ncaab-analytics" \
    DB_DRIVER="ODBC Driver 18 for SQL Server" \
    DB_USER="ncaabadmin" \
    DB_PASSWORD="YourStrongPassword123!"
```

### 2.4 Deploy via GitHub Actions

Azure will auto-generate `.github/workflows/main_ncaab-dashboard.yml`:

```yaml
name: Build and deploy Python app to Azure Web App

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python version
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Create and start virtual environment
        run: |
          python -m venv venv
          source venv/bin/activate

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Upload artifact for deployment
        uses: actions/upload-artifact@v3
        with:
          name: python-app
          path: |
            .
            !venv/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'Production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v3
        with:
          name: python-app

      - name: 'Deploy to Azure Web App'
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'ncaab-dashboard'
          slot-name: 'Production'
          publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
```

**Trigger Deployment**:
```bash
# Push to main branch triggers automatic deployment
git add .
git commit -m "Configure Azure deployment"
git push origin main

# Monitor deployment
az webapp log tail --resource-group rg-ncaab-tracker --name ncaab-dashboard
```

---

## Phase 3: Automate Daily Pipeline with Azure Functions

### 3.1 Create Azure Function App

**Using Azure Portal**:
1. Navigate to Azure Portal → Create Resource → Function App
2. Configuration:
   - **Resource Group**: `rg-ncaab-tracker`
   - **Function App Name**: `ncaab-daily-etl`
   - **Publish**: Code
   - **Runtime Stack**: Python
   - **Version**: 3.11
   - **Region**: East US
   - **Operating System**: Linux
   - **Plan Type**: Consumption (Serverless) - ~$0/month for low usage
   - **Storage Account**: Create new (required for functions)
3. Review + Create

**Using Azure CLI**:
```bash
# Create storage account (required for functions)
az storage account create \
  --name ncaabstorage \
  --resource-group rg-ncaab-tracker \
  --location eastus \
  --sku Standard_LRS

# Create Function App
az functionapp create \
  --resource-group rg-ncaab-tracker \
  --consumption-plan-location eastus \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name ncaab-daily-etl \
  --storage-account ncaabstorage \
  --os-type Linux
```

### 3.2 Create Timer-Triggered Function

**Project Structure**:
```
azure-functions/
├── daily_etl/
│   ├── __init__.py          # Main function code
│   └── function.json        # Trigger configuration
├── shared/
│   ├── odds_fetcher.py      # The Odds API client
│   ├── espn_scraper.py      # ESPN BPI scraper
│   └── db_utils.py          # Database helpers
├── requirements.txt
└── host.json
```

**`daily_etl/function.json`** (Timer Trigger - runs at 6 AM ET daily):
```json
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "name": "mytimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 10 * * *"
    }
  ]
}
```
*Note: Schedule is in UTC (10 AM UTC = 6 AM ET)*

**`daily_etl/__init__.py`**:
```python
import logging
import azure.functions as func
from datetime import datetime
import os
import sys

# Add shared modules to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from shared.odds_fetcher import fetch_ncaab_odds
from shared.espn_scraper import fetch_espn_predictions
from shared.db_utils import get_azure_connection, insert_daily_data

def main(mytimer: func.TimerRequest) -> None:
    """Daily ETL function - runs at 6 AM ET"""
    utc_timestamp = datetime.utcnow().isoformat()

    if mytimer.past_due:
        logging.info('The timer is past due!')

    logging.info(f'Python timer trigger function started at {utc_timestamp}')

    try:
        # 1. Fetch odds from The Odds API
        logging.info("Fetching odds from The Odds API...")
        api_key = os.environ['ODDS_API_KEY']
        odds_data = fetch_ncaab_odds(api_key)
        logging.info(f"Fetched {len(odds_data)} games")

        # 2. Fetch ESPN predictions
        logging.info("Fetching ESPN BPI predictions...")
        espn_data = fetch_espn_predictions()
        logging.info(f"Fetched {len(espn_data)} ESPN predictions")

        # 3. Insert into Azure SQL
        logging.info("Inserting data into Azure SQL...")
        conn = get_azure_connection()
        insert_daily_data(conn, odds_data, espn_data)
        conn.close()

        logging.info('Daily ETL completed successfully!')

    except Exception as e:
        logging.error(f'Error in daily ETL: {str(e)}')
        raise
```

**`shared/db_utils.py`**:
```python
import pyodbc
import os

def get_azure_connection():
    """Connect to Azure SQL Database"""
    server = os.environ['DB_SERVER']
    database = os.environ['DB_NAME']
    username = os.environ['DB_USER']
    password = os.environ['DB_PASSWORD']

    conn_str = (
        f'DRIVER={{ODBC Driver 18 for SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'UID={username};'
        f'PWD={password};'
        f'Encrypt=yes;'
        f'TrustServerCertificate=no;'
        f'Connection Timeout=30;'
    )

    return pyodbc.connect(conn_str)

def insert_daily_data(conn, odds_data, espn_data):
    """Insert daily odds and ESPN data"""
    cursor = conn.cursor()

    # Insert odds
    for game in odds_data:
        cursor.execute("""
            INSERT INTO dbo.DailyOdds
            (GameDate, HomeTeam, RoadTeam, Sportsbook, HomeSpread, RoadSpread)
            VALUES (?, ?, ?, ?, ?, ?)
        """, game['date'], game['home_team'], game['away_team'],
             game['bookmaker'], game['home_spread'], game['away_spread'])

    # Insert ESPN predictions
    for game in espn_data:
        cursor.execute("""
            INSERT INTO dbo.DailyESPN
            (GameDate, HomeTeam, RoadTeam, ESPNHomeWinProb, ESPNImpliedSpread)
            VALUES (?, ?, ?, ?, ?)
        """, game['date'], game['home_team'], game['away_team'],
             game['home_win_prob'], game['implied_spread'])

    conn.commit()
```

**`requirements.txt`**:
```txt
azure-functions
pyodbc
requests
beautifulsoup4
pandas
```

### 3.3 Deploy Azure Function

**Using Azure Functions Core Tools**:
```bash
# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Navigate to function directory
cd azure-functions

# Initialize function app
func init --python

# Deploy to Azure
func azure functionapp publish ncaab-daily-etl
```

**Configure Function Settings**:
```bash
az functionapp config appsettings set \
  --resource-group rg-ncaab-tracker \
  --name ncaab-daily-etl \
  --settings \
    DB_SERVER="ncaab-sql-server.database.windows.net" \
    DB_NAME="ncaab-analytics" \
    DB_USER="ncaabadmin" \
    DB_PASSWORD="YourStrongPassword123!" \
    ODDS_API_KEY="your_odds_api_key_here"
```

---

## Phase 4: Security & Secrets Management

### 4.1 Create Azure Key Vault

```bash
# Create Key Vault
az keyvault create \
  --name ncaab-keyvault \
  --resource-group rg-ncaab-tracker \
  --location eastus

# Add secrets
az keyvault secret set \
  --vault-name ncaab-keyvault \
  --name "db-password" \
  --value "YourStrongPassword123!"

az keyvault secret set \
  --vault-name ncaab-keyvault \
  --name "odds-api-key" \
  --value "your_odds_api_key"
```

### 4.2 Grant Access to Web App and Functions

```bash
# Enable managed identity for Web App
az webapp identity assign \
  --resource-group rg-ncaab-tracker \
  --name ncaab-dashboard

# Enable managed identity for Function App
az functionapp identity assign \
  --resource-group rg-ncaab-tracker \
  --name ncaab-daily-etl

# Grant Key Vault access to Web App
az keyvault set-policy \
  --name ncaab-keyvault \
  --object-id <web-app-principal-id> \
  --secret-permissions get list

# Grant Key Vault access to Function App
az keyvault set-policy \
  --name ncaab-keyvault \
  --object-id <function-app-principal-id> \
  --secret-permissions get list
```

### 4.3 Reference Key Vault in App Settings

```bash
# Update Web App to use Key Vault references
az webapp config appsettings set \
  --resource-group rg-ncaab-tracker \
  --name ncaab-dashboard \
  --settings \
    DB_PASSWORD="@Microsoft.KeyVault(SecretUri=https://ncaab-keyvault.vault.azure.net/secrets/db-password/)"

# Update Function App to use Key Vault references
az functionapp config appsettings set \
  --resource-group rg-ncaab-tracker \
  --name ncaab-daily-etl \
  --settings \
    DB_PASSWORD="@Microsoft.KeyVault(SecretUri=https://ncaab-keyvault.vault.azure.net/secrets/db-password/)" \
    ODDS_API_KEY="@Microsoft.KeyVault(SecretUri=https://ncaab-keyvault.vault.azure.net/secrets/odds-api-key/)"
```

---

## Phase 5: Monitoring & Logging

### 5.1 Enable Application Insights

```bash
# Create Application Insights
az monitor app-insights component create \
  --app ncaab-insights \
  --location eastus \
  --resource-group rg-ncaab-tracker

# Connect to Web App
az monitor app-insights component connect-webapp \
  --app ncaab-insights \
  --resource-group rg-ncaab-tracker \
  --web-app ncaab-dashboard

# Connect to Function App
az monitor app-insights component connect-function \
  --app ncaab-insights \
  --resource-group rg-ncaab-tracker \
  --function ncaab-daily-etl
```

### 5.2 Set Up Alerts

**Daily ETL Failure Alert**:
```bash
az monitor metrics alert create \
  --name "Daily ETL Failed" \
  --resource-group rg-ncaab-tracker \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-ncaab-tracker/providers/Microsoft.Web/sites/ncaab-daily-etl \
  --condition "count invocations/failed > 0" \
  --window-size 1h \
  --evaluation-frequency 15m \
  --action email happynowbtodd@gmail.com
```

**Dashboard Downtime Alert**:
```bash
az monitor metrics alert create \
  --name "Dashboard Down" \
  --resource-group rg-ncaab-tracker \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-ncaab-tracker/providers/Microsoft.Web/sites/ncaab-dashboard \
  --condition "avg http server errors > 5" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action email happynowbtodd@gmail.com
```

### 5.3 View Logs

```bash
# Stream Web App logs
az webapp log tail --resource-group rg-ncaab-tracker --name ncaab-dashboard

# Stream Function App logs
az webapp log tail --resource-group rg-ncaab-tracker --name ncaab-daily-etl

# Query Application Insights
az monitor app-insights query \
  --app ncaab-insights \
  --resource-group rg-ncaab-tracker \
  --analytics-query "requests | where timestamp > ago(1d) | summarize count() by resultCode"
```

---

## Cost Breakdown

### Monthly Azure Costs (Estimated)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| **Azure SQL Database** | S0 Standard (10 DTUs) | $15 |
| **Web App (Dashboard)** | B1 Basic | $13 |
| **Function App (ETL)** | Consumption (< 1M executions) | $0 |
| **Storage Account** | Standard LRS (< 1 GB) | $0.02 |
| **Application Insights** | Basic (< 5 GB data) | Free |
| **Key Vault** | Standard | $0.03 |
| **The Odds API** | Standard Plan | $25-50 |
| **TOTAL** | | **~$53-78/month** |

### Cost Optimization Tips

1. **Use Free Tier Initially**:
   - Web App: F1 Free tier (limited to 60 min/day compute)
   - SQL Database: Can't use free tier, but S0 is cheapest

2. **Auto-Pause SQL Database**:
   - Serverless tier: Auto-pauses after 1 hour of inactivity
   - Only charged for compute when active

3. **Reserved Instances**:
   - Commit to 1-year for 30% discount on Web App

4. **Dev/Prod Separation**:
   - Use free/basic tiers for development environment
   - Only production uses standard tiers

---

## Deployment Checklist

### Pre-Deployment
- [ ] Azure subscription created
- [ ] Azure CLI installed locally
- [ ] SQL Server data exported/backed up
- [ ] Environment variables documented
- [ ] Secrets stored securely

### Phase 1: Database
- [ ] Azure SQL Database created
- [ ] Firewall rules configured
- [ ] Schema migrated
- [ ] Data migrated
- [ ] Views and stored procedures deployed
- [ ] Connection tested from local machine

### Phase 2: Dashboard
- [ ] `requirements.txt` created
- [ ] `startup.sh` configured
- [ ] `.env` files set up
- [ ] Azure Web App created
- [ ] Environment variables configured
- [ ] GitHub Actions workflow set up
- [ ] Code deployed
- [ ] Dashboard accessible at `https://ncaab-dashboard.azurewebsites.net`

### Phase 3: Automation
- [ ] The Odds API account created
- [ ] Azure Function App created
- [ ] Timer trigger configured (6 AM ET daily)
- [ ] Odds fetcher implemented
- [ ] ESPN scraper implemented
- [ ] Function deployed
- [ ] Manual test run successful

### Phase 4: Security
- [ ] Azure Key Vault created
- [ ] Secrets migrated to Key Vault
- [ ] Managed identities enabled
- [ ] Key Vault permissions granted
- [ ] App settings updated to reference Key Vault

### Phase 5: Monitoring
- [ ] Application Insights enabled
- [ ] Alerts configured
- [ ] Log streaming tested
- [ ] Dashboard metrics visible

---

## Post-Deployment Tasks

### Week 1: Validation
- [ ] Monitor daily ETL runs
- [ ] Verify data accuracy
- [ ] Check dashboard performance
- [ ] Review cost usage

### Week 2: Optimization
- [ ] Tune SQL queries if slow
- [ ] Optimize Function App memory
- [ ] Review Application Insights for errors
- [ ] Adjust alert thresholds

### Month 1: Enhancements
- [ ] Add Today's Picks tab to dashboard
- [ ] Implement email notifications
- [ ] Set up automated backups
- [ ] Create staging environment

---

## Rollback Plan

If deployment fails or issues arise:

1. **Database Rollback**:
   - Azure SQL has point-in-time restore (7-35 days)
   - Local SQL Server backup still available

2. **App Rollback**:
   - GitHub Actions: Deploy previous commit
   - Azure Portal: Swap deployment slots

3. **Complete Rollback**:
   - Delete Azure resources
   - Continue using local setup
   - No data loss (local copy remains)

---

## Alternative: Docker + Azure Container Apps

If you prefer containerization:

**Dockerfile**:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY dashboard/ ./dashboard/

EXPOSE 8000

CMD ["gunicorn", "--bind=0.0.0.0:8000", "--timeout", "600", "dashboard.app:server"]
```

**Deploy to Azure Container Apps**:
```bash
az containerapp create \
  --name ncaab-dashboard \
  --resource-group rg-ncaab-tracker \
  --image yourdockerhub/ncaab-dashboard:latest \
  --environment ncaab-env \
  --ingress external \
  --target-port 8000
```

---

## Next Steps

1. **Choose Deployment Approach**:
   - Standard Web App (recommended for simplicity)
   - Container Apps (if you prefer Docker)

2. **Create Azure Account**:
   - Sign up at portal.azure.com
   - $200 free credit for 30 days
   - Free tier services available

3. **Test Migration**:
   - Start with database migration
   - Verify data integrity
   - Test connections

4. **Deploy Dashboard**:
   - Connect GitHub repo
   - Configure environment variables
   - Deploy via GitHub Actions

5. **Build Automation**:
   - Implement after manual workflow validated
   - Start with Option 3 from AUTOMATION_ROADMAP.md

Let me know which phase you'd like to tackle first!
