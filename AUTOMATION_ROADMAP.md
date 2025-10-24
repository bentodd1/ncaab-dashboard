# Automation Roadmap: Daily Picks Pipeline

## Current State (Option 1 - Manual)
- Historical data in SQL Server (2021-2024 seasons)
- Dashboard with strategy filters and analysis
- Manual morning workflow: Check smartbet.name → Identify edges → Place bets

## Future State (Option 3 - Automated Pipeline)
Automatically fetch daily ESPN BPI + sportsbook lines, calculate edges, and surface picks that match proven strategies.

---

## Phase 1: Data Source Setup

### 1.1 Odds API Integration
**Goal**: Get real-time sportsbook lines for NCAAB games

**Options**:
- [The Odds API](https://the-odds-api.com/) - $10-50/month
  - Supports: DraftKings, FanDuel, BetMGM, Caesars, etc.
  - 500-10,000 requests/month depending on tier
  - Real-time spreads, moneylines, totals
- [Odds Jam API](https://oddsjam.com/api) - Alternative option
- [RapidAPI Sports Odds](https://rapidapi.com/theoddsapi/api/live-sports-odds) - Alternative option

**Implementation**:
```python
# odds_fetcher.py
import requests
from datetime import date

def fetch_ncaab_odds(api_key):
    """Fetch today's NCAAB spreads from The Odds API"""
    url = "https://api.the-odds-api.com/v4/sports/basketball_ncaab/odds"
    params = {
        'apiKey': api_key,
        'regions': 'us',
        'markets': 'spreads',
        'oddsFormat': 'american',
        'dateFormat': 'iso'
    }
    response = requests.get(url, params=params)
    return response.json()
```

**Database Schema**:
```sql
CREATE TABLE dbo.DailyOdds (
    OddsID INT IDENTITY(1,1) PRIMARY KEY,
    GameDate DATE NOT NULL,
    HomeTeam NVARCHAR(100) NOT NULL,
    RoadTeam NVARCHAR(100) NOT NULL,
    Sportsbook NVARCHAR(50) NOT NULL,
    HomeSpread DECIMAL(4,1),
    RoadSpread DECIMAL(4,1),
    LastUpdate DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.ConsensusLines (
    ConsensusID INT IDENTITY(1,1) PRIMARY KEY,
    GameDate DATE NOT NULL,
    HomeTeam NVARCHAR(100) NOT NULL,
    RoadTeam NVARCHAR(100) NOT NULL,
    ConsensusSpread DECIMAL(4,1), -- Average across sportsbooks
    CalculatedAt DATETIME DEFAULT GETDATE()
);
```

### 1.2 ESPN BPI Data Collection
**Goal**: Get daily ESPN FPI win probabilities and implied spreads

**Options**:
- **ESPN Stats Page Scraping**:
  - URL: `https://www.espn.com/mens-college-basketball/bpi`
  - Contains team ratings and projected records
  - May need to calculate spreads from ratings
- **ESPN Scoreboard Scraping**:
  - URL: `https://www.espn.com/mens-college-basketball/scoreboard`
  - Shows game predictions when available
- **ESPN Hidden API** (if discoverable):
  - Inspect network traffic on ESPN pages
  - May have JSON endpoints for BPI data

**Implementation**:
```python
# espn_scraper.py
from bs4 import BeautifulSoup
import requests

def fetch_espn_bpi():
    """Scrape ESPN BPI ratings and game predictions"""
    url = "https://www.espn.com/mens-college-basketball/bpi"
    # TODO: Implement scraping logic
    # May need Selenium if JavaScript-heavy
    pass

def fetch_espn_scoreboard(date):
    """Get today's games with ESPN predictions"""
    url = f"https://www.espn.com/mens-college-basketball/scoreboard/_/date/{date}"
    # TODO: Implement scraping logic
    pass
```

**Database Schema**:
```sql
CREATE TABLE dbo.DailyESPN (
    ESPNID INT IDENTITY(1,1) PRIMARY KEY,
    GameDate DATE NOT NULL,
    HomeTeam NVARCHAR(100) NOT NULL,
    RoadTeam NVARCHAR(100) NOT NULL,
    ESPNHomeWinProb DECIMAL(5,2), -- e.g., 65.5%
    ESPNImpliedSpread DECIMAL(4,1), -- Calculated from win prob
    FetchedAt DATETIME DEFAULT GETDATE()
);
```

---

## Phase 2: Daily ETL Pipeline

### 2.1 Data Collection Script
**Goal**: Run daily (early morning) to fetch all data before games start

**Schedule**:
- Run at 6:00 AM ET daily (before most game times)
- Use Windows Task Scheduler or Python scheduler library

**Script Structure**:
```python
# daily_update.py
import pyodbc
from datetime import date
from odds_fetcher import fetch_ncaab_odds
from espn_scraper import fetch_espn_bpi, fetch_espn_scoreboard

def daily_data_pipeline():
    """Main ETL pipeline for daily picks"""

    # 1. Fetch odds from API
    print(f"Fetching odds for {date.today()}...")
    odds_data = fetch_ncaab_odds(api_key=YOUR_API_KEY)

    # 2. Fetch ESPN BPI data
    print("Fetching ESPN BPI data...")
    espn_data = fetch_espn_scoreboard(date.today())

    # 3. Connect to SQL Server
    conn = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=MSI\\SQLEXPRESS;'
        'DATABASE=SportsAnalytics;'
        'Trusted_Connection=yes;'
    )

    # 4. Insert odds data
    insert_odds(conn, odds_data)

    # 5. Calculate consensus lines
    calculate_consensus(conn, date.today())

    # 6. Insert ESPN data
    insert_espn(conn, espn_data)

    # 7. Calculate edges and identify picks
    picks = calculate_daily_picks(conn, date.today())

    # 8. Send notification
    send_picks_notification(picks)

    conn.close()
    print("Daily pipeline complete!")

if __name__ == "__main__":
    daily_data_pipeline()
```

### 2.2 Edge Calculation
**Goal**: Match ESPN lines with consensus/closing lines to find edges

**Stored Procedure**:
```sql
CREATE PROCEDURE dbo.sp_CalculateDailyEdges
    @GameDate DATE
AS
BEGIN
    -- Calculate edges for today's games
    SELECT
        e.GameDate,
        e.HomeTeam,
        e.RoadTeam,
        c.ConsensusSpread AS ClosingLine,
        e.ESPNImpliedSpread AS ESPNLine,
        (c.ConsensusSpread - e.ESPNImpliedSpread) AS ESPNEdge,
        ABS(c.ConsensusSpread - e.ESPNImpliedSpread) AS EdgeMagnitude,
        -- Determine direction
        CASE
            WHEN (c.ConsensusSpread - e.ESPNImpliedSpread) > 0 THEN 'UNDERDOG'
            WHEN (c.ConsensusSpread - e.ESPNImpliedSpread) < 0 THEN 'FAVORITE'
            ELSE 'NONE'
        END AS ESPNFavors,
        -- Get conference info
        ht.ConferenceType AS HomeConferenceType,
        rt.ConferenceType AS RoadConferenceType
    FROM dbo.DailyESPN e
    INNER JOIN dbo.ConsensusLines c ON
        e.GameDate = c.GameDate AND
        e.HomeTeam = c.HomeTeam AND
        e.RoadTeam = c.RoadTeam
    LEFT JOIN dbo.Teams ht ON e.HomeTeam = ht.TeamName
    LEFT JOIN dbo.Teams rt ON e.RoadTeam = rt.TeamName
    WHERE e.GameDate = @GameDate;
END;
```

---

## Phase 3: Strategy Filtering & Alerts

### 3.1 Strategy Engine
**Goal**: Apply monthly strategies to daily edges

**Implementation**:
```python
# strategy_engine.py
from datetime import date

STRATEGIES = {
    11: [  # November
        {
            'name': 'Minor Underdog',
            'conference': 'Minor',
            'min_edge': 4,
            'direction': 'UNDERDOG'
        },
        {
            'name': 'All Favorites',
            'conference': 'ALL',
            'min_edge': 3,
            'direction': 'FAVORITE'
        }
    ],
    12: [  # December
        {
            'name': 'Mid-Major Both',
            'conference': 'Mid-Major',
            'min_edge': 3,
            'direction': 'BOTH'
        },
        {
            'name': 'Minor Both',
            'conference': 'Minor',
            'min_edge': 3,
            'direction': 'BOTH'
        }
    ],
    1: [],   # January - AVOID
    2: [],   # February - AVOID
    3: [  # March
        {
            'name': 'All Underdogs',
            'conference': 'ALL',
            'min_edge': 4,
            'direction': 'UNDERDOG'
        }
    ]
}

def get_todays_strategy():
    """Get applicable strategies for current month"""
    current_month = date.today().month
    return STRATEGIES.get(current_month, [])

def filter_picks_by_strategy(edges_df, strategies):
    """Filter daily edges by strategy rules"""
    picks = []

    for strategy in strategies:
        filtered = edges_df[
            (edges_df['EdgeMagnitude'] >= strategy['min_edge']) &
            (
                (strategy['conference'] == 'ALL') |
                (edges_df['HomeConferenceType'] == strategy['conference'])
            )
        ]

        if strategy['direction'] == 'UNDERDOG':
            filtered = filtered[filtered['ESPNFavors'] == 'UNDERDOG']
        elif strategy['direction'] == 'FAVORITE':
            filtered = filtered[filtered['ESPNFavors'] == 'FAVORITE']

        for _, row in filtered.iterrows():
            picks.append({
                'strategy': strategy['name'],
                'game': f"{row['RoadTeam']} @ {row['HomeTeam']}",
                'edge': row['EdgeMagnitude'],
                'espn_line': row['ESPNLine'],
                'closing_line': row['ClosingLine'],
                'recommendation': get_bet_recommendation(row, strategy)
            })

    return picks

def get_bet_recommendation(game, strategy):
    """Generate human-readable bet recommendation"""
    if strategy['direction'] == 'UNDERDOG':
        # ESPN favors underdog, so bet the dog
        if game['ClosingLine'] > 0:
            return f"Bet {game['RoadTeam']} +{game['ClosingLine']}"
        else:
            return f"Bet {game['HomeTeam']} +{abs(game['ClosingLine'])}"
    elif strategy['direction'] == 'FAVORITE':
        # ESPN favors favorite, so bet the favorite
        if game['ClosingLine'] > 0:
            return f"Bet {game['HomeTeam']} -{game['ClosingLine']}"
        else:
            return f"Bet {game['RoadTeam']} -{abs(game['ClosingLine'])}"
    else:
        return "Review both sides"
```

### 3.2 Notification System
**Goal**: Deliver picks via email/SMS/dashboard

**Email Option**:
```python
# notifications.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_picks_email(picks, recipient="happynowbtodd@gmail.com"):
    """Send daily picks via email"""

    if not picks:
        print("No picks today - skipping email")
        return

    # Format email body
    body = f"""
    <h2>NCAA Basketball Picks for {date.today().strftime('%A, %B %d, %Y')}</h2>
    <p>Found {len(picks)} games matching your strategies:</p>
    <table border="1" cellpadding="5">
        <tr>
            <th>Strategy</th>
            <th>Game</th>
            <th>Edge</th>
            <th>ESPN Line</th>
            <th>Closing Line</th>
            <th>Recommendation</th>
        </tr>
    """

    for pick in picks:
        body += f"""
        <tr>
            <td>{pick['strategy']}</td>
            <td>{pick['game']}</td>
            <td>{pick['edge']:.1f}</td>
            <td>{pick['espn_line']:.1f}</td>
            <td>{pick['closing_line']:.1f}</td>
            <td><strong>{pick['recommendation']}</strong></td>
        </tr>
        """

    body += "</table>"

    # Send email
    msg = MIMEMultipart('alternative')
    msg['Subject'] = f"🏀 {len(picks)} Picks Today - {date.today().strftime('%m/%d')}"
    msg['From'] = "your_email@gmail.com"
    msg['To'] = recipient

    msg.attach(MIMEText(body, 'html'))

    # TODO: Configure SMTP settings
    # with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
    #     server.login("your_email@gmail.com", "your_app_password")
    #     server.send_message(msg)

    print(f"Email sent with {len(picks)} picks")
```

**Dashboard Option**:
Add a new "Today's Picks" page to the Dash app:
```python
# In dashboard/app.py
@app.callback(
    Output('todays-picks-table', 'children'),
    Input('refresh-button', 'n_clicks')
)
def update_todays_picks(n_clicks):
    """Show today's filtered picks in dashboard"""
    conn = get_connection()

    query = """
    EXEC dbo.sp_CalculateDailyEdges @GameDate = CAST(GETDATE() AS DATE)
    """

    df = pd.read_sql(query, conn)
    conn.close()

    # Apply strategy filters
    strategies = get_todays_strategy()
    picks = filter_picks_by_strategy(df, strategies)

    # Return table
    return create_picks_table(picks)
```

---

## Phase 4: Dashboard Enhancements

### 4.1 "Today's Picks" Tab
**Features**:
- Live view of games matching today's strategies
- Refresh button to update odds
- Link to sportsbooks
- Confidence indicator based on historical win rate

### 4.2 "Strategy Performance" Real-Time Updates
**Features**:
- Track picks made each day
- Update win/loss as games complete
- Season-to-date ROI tracking
- Compare actual results vs historical backtesting

### 4.3 Alerts & Thresholds
**Features**:
- Set minimum edge thresholds
- Filter by specific sportsbooks
- Line movement tracking (alert when edge appears/disappears)

---

## Implementation Timeline

### Week 1: Research & Setup
- [ ] Sign up for The Odds API (or alternative)
- [ ] Test API endpoints and understand data format
- [ ] Research ESPN BPI scraping feasibility
- [ ] Create new database tables (DailyOdds, ConsensusLines, DailyESPN)

### Week 2: Data Collection
- [ ] Build odds_fetcher.py
- [ ] Build espn_scraper.py
- [ ] Test data insertion into SQL Server
- [ ] Create sp_CalculateDailyEdges stored procedure

### Week 3: Strategy Engine
- [ ] Build strategy_engine.py with monthly rules
- [ ] Test filtering logic against historical data
- [ ] Validate recommendations match expected bets

### Week 4: Automation & Notifications
- [ ] Create daily_update.py pipeline script
- [ ] Set up Windows Task Scheduler job
- [ ] Implement email notifications
- [ ] Add "Today's Picks" tab to dashboard

### Week 5: Testing & Refinement
- [ ] Run pipeline for 1 week, verify data quality
- [ ] Compare automated picks to manual smartbet.name review
- [ ] Adjust thresholds and filters as needed
- [ ] Document any edge cases or issues

---

## Cost Estimate

| Item | Monthly Cost |
|------|--------------|
| The Odds API (Standard Plan) | $25-50 |
| Total | **$25-50/month** |

**Break-even**: Need to profit ~$50/month to cover API costs
- At $100/bet and 56% win rate: ~13 bets/month to break even
- Your strategies show +$11,490 over 3 seasons, averaging ~$320/month

---

## Risks & Mitigation

### Risk: ESPN stops publishing BPI data
**Mitigation**: Build flexibility to swap in alternative models (KenPom, Sagarin, Bart Torvik)

### Risk: API costs exceed budget
**Mitigation**: Start with lowest tier, monitor usage, optimize request frequency

### Risk: Team name mismatches between sources
**Mitigation**: Expand TeamAliases table, build fuzzy matching logic

### Risk: Line movement between fetch and bet placement
**Mitigation**: Fetch odds multiple times per day, alert on significant movement

### Risk: Strategies stop working (market efficiency)
**Mitigation**: Continuously backtest, adjust filters, develop new strategies

---

## Success Metrics

### Technical Metrics
- [ ] Pipeline runs successfully 7 days/week
- [ ] Data freshness: Odds fetched within 1 hour of game time
- [ ] Accuracy: 95%+ team name match rate
- [ ] Uptime: 99%+ pipeline reliability

### Business Metrics
- [ ] Picks generated match manual review 90%+ of time
- [ ] Time saved: Reduce morning research from 30min to 5min
- [ ] ROI: Maintain 52.4%+ win rate on automated picks
- [ ] Profit: Cover API costs + generate net positive returns

---

## Future Enhancements

### Machine Learning Integration
- Train model on historical edges to predict likelihood of cover
- Feature engineering: Time of season, rest days, home/road records
- Ensemble predictions combining ESPN + ML model

### Live Betting Integration
- Track in-game line movements
- Alert on live betting opportunities
- Compare pre-game edge to live edge

### Portfolio Management
- Bankroll tracking
- Kelly Criterion bet sizing
- Variance analysis and risk management

### Multi-Sport Expansion
- Apply same methodology to NFL, NBA, NCAAF
- Unified dashboard across all sports
- Cross-sport arbitrage opportunities

---

## Questions to Resolve

1. **Odds API Selection**: Which service has best NCAAB coverage and pricing?
2. **ESPN Data Source**: Can we find a reliable JSON endpoint or must we scrape HTML?
3. **Notification Preference**: Email, SMS, dashboard, or combination?
4. **Bet Tracking**: Do you want to log actual bets placed and track real P&L?
5. **Line Shopping**: Should we fetch from multiple sportsbooks and recommend best line?

---

## Next Steps

When ready to start Phase 1:
1. Create free trial account for The Odds API
2. Test fetching NCAAB spreads for upcoming games
3. Investigate ESPN BPI data availability
4. Build proof-of-concept script to fetch + store one day's data
