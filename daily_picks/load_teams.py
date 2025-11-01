"""
Load teams database from SQL Server
Creates a mapping of team names to conference types
"""

import pyodbc
import json


def load_teams_from_db():
    """
    Load teams and conference types from SQL Server

    Returns:
        Dict mapping team names to conference types
    """
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=MSI\\SQLEXPRESS;'
            'DATABASE=SportsAnalytics;'
            'Trusted_Connection=yes;'
        )

        query = """
        SELECT DISTINCT
            t.TeamName,
            c.ConferenceType
        FROM dbo.Teams t
        INNER JOIN dbo.Conferences c ON t.ConferenceID = c.ConferenceID
        ORDER BY t.TeamName
        """

        cursor = conn.cursor()
        cursor.execute(query)

        teams_db = {}
        for row in cursor.fetchall():
            team_name = row[0]
            conf_type = row[1]
            teams_db[team_name] = conf_type

        conn.close()

        print(f"Loaded {len(teams_db)} teams from database")
        print(f"  Major: {sum(1 for v in teams_db.values() if v == 'Major')}")
        print(f"  Mid-Major: {sum(1 for v in teams_db.values() if v == 'Mid-Major')}")
        print(f"  Minor: {sum(1 for v in teams_db.values() if v == 'Minor')}")

        return teams_db

    except Exception as e:
        print(f"Error loading teams from database: {e}")
        print("Using fallback team list...")
        return get_fallback_teams()


def get_fallback_teams():
    """
    Fallback team list if database connection fails
    Returns a dict with common teams
    """
    return {
        # Major conferences (Power 6)
        'Duke': 'Major', 'North Carolina': 'Major', 'Kansas': 'Major',
        'Kentucky': 'Major', 'Arizona': 'Major', 'UCLA': 'Major',
        'Gonzaga': 'Major', 'Villanova': 'Major', 'Michigan': 'Major',
        'Tennessee': 'Major', 'Auburn': 'Major', 'Alabama': 'Major',
        'Houston': 'Major', 'Texas': 'Major', 'Purdue': 'Major',
        'Wisconsin': 'Major', 'Illinois': 'Major', 'Indiana': 'Major',
        'Michigan St.': 'Major', 'Ohio St.': 'Major',

        # Mid-Major conferences (Mountain West, A-10, American, WCC)
        'San Diego State': 'Mid-Major', 'Nevada': 'Mid-Major',
        'Boise State': 'Mid-Major', 'Colorado State': 'Mid-Major',
        'VCU': 'Mid-Major', 'Dayton': 'Mid-Major', 'Richmond': 'Mid-Major',
        'Saint Mary\'s': 'Mid-Major', 'BYU': 'Mid-Major',
        'Memphis': 'Mid-Major', 'SMU': 'Mid-Major', 'Temple': 'Mid-Major',

        # Minor conferences (all others)
        'Vermont': 'Minor', 'Colgate': 'Minor', 'Furman': 'Minor',
        'Charleston': 'Minor', 'Oral Roberts': 'Minor',
    }


def save_teams_cache(teams_db, filename='teams_cache.json'):
    """
    Save teams database to JSON file for faster loading

    Args:
        teams_db: Dict of teams
        filename: Output filename
    """
    with open(filename, 'w') as f:
        json.dump(teams_db, f, indent=2)
    print(f"Saved teams cache to {filename}")


def load_teams_cache(filename='teams_cache.json'):
    """
    Load teams database from JSON cache

    Args:
        filename: Cache filename

    Returns:
        Dict of teams or None if file doesn't exist
    """
    try:
        with open(filename, 'r') as f:
            teams_db = json.load(f)
        print(f"Loaded {len(teams_db)} teams from cache")
        return teams_db
    except FileNotFoundError:
        return None


if __name__ == '__main__':
    # Load from database and save cache
    teams_db = load_teams_from_db()
    save_teams_cache(teams_db)

    # Print sample teams
    print("\nSample teams:")
    for i, (team, conf) in enumerate(list(teams_db.items())[:20]):
        print(f"  {team}: {conf}")
        if i >= 19:
            break
