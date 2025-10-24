"""
Import NCAAB CSV data into SQL Server
Run: python import_data.py
"""

import csv
import pyodbc
from pathlib import Path

# Configuration
SERVER = r'MSI\SQLEXPRESS'
DATABASE = 'SportsAnalytics'
CSV_PATH = Path(r'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker')

# CSV to Season mapping
CSV_FILES = {
    'ncaabb22.csv': '2021-22',
    'ncaabb23.csv': '2022-23',
    'ncaabb24.csv': '2023-24'
}

# Column to Model mapping
COLUMN_MODEL_MAPPING = {
    'lineespn': 'ESPN',
    'linesag': 'SAGARIN',
    'linemassey': 'MASSEY',
    'linedunk': 'DUNKEL',
    'linedok': 'DOKTER',
    'linemoore': 'MOORE',
    'linepugh': 'PUGH',
    'linedonc': 'DONCHESS',
    'linetalis': 'TALIS',
    'linepir': 'PIRATINGS',
    'line7ot': 'SEVENTIMES',
    'lineer': 'EFFRATING',
    'linedd': 'DODDS',
    'linefox': 'FOX'
}

def get_connection():
    """Create database connection"""
    conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'
    return pyodbc.connect(conn_str)

def get_season_id(cursor, season_year):
    """Get SeasonID for given season year"""
    cursor.execute("SELECT SeasonID FROM dbo.Seasons WHERE SportID = 1 AND SeasonYear = ?", season_year)
    row = cursor.fetchone()
    return row[0] if row else None

def get_model_id(cursor, model_code):
    """Get ModelID for given model code"""
    cursor.execute("SELECT ModelID FROM dbo.PredictionModels WHERE ModelCode = ?", model_code)
    row = cursor.fetchone()
    return row[0] if row else None

def import_game(cursor, season_id, row):
    """Import a single game and its predictions"""
    try:
        # Parse game data
        game_date = row['date']
        home_team = row['home']
        road_team = row['road']
        home_score = int(row['hscore']) if row['hscore'] else None
        road_score = int(row['rscore']) if row['rscore'] else None
        is_neutral = 1 if row.get('neutral') == '1' else 0
        round_num = int(row['lineround']) if row.get('lineround') else None

        # Check if game already exists
        cursor.execute("""
            SELECT GameID FROM dbo.Games
            WHERE SportID = 1 AND SeasonID = ?
            AND GameDate = ? AND HomeTeam = ? AND RoadTeam = ?
        """, season_id, game_date, home_team, road_team)

        existing = cursor.fetchone()
        if existing:
            game_id = existing[0]
        else:
            # Insert game
            cursor.execute("""
                INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
                VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?)
            """, season_id, game_date, home_team, road_team, home_score, road_score, is_neutral, round_num)

            # Get the new GameID
            cursor.execute("SELECT @@IDENTITY")
            game_id = cursor.fetchone()[0]

        # Insert consensus line
        if row.get('lineavg'):
            line_avg = float(row['lineavg'])
            line_std = float(row['std']) if row.get('std') else None

            cursor.execute("""
                IF NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = ? AND LineType = 'CONSENSUS')
                BEGIN
                    INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
                    VALUES (?, 'CONSENSUS', ?, ?)
                END
            """, game_id, game_id, line_avg, line_std)

        # Insert opening line
        if row.get('lineopen'):
            line_open = float(row['lineopen'])

            cursor.execute("""
                IF NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = ? AND LineType = 'OPENING')
                BEGIN
                    INSERT INTO dbo.GameLines (GameID, LineType, Line)
                    VALUES (?, 'OPENING', ?)
                END
            """, game_id, game_id, line_open)

        # Insert predictions from various models
        pred_count = 0
        for column, model_code in COLUMN_MODEL_MAPPING.items():
            if row.get(column) and row[column]:
                try:
                    predicted_line = float(row[column])
                    model_id = get_model_id(cursor, model_code)

                    if model_id:
                        cursor.execute("""
                            IF NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = ? AND ModelID = ?)
                            BEGIN
                                INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
                                VALUES (?, ?, ?)
                            END
                        """, game_id, model_id, game_id, model_id, predicted_line)
                        pred_count += 1
                except ValueError:
                    pass  # Skip invalid numeric values

        return True, pred_count

    except Exception as e:
        print(f"    ERROR processing game {row.get('home', 'unknown')}: {e}")
        return False, 0

def main():
    print("=" * 50)
    print("Starting NCAAB Data Import")
    print("=" * 50)

    try:
        conn = get_connection()
        cursor = conn.cursor()
        print("✓ Connected to database")

        total_games = 0
        total_predictions = 0

        for csv_file, season_year in CSV_FILES.items():
            csv_path = CSV_PATH / csv_file

            if not csv_path.exists():
                print(f"\n✗ File not found: {csv_path}")
                continue

            print(f"\n[Processing {csv_file} for season {season_year}]")

            # Get season ID
            season_id = get_season_id(cursor, season_year)
            if not season_id:
                print(f"  ✗ Season not found: {season_year}")
                continue

            # Read and process CSV
            with open(csv_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                games_count = 0
                preds_count = 0

                for row in reader:
                    success, pred_count = import_game(cursor, season_id, row)
                    if success:
                        games_count += 1
                        preds_count += pred_count

                    # Commit every 100 games
                    if games_count % 100 == 0:
                        conn.commit()
                        print(f"  Progress: {games_count} games processed...")

                # Final commit for this file
                conn.commit()

                total_games += games_count
                total_predictions += preds_count

                print(f"  ✓ Imported {games_count} games and {preds_count} predictions")

        print("\n" + "=" * 50)
        print(f"✓ Import Complete!")
        print(f"  Total Games: {total_games}")
        print(f"  Total Predictions: {total_predictions}")
        print("=" * 50)

        cursor.close()
        conn.close()

    except pyodbc.Error as e:
        print(f"\n✗ Database error: {e}")
    except Exception as e:
        print(f"\n✗ Error: {e}")

if __name__ == '__main__':
    main()
