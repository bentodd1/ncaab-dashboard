-- ============================================
-- Test Queries for SportsAnalytics Database
-- ============================================
-- To connect: Use SQL Server extension
-- Server: MSI\SQLEXPRESS
-- Database: SportsAnalytics
-- Authentication: Windows Authentication

-- Test 1: Total games imported
SELECT COUNT(*) as TotalGames FROM dbo.Games;

-- Test 2: Games by season
SELECT
    s.SeasonYear,
    COUNT(*) as GameCount
FROM dbo.Games g
INNER JOIN dbo.Seasons s ON g.SeasonID = s.SeasonID
GROUP BY s.SeasonYear
ORDER BY s.SeasonYear;

-- Test 3: ESPN underdog picks with 3+ edge
EXEC dbo.usp_GetESPNUnderdogPicks @MinEdge = 3.0;

-- Test 4: Strategy performance overall
EXEC dbo.usp_CalculateStrategyPerformance @MinEdge = 3.0;

-- Test 5: See some actual strong picks (5+ edge)
SELECT TOP 20
    GameDate,
    HomeTeam,
    RoadTeam,
    ConsensusLine,
    ESPNLine,
    ESPNEdge,
    HomeScore,
    RoadScore,
    CoverResult
FROM dbo.vw_ESPNFavorsUnderdog
WHERE ESPNEdge >= 5
ORDER BY GameDate DESC;

-- Test 6: Model accuracy comparison
EXEC dbo.usp_CompareModelAccuracy;

-- Test 7: Performance by season
SELECT * FROM dbo.vw_ESPNStrategyPerformance
ORDER BY SeasonYear DESC;
