-- Recreate vw_GamesWithConferences to use the Teams and Conferences tables
-- instead of hardcoded CASE statements

USE SportsAnalytics;
GO

-- Drop the old view
DROP VIEW IF EXISTS dbo.vw_GamesWithConferences;
GO

-- Create new view that properly joins to Teams and Conferences tables
CREATE VIEW dbo.vw_GamesWithConferences AS
SELECT
    g.*,
    ht.TeamID AS HomeTeamID,
    rt.TeamID AS RoadTeamID,
    hc.ConferenceID AS HomeConferenceID,
    rc.ConferenceID AS RoadConferenceID,
    hc.ConferenceName AS HomeConferenceName,
    rc.ConferenceName AS RoadConferenceName,
    COALESCE(hc.ConferenceType, 'Unknown') AS HomeConferenceType,
    COALESCE(rc.ConferenceType, 'Unknown') AS RoadConferenceType
FROM dbo.Games g
LEFT JOIN dbo.Teams ht ON g.HomeTeam = ht.TeamName
LEFT JOIN dbo.Teams rt ON g.RoadTeam = rt.TeamName
LEFT JOIN dbo.Conferences hc ON ht.ConferenceID = hc.ConferenceID
LEFT JOIN dbo.Conferences rc ON rt.ConferenceID = rc.ConferenceID;
GO

PRINT 'View vw_GamesWithConferences recreated successfully!';
PRINT 'Now uses Teams and Conferences tables for accurate mappings.';
GO

-- Test the new view
SELECT
    HomeConferenceType,
    COUNT(*) AS GameCount
FROM dbo.vw_GamesWithConferences
WHERE SportID = 1
GROUP BY HomeConferenceType
ORDER BY GameCount DESC;
GO

-- Test with ESPN picks
SELECT
    c.HomeConferenceType,
    COUNT(*) AS ESPNPickCount
FROM dbo.vw_ESPNFavorsUnderdog v
INNER JOIN dbo.vw_GamesWithConferences c ON v.GameID = c.GameID
WHERE ABS(v.ESPNEdge) >= 3
GROUP BY c.HomeConferenceType
ORDER BY ESPNPickCount DESC;
GO
