# Dashboard Deployment Guide

## Local Development

### 1. Install Dependencies
```bash
cd dashboard
pip install -r requirements.txt
```

### 2. Run Locally
```bash
python app.py
```

Then open browser to: http://localhost:8050

## Azure Deployment

### Prerequisites
- Azure CLI installed: `az --version`
- Azure account: `az login`

### Option 1: Quick Deploy with Azure CLI (Easiest)

```bash
cd dashboard

# Create and deploy in one command
az webapp up \
  --name espn-strategy-dashboard \
  --runtime PYTHON:3.11 \
  --sku B1 \
  --location eastus
```

That's it! Your dashboard will be at: `https://espn-strategy-dashboard.azurewebsites.net`

### Option 2: Step-by-Step Azure Portal Deployment

1. **Create App Service**:
   - Go to Azure Portal → Create Resource → Web App
   - Name: `espn-strategy-dashboard`
   - Runtime: Python 3.11
   - Region: East US
   - Plan: Basic B1 (~$13/month)

2. **Configure Database Connection**:
   - In Azure Portal → Your Web App → Configuration → Connection Strings
   - Add connection string named `SQLAZURECONNSTR_DefaultConnection`:
   ```
   DRIVER={ODBC Driver 17 for SQL Server};SERVER=your-server.database.windows.net;DATABASE=SportsAnalytics;UID=username;PWD=password
   ```

3. **Deploy Code**:

   **Option A: GitHub Actions (Recommended)**
   - Push code to GitHub
   - Azure Portal → Deployment Center → GitHub
   - Select repository
   - Azure auto-creates CI/CD pipeline

   **Option B: Local Git**
   ```bash
   az webapp deployment source config-local-git \
     --name espn-strategy-dashboard \
     --resource-group your-resource-group

   git remote add azure <deployment-url>
   git push azure main
   ```

   **Option C: ZIP Deploy**
   ```bash
   az webapp deployment source config-zip \
     --name espn-strategy-dashboard \
     --resource-group your-resource-group \
     --src dashboard.zip
   ```

### For Production: Migrate SQL Server to Azure

Your current connection uses `MSI\SQLEXPRESS` (local). For production:

1. **Create Azure SQL Database**:
   ```bash
   az sql server create \
     --name espn-strategy-sql \
     --resource-group your-rg \
     --location eastus \
     --admin-user sqladmin \
     --admin-password YourPassword123!

   az sql db create \
     --resource-group your-rg \
     --server espn-strategy-sql \
     --name SportsAnalytics \
     --service-objective S0
   ```

2. **Migrate Data**:
   - Use SQL Server Management Studio (SSMS)
   - Right-click database → Tasks → Deploy to Azure SQL
   - Or use Azure Data Migration Service

3. **Update Connection String** in app.py:
   ```python
   conn_str = (
       'DRIVER={ODBC Driver 17 for SQL Server};'
       'SERVER=espn-strategy-sql.database.windows.net;'
       'DATABASE=SportsAnalytics;'
       'UID=sqladmin;'
       'PWD=YourPassword123!;'
   )
   ```

## Dashboard Features

The dashboard includes:
- ✅ Strategy comparison (Consensus vs Opening vs Closing)
- ✅ Season dropdown filter
- ✅ Minimum edge filter (3, 5, 7 points)
- ✅ Performance by season chart
- ✅ Recent picks table with color-coded results
- ✅ Interactive Plotly charts
- ✅ Responsive design

## Next Steps: Add Conference Analysis

To add conference filtering (coming next):
1. Run SQL: `23_AddConferenceData.sql`
2. Add conference dropdown to dashboard
3. Filter by Major/Mid-Major/Minor conferences
4. Compare win rates by conference type

## Troubleshooting

### Local: "Module not found"
```bash
pip install -r requirements.txt
```

### Local: "Cannot connect to SQL Server"
- Verify SQL Server is running
- Check connection string in app.py
- Ensure ODBC Driver 17 is installed

### Azure: App won't start
- Check logs: `az webapp log tail --name espn-strategy-dashboard`
- Verify Python version matches requirements
- Check connection string configuration

### Azure: Database connection fails
- Whitelist Azure Web App IP in SQL Server firewall
- Or allow Azure services in SQL firewall settings
- Verify connection string is correct

## Cost Estimate

**Development (Local SQL Server)**:
- Free!

**Production (Azure)**:
- App Service B1: ~$13/month
- Azure SQL S0: ~$15/month
- **Total: ~$28/month**

**Free Tier Option**:
- App Service F1 (Free): Limited to 60 min/day
- Keep SQL Server local, use VPN
- Good for demo/testing only

## Security Best Practices

1. **Don't hardcode passwords** - Use Azure Key Vault or environment variables
2. **Enable HTTPS only** - Azure does this by default
3. **Restrict SQL access** - Whitelist only Azure IPs
4. **Use Managed Identity** - Let Azure handle DB authentication
5. **Enable Application Insights** - Monitor performance and errors

Ready to deploy!
