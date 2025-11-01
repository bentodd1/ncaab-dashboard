"""
Daily Picks Generator
Main script to generate CSV of betting recommendations
"""

import csv
import sys
from datetime import datetime
from pathlib import Path

# Add daily_picks to path
sys.path.append(str(Path(__file__).parent))

from espn_scraper import fetch_espn_predictions
from odds_fetcher import fetch_ncaab_odds, calculate_consensus_spread, get_best_line
from strategy_engine import apply_strategies, calculate_edge
from load_teams import load_teams_from_db, load_teams_cache, save_teams_cache


# Your Odds API Key
ODDS_API_KEY = 'c2684e376927153aefc7aa730cca2d27'

# Bookmakers to check
BOOKMAKERS = ['fanduel', 'betmgm', 'draftkings']


def normalize_team_name(team_name):
    """Normalize team names for matching between sources"""
    # Remove common suffixes
    team_name = team_name.replace(' St.', ' State')
    team_name = team_name.replace(' St', ' State')

    # Common aliases
    aliases = {
        'Miami (FL)': 'Miami FL',
        'Miami-Florida': 'Miami FL',
        'Central Florida': 'UCF',
        'CS Sacramento': 'Sacramento St.',
        'CS Bakersfield': 'Cal St. Bakersfield',
        'Middle Tenn St.': 'Middle Tennessee St.',
        'UT Rio Grande Valley': 'UTRGV',
        'SE Louisiana': 'Southeastern Louisiana',
        'FGCU': 'Florida Gulf Coast',
    }

    return aliases.get(team_name, team_name)


def match_espn_to_odds(espn_games, odds_games):
    """
    Match ESPN predictions with odds data

    Args:
        espn_games: List of ESPN game dicts
        odds_games: List of odds game dicts

    Returns:
        List of matched game dicts
    """
    matched_games = []

    for espn_game in espn_games:
        espn_home = normalize_team_name(espn_game['home_team'])
        espn_away = normalize_team_name(espn_game['away_team'])

        # Try to find matching odds game
        for odds_game in odds_games:
            odds_home = normalize_team_name(odds_game['home_team'])
            odds_away = normalize_team_name(odds_game['away_team'])

            # Check if teams match (either exact or fuzzy)
            home_match = (espn_home == odds_home or
                         espn_home in odds_home or
                         odds_home in espn_home)
            away_match = (espn_away == odds_away or
                         espn_away in odds_away or
                         odds_away in espn_away)

            if home_match and away_match:
                # Calculate consensus spread
                consensus = calculate_consensus_spread(odds_game)

                # Get best lines for each side
                best_home = get_best_line(odds_game, 'home')
                best_away = get_best_line(odds_game, 'away')

                matched_game = {
                    'home_team': espn_game['home_team'],
                    'away_team': espn_game['away_team'],
                    'espn_spread': espn_game.get('espn_spread'),
                    'consensus_spread': consensus,
                    'commence_time': odds_game.get('commence_time'),
                    'bookmakers': odds_game.get('bookmakers', {}),
                    'best_home_line': best_home,
                    'best_away_line': best_away,
                }

                matched_games.append(matched_game)
                break  # Found match, move to next ESPN game

    return matched_games


def generate_csv(picks, output_filename='daily_picks.csv'):
    """
    Generate CSV file with betting recommendations

    Args:
        picks: List of pick dicts
        output_filename: Output CSV filename
    """
    if not picks:
        print("No picks found matching current strategies!")
        return

    # Define CSV columns
    fieldnames = [
        'Game',
        'Game Time',
        'ESPN Spread',
        'FanDuel',
        'BetMGM',
        'DraftKings',
        'Consensus',
        'Edge',
        'Recommendation',
        'Best Line',
        'Strategy',
        'Why'
    ]

    with open(output_filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for pick in picks:
            # Format game time
            game_time = pick.get('commence_time', '')
            if game_time:
                try:
                    dt = datetime.fromisoformat(game_time.replace('Z', '+00:00'))
                    game_time = dt.strftime('%I:%M %p ET')
                except:
                    pass

            # Format bookmaker spreads
            bookmakers = pick.get('bookmakers', {})
            fanduel = bookmakers.get('fanduel', {}).get('home_spread', 'N/A')
            betmgm = bookmakers.get('betmgm', {}).get('home_spread', 'N/A')
            draftkings = bookmakers.get('draftkings', {}).get('home_spread', 'N/A')

            # Format spreads
            if fanduel != 'N/A':
                fanduel = f"{fanduel:+.1f}"
            if betmgm != 'N/A':
                betmgm = f"{betmgm:+.1f}"
            if draftkings != 'N/A':
                draftkings = f"{draftkings:+.1f}"

            # Determine which side to bet and best line
            edge_direction = pick.get('edge_direction')
            if edge_direction == 'UNDERDOG':
                best_line_info = pick.get('best_away_line', {})
            else:
                best_line_info = pick.get('best_home_line', {})

            best_book = best_line_info.get('bookmaker', 'N/A')
            best_spread = best_line_info.get('spread', 'N/A')
            if best_spread != 'N/A':
                best_spread = f"{best_spread:+.1f}"

            best_line = f"{best_book}: {best_spread}" if best_book != 'N/A' else 'N/A'

            row = {
                'Game': f"{pick['away_team']} @ {pick['home_team']}",
                'Game Time': game_time,
                'ESPN Spread': f"{pick.get('espn_spread', 'N/A'):+.1f}" if pick.get('espn_spread') else 'N/A',
                'FanDuel': fanduel,
                'BetMGM': betmgm,
                'DraftKings': draftkings,
                'Consensus': f"{pick.get('consensus_spread', 'N/A'):+.1f}" if pick.get('consensus_spread') else 'N/A',
                'Edge': f"{pick.get('edge', 0):.1f}",
                'Recommendation': pick.get('bet_recommendation', ''),
                'Best Line': best_line,
                'Strategy': pick.get('strategy_name', ''),
                'Why': pick.get('strategy_description', '')
            }

            writer.writerow(row)

    print(f"\nCSV generated: {output_filename}")
    print(f"Total picks: {len(picks)}")


def main(date_str=None, output_filename='daily_picks.csv'):
    """
    Main function to generate daily picks

    Args:
        date_str: Date in YYYYMMDD format (e.g., '20251103'), defaults to today
        output_filename: Output CSV filename
    """
    if date_str is None:
        date_str = datetime.now().strftime('%Y%m%d')

    print(f"=== Generating Daily Picks for {date_str} ===\n")

    # 1. Load teams database
    print("Step 1: Loading teams database...")
    teams_db = load_teams_cache()
    if teams_db is None:
        teams_db = load_teams_from_db()
        save_teams_cache(teams_db)
    print()

    # 2. Fetch ESPN predictions
    print("Step 2: Fetching ESPN BPI predictions...")
    espn_games = fetch_espn_predictions(date_str)
    print(f"Found {len(espn_games)} games from ESPN\n")

    # 3. Fetch odds from bookmakers
    print("Step 3: Fetching odds from bookmakers...")
    odds_games = fetch_ncaab_odds(ODDS_API_KEY, BOOKMAKERS)
    print(f"Found {len(odds_games)} games with odds\n")

    # 4. Match ESPN to odds
    print("Step 4: Matching ESPN predictions with odds...")
    matched_games = match_espn_to_odds(espn_games, odds_games)
    print(f"Matched {len(matched_games)} games\n")

    # 5. Apply strategies
    print("Step 5: Applying betting strategies...")
    current_month = datetime.now().month
    month_name = datetime.now().strftime('%B')
    print(f"Current month: {month_name} (using {month_name} strategies)")

    all_picks = []

    for game in matched_games:
        # Calculate edge
        edge = calculate_edge(game.get('espn_spread'), game.get('consensus_spread'))

        if edge is None:
            continue

        # Apply strategies
        matches = apply_strategies(game, teams_db, current_month)

        # Add matched strategies to picks
        for match in matches:
            pick = {**game, **match}  # Merge game data with strategy match
            all_picks.append(pick)

    print(f"Found {len(all_picks)} picks matching strategies\n")

    # 6. Generate CSV
    print("Step 6: Generating CSV...")
    generate_csv(all_picks, output_filename)

    # Print summary
    if all_picks:
        print("\n=== Summary ===")
        for pick in all_picks:
            print(f"\n{pick['away_team']} @ {pick['home_team']}")
            print(f"  Strategy: {pick['strategy_name']}")
            print(f"  {pick['bet_recommendation']}")
            print(f"  {pick['strategy_description']}")
    else:
        print("\n=== No Picks Today ===")
        print("No games match the current month's strategies.")
        print(f"Check {output_filename} for details.")


if __name__ == '__main__':
    import sys

    # Parse command line arguments
    date_str = None
    output_file = 'daily_picks.csv'

    if len(sys.argv) > 1:
        date_str = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]

    main(date_str, output_file)
