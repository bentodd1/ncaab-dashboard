-- Fix conference type classifications
-- Per user request:
-- Mid-Major should ONLY be: Mountain West, A-10, American, WCC
-- Everything else (Conference USA, MVC, etc.) should be Minor

USE SportsAnalytics;
GO

-- Update Conference USA from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 11;

-- Update Missouri Valley from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 12;

-- Update Horizon from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 13;

-- Update Summit from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 14;

-- Update Sun Belt from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 15;

-- Update WAC from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 16;

-- Update Colonial from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 17;

-- Update Southern from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 18;

-- Update MAC from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 19;

-- Update Ivy League from Mid-Major to Minor
UPDATE dbo.Conferences SET ConferenceType = 'Minor' WHERE ConferenceID = 20;

GO

-- Verify the correct distribution
SELECT
    c.ConferenceType,
    COUNT(DISTINCT c.ConferenceID) AS ConferenceCount,
    STRING_AGG(c.ConferenceName, ', ') AS Conferences
FROM dbo.Conferences c
GROUP BY c.ConferenceType
ORDER BY
    CASE c.ConferenceType
        WHEN 'Major' THEN 1
        WHEN 'Mid-Major' THEN 2
        WHEN 'Minor' THEN 3
    END;
GO

-- Verify team counts
SELECT
    c.ConferenceType,
    COUNT(DISTINCT t.TeamID) AS TeamCount
FROM dbo.Teams t
INNER JOIN dbo.Conferences c ON t.ConferenceID = c.ConferenceID
GROUP BY c.ConferenceType
ORDER BY
    CASE c.ConferenceType
        WHEN 'Major' THEN 1
        WHEN 'Mid-Major' THEN 2
        WHEN 'Minor' THEN 3
    END;
GO

PRINT 'Conference types fixed!';
PRINT 'Mid-Major now contains ONLY: Mountain West, A-10, American, WCC';
GO
