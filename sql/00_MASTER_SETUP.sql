-- MASTER SETUP SCRIPT
-- This is the definitive setup order for a fresh database deployment
-- Run this file to see the complete setup sequence

/*
ESSENTIAL SCRIPTS (in order):

1. 01_CreateDatabase.sql          - Creates SportsAnalytics database
2. 02_CreateTables.sql             - Creates all tables (Sports, Seasons, Games, etc.)
3. 03_InsertReferenceData.sql     - Inserts sports, seasons, prediction models
4. 05_CreateViews.sql              - Creates analytical views (ESPN vs Consensus, etc.)
5. 06_CreateStoredProcedures.sql  - Creates stored procedures for analysis
6. 15_ImportBothSeasons.sql        - Imports all 3 seasons of game data (FINAL VERSION)
7. 18_ImportPredictionsDeduped.sql - Imports predictions from all models (FINAL VERSION)
8. 19_CreateOpeningLineViews.sql   - Creates opening line comparison views
9. 20_CreateOpeningLineStoredProcs.sql - Creates opening line stored procedures
10. 21_ImportClosingLine.sql       - Imports closing line data
11. 22_CreateClosingLineViews.sql  - Creates closing line comparison views
12. 23_AddConferenceData.sql       - Creates Conferences and Teams tables
13. 25_UpdateTeamConferencesCorrect.sql - Maps all 350+ teams to conferences (FINAL VERSION)
14. 26_FixConferenceTypes.sql      - Fixes conference classifications (Mid-Major = 4 only)
15. 28_AddAllTeamAliases.sql       - Adds 58 team name variations from CSVs
16. 29_RecreateGamesWithConferencesView.sql - Recreates view to use Teams table

OBSOLETE/DUPLICATE SCRIPTS (safe to archive):
- 07-14: Early import attempts with various issues (duplicates, wrong terminators)
- 16-17: Early prediction import attempts
- 24: First team mapping attempt (had wrong conference IDs)
- 27: Partial alias script (28 is complete version)

NOTES:
- Scripts 07-14 were iterative attempts to solve CSV import issues
- Script 15 is the FINAL working version that handles all 3 seasons
- Script 18 is the FINAL working version for predictions
- Scripts 11-14 show the debugging process but aren't needed for fresh setup
*/

PRINT '========================================';
PRINT 'NCAA Basketball Prediction Tracker Setup';
PRINT '========================================';
PRINT '';
PRINT 'This database requires 16 scripts to set up completely.';
PRINT 'Run scripts 01-06, 15, 18-23, 25-26, 28-29 in order.';
PRINT '';
PRINT 'See sql/SETUP_GUIDE.md for detailed instructions.';
GO
