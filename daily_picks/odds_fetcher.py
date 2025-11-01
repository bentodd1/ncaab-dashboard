"""
The Odds API Fetcher
Fetches spreads from FanDuel, BetMGM, and DraftKings
"""

import requests
from datetime import datetime


def fetch_ncaab_odds(api_key, bookmakers=['fanduel', 'betmgm', 'draftkings']):
    """
    Fetch NCAAB spreads from The Odds API

    Args:
        api_key: Your Odds API key
        bookmakers: List of bookmakers to fetch (default: FanDuel, BetMGM, DraftKings)

    Returns:
        List of dicts with game odds
    """
    url = "https://api.the-odds-api.com/v4/sports/basketball_ncaab/odds"

    params = {
        'apiKey': api_key,
        'regions': 'us',
        'markets': 'spreads',
        'oddsFormat': 'american',
        'bookmakers': ','.join(bookmakers)
    }

    print(f"Fetching odds from The Odds API...")
    print(f"Bookmakers: {', '.join(bookmakers)}")

    try:
        response = requests.get(url, params=params)
        response.raise_for_status()

        data = response.json()

        # Check remaining requests
        remaining = response.headers.get('x-requests-remaining')
        used = response.headers.get('x-requests-used')
        print(f"API Requests - Used: {used}, Remaining: {remaining}")

        games = []

        for game in data:
            game_info = {
                'id': game['id'],
                'commence_time': game['commence_time'],
                'home_team': game['home_team'],
                'away_team': game['away_team'],
                'bookmakers': {}
            }

            # Extract spreads from each bookmaker
            for bookmaker in game.get('bookmakers', []):
                book_name = bookmaker['key']

                for market in bookmaker.get('markets', []):
                    if market['key'] == 'spreads':
                        # Spreads market has outcomes for each team
                        outcomes = market['outcomes']

                        # Find home and away spreads
                        home_spread = None
                        away_spread = None

                        for outcome in outcomes:
                            if outcome['name'] == game['home_team']:
                                home_spread = outcome['point']
                            elif outcome['name'] == game['away_team']:
                                away_spread = outcome['point']

                        game_info['bookmakers'][book_name] = {
                            'home_spread': home_spread,
                            'away_spread': away_spread
                        }

            games.append(game_info)

        print(f"Found {len(games)} games with odds")
        return games

    except requests.exceptions.RequestException as e:
        print(f"Error fetching odds: {e}")
        return []


def calculate_consensus_spread(game_odds):
    """
    Calculate consensus spread across all bookmakers

    Args:
        game_odds: Game dict with bookmaker spreads

    Returns:
        Average home spread across bookmakers
    """
    home_spreads = []

    for book_name, spreads in game_odds.get('bookmakers', {}).items():
        if spreads.get('home_spread') is not None:
            home_spreads.append(spreads['home_spread'])

    if not home_spreads:
        return None

    return sum(home_spreads) / len(home_spreads)


def get_best_line(game_odds, bet_side='home'):
    """
    Find the best spread for betting a particular side

    Args:
        game_odds: Game dict with bookmaker spreads
        bet_side: 'home' or 'away'

    Returns:
        Dict with best bookmaker and spread
    """
    best_book = None
    best_spread = None

    for book_name, spreads in game_odds.get('bookmakers', {}).items():
        spread_key = f'{bet_side}_spread'
        spread = spreads.get(spread_key)

        if spread is not None:
            if best_spread is None:
                best_spread = spread
                best_book = book_name
            else:
                # For favorites (negative spread), more negative is worse
                # For underdogs (positive spread), more positive is better
                if bet_side == 'home':
                    if spread > best_spread:  # Want highest spread
                        best_spread = spread
                        best_book = book_name
                else:  # away
                    if spread > best_spread:  # Want highest spread
                        best_spread = spread
                        best_book = book_name

    return {
        'bookmaker': best_book,
        'spread': best_spread
    }


def normalize_team_name(team_name):
    """
    Normalize team names to match ESPN format

    Args:
        team_name: Raw team name from Odds API

    Returns:
        Normalized team name
    """
    # Common normalizations
    replacements = {
        'State': 'St.',
        'St.': 'State',
        # Add more as needed
    }

    for old, new in replacements.items():
        if old in team_name:
            return team_name.replace(old, new)

    return team_name


if __name__ == '__main__':
    # Test the odds fetcher
    API_KEY = 'c2684e376927153aefc7aa730cca2d27'

    games = fetch_ncaab_odds(API_KEY)

    for game in games[:3]:  # Print first 3 games
        print(f"\n{game['away_team']} @ {game['home_team']}")
        print(f"Game Time: {game['commence_time']}")

        for book, spreads in game['bookmakers'].items():
            print(f"  {book}: Home {spreads['home_spread']}, Away {spreads['away_spread']}")

        consensus = calculate_consensus_spread(game)
        print(f"  Consensus: {consensus:.1f}")
