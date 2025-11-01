# Daily Picks Generator

Automatically generate daily NCAA basketball betting recommendations based on ESPN BPI predictions and your proven strategies.

## Quick Start

### Install Dependencies
```bash
pip install -r requirements.txt
```

### Generate Today's Picks
```bash
python generate_picks.py
```

This will create `daily_picks.csv` with all games matching your monthly strategies.

### Generate Picks for Specific Date
```bash
python generate_picks.py 20251103
```

### Custom Output Filename
```bash
python generate_picks.py 20251103 my_picks.csv
```

## What It Does

1. **Fetches ESPN BPI Predictions** - Gets ESPN's predicted spreads from their BPI predictions page
2. **Fetches Sportsbook Odds** - Gets current spreads from FanDuel, BetMGM, and DraftKings via The Odds API
3. **Calculates Edges** - Compares ESPN's line to consensus bookmaker line
4. **Applies Strategies** - Filters games based on your monthly strategies:
   - **November**: Minor +4 Underdog, All +3 Favorite
   - **December**: Mid-Major/Minor +3 Both directions
   - **January/February**: AVOID (no strategies)
   - **March**: All +4 Underdog
5. **Generates CSV** - Creates spreadsheet with recommendations and explanations

## CSV Columns

- **Game** - Matchup (Away @ Home)
- **Game Time** - Scheduled start time
- **ESPN Spread** - ESPN's predicted spread
- **FanDuel/BetMGM/DraftKings** - Current spreads at each book
- **Consensus** - Average spread across all three books
- **Edge** - ESPN edge (Consensus - ESPN)
- **Recommendation** - Which team to bet and why
- **Best Line** - Which book has the best spread for your bet
- **Strategy** - Which strategy matched this game
- **Why** - Detailed explanation of the strategy

## Configuration

### API Key
Edit `generate_picks.py` and update:
```python
ODDS_API_KEY = 'your_api_key_here'
```

### Bookmakers
To add/change bookmakers, edit:
```python
BOOKMAKERS = ['fanduel', 'betmgm', 'draftkings']
```

Available bookmakers: `fanduel`, `betmgm`, `draftkings`, `pointsbetus`, `bovada`, `mybookieag`, `betus`, `betonlineag`

### Strategies
Strategies are defined in `strategy_engine.py`. To modify:
1. Edit the `STRATEGIES` dict with your monthly rules
2. Each strategy needs:
   - `name`: Strategy name
   - `conference`: 'Major', 'Mid-Major', 'Minor', or 'ALL'
   - `min_edge`: Minimum edge in points
   - `direction`: 'UNDERDOG', 'FAVORITE', or 'BOTH'
   - `description`: Why this strategy works

## Files

- **generate_picks.py** - Main script that orchestrates everything
- **espn_scraper.py** - Fetches ESPN BPI predictions
- **odds_fetcher.py** - Fetches odds from The Odds API
- **strategy_engine.py** - Applies your betting strategies
- **load_teams.py** - Loads conference classifications from database
- **teams_cache.json** - Cached team/conference mappings (auto-generated)

## Troubleshooting

### "No picks found"
- Check that it's not January/February (avoid months)
- Verify games meet minimum edge requirements
- Try lowering min_edge in strategies

### "Error fetching ESPN predictions"
- ESPN may have changed their HTML structure
- Check the URL format at ESPN's BPI predictions page
- May need to update the scraper

### "Error fetching odds"
- Verify your Odds API key is correct
- Check remaining API requests (shown in output)
- Ensure bookmakers are available for NCAAB

### "Team not found in database"
- Run `python load_teams.py` to refresh team cache
- Add missing teams to your SQL Server Teams table
- Or add to fallback list in `load_teams.py`

## Examples

### Output Sample
```
=== Generating Daily Picks for 20251103 ===

Step 1: Loading teams database...
Loaded 361 teams from cache

Step 2: Fetching ESPN BPI predictions...
Found 47 games from ESPN

Step 3: Fetching odds from bookmakers...
API Requests - Used: 1, Remaining: 499
Found 45 games with odds

Step 4: Matching ESPN predictions with odds...
Matched 43 games

Step 5: Applying betting strategies...
Current month: November (using November strategies)
Found 3 picks matching strategies

Step 6: Generating CSV...
CSV generated: daily_picks.csv
Total picks: 3

=== Summary ===

Vermont @ Duke
  Strategy: November Minor Underdog
  Bet Vermont +28.5 (ESPN favors underdog with 4.2 pt edge)
  Minor conference underdog with 4+ point ESPN edge
```

### CSV Sample
```
Game,Game Time,ESPN Spread,FanDuel,BetMGM,DraftKings,Consensus,Edge,Recommendation,Best Line,Strategy,Why
Vermont @ Duke,07:00 PM ET,+24.3,+28.5,+28.0,+29.0,+28.5,4.2,Bet Vermont +28.5,DraftKings: +29.0,November Minor Underdog,Minor conference underdog with 4+ point ESPN edge
```

## Daily Workflow

1. Run the script each morning before games start
2. Review the CSV for picks
3. Check best lines at each sportsbook
4. Place bets based on recommendations
5. Track results to validate strategies

## Future Enhancements

- Email/SMS notifications when picks are found
- Automatic bet placement via sportsbook APIs
- Live line monitoring and alerts
- Results tracking and P&L calculation
- Strategy backtesting against historical results
