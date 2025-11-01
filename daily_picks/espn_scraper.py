"""
ESPN BPI Predictions Scraper
Fetches game predictions from ESPN's BPI predictions page
"""

import requests
from bs4 import BeautifulSoup
from datetime import datetime
import re


def fetch_espn_predictions(date_str=None):
    """
    Fetch ESPN BPI predictions for a given date

    Args:
        date_str: Date in YYYYMMDD format (e.g., '20251103')
                  If None, uses today's date

    Returns:
        List of dicts with game predictions
    """
    if date_str is None:
        date_str = datetime.now().strftime('%Y%m%d')

    url = f"https://www.espn.com/mens-college-basketball/bpi/predictions/_/date/{date_str}"

    print(f"Fetching ESPN predictions from {url}...")

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()

    soup = BeautifulSoup(response.content, 'html.parser')

    games = []

    # ESPN uses JavaScript to load data, so we need to extract from script tags
    # Look for the data in script tags
    scripts = soup.find_all('script')

    # Try to find JSON data in scripts
    for script in scripts:
        if script.string and 'predictions' in script.string:
            # Extract game data from the script
            # This is a simplified approach - ESPN's actual structure may vary
            pass

    # Alternative: Parse the rendered HTML table
    # Look for game rows in the predictions table
    game_rows = soup.find_all('tr', class_=re.compile('Table__TR'))

    for row in game_rows:
        try:
            cells = row.find_all('td')
            if len(cells) < 4:
                continue

            # Extract team names and data
            # Note: This is a template - actual parsing depends on ESPN's HTML structure
            teams_cell = cells[0] if cells else None
            prob_cell = cells[1] if len(cells) > 1 else None
            spread_cell = cells[2] if len(cells) > 2 else None

            if teams_cell:
                team_links = teams_cell.find_all('a')
                if len(team_links) >= 2:
                    away_team = team_links[0].text.strip()
                    home_team = team_links[1].text.strip()

                    # Extract probabilities
                    prob_text = prob_cell.text.strip() if prob_cell else ""
                    spread_text = spread_cell.text.strip() if spread_cell else ""

                    # Parse probability (e.g., "68.5%")
                    prob_match = re.search(r'(\d+\.?\d*)%', prob_text)
                    home_win_prob = float(prob_match.group(1)) if prob_match else None

                    # Parse spread (e.g., "4.9" or "-4.9")
                    spread_match = re.search(r'(-?\d+\.?\d*)', spread_text)
                    espn_spread = float(spread_match.group(1)) if spread_match else None

                    games.append({
                        'away_team': away_team,
                        'home_team': home_team,
                        'home_win_prob': home_win_prob,
                        'espn_spread': espn_spread,  # Positive = home favored
                        'date': date_str
                    })
        except Exception as e:
            print(f"Error parsing row: {e}")
            continue

    print(f"Found {len(games)} games from ESPN")
    return games


def normalize_team_name(team_name):
    """
    Normalize team names to match across different sources

    Args:
        team_name: Raw team name from ESPN

    Returns:
        Normalized team name
    """
    # Common normalizations
    replacements = {
        'State': 'St.',
        'St.': 'State',
        'Miami': 'Miami FL',
        'Miami (FL)': 'Miami FL',
        'UCF': 'Central Florida',
        'Central Florida': 'UCF',
        # Add more as needed based on mismatches
    }

    for old, new in replacements.items():
        if old in team_name:
            return team_name.replace(old, new)

    return team_name


if __name__ == '__main__':
    # Test the scraper
    games = fetch_espn_predictions('20251103')

    for game in games[:5]:  # Print first 5 games
        print(f"{game['away_team']} @ {game['home_team']}")
        print(f"  ESPN Spread: {game['espn_spread']}")
        print(f"  Home Win %: {game['home_win_prob']}%")
        print()
