-- ============================================
-- Add Conference Classification Data
-- ============================================
USE SportsAnalytics;
GO

-- Create Conference table
IF OBJECT_ID('dbo.Conferences', 'U') IS NOT NULL
    DROP TABLE dbo.Conferences;
GO

CREATE TABLE dbo.Conferences (
    ConferenceID INT IDENTITY(1,1) PRIMARY KEY,
    ConferenceName NVARCHAR(100) NOT NULL UNIQUE,
    ConferenceType NVARCHAR(20) NOT NULL, -- 'Major', 'Mid-Major', 'Minor'
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Create Team table
IF OBJECT_ID('dbo.Teams', 'U') IS NOT NULL
    DROP TABLE dbo.Teams;
GO

CREATE TABLE dbo.Teams (
    TeamID INT IDENTITY(1,1) PRIMARY KEY,
    TeamName NVARCHAR(100) NOT NULL UNIQUE,
    ConferenceID INT NULL FOREIGN KEY REFERENCES dbo.Conferences(ConferenceID),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Insert Major Conferences (Power 6)
INSERT INTO dbo.Conferences (ConferenceName, ConferenceType) VALUES
('SEC', 'Major'),
('Big Ten', 'Major'),
('ACC', 'Major'),
('Big 12', 'Major'),
('Pac-12', 'Major'),
('Big East', 'Major');
GO

-- Insert Mid-Major Conferences
INSERT INTO dbo.Conferences (ConferenceName, ConferenceType) VALUES
('Atlantic 10', 'Mid-Major'),
('West Coast', 'Mid-Major'),
('Mountain West', 'Mid-Major'),
('American', 'Mid-Major'),
('Conference USA', 'Mid-Major'),
('Missouri Valley', 'Mid-Major'),
('Horizon', 'Mid-Major'),
('Summit', 'Mid-Major'),
('Sun Belt', 'Mid-Major'),
('WAC', 'Mid-Major'),
('Colonial', 'Mid-Major'),
('Southern', 'Mid-Major'),
('MAC', 'Mid-Major'),
('Ivy League', 'Mid-Major');
GO

-- Insert Minor/Low-Major Conferences
INSERT INTO dbo.Conferences (ConferenceName, ConferenceType) VALUES
('Big South', 'Minor'),
('Big Sky', 'Minor'),
('Big West', 'Minor'),
('ASUN', 'Minor'),
('America East', 'Minor'),
('Metro Atlantic', 'Minor'),
('Northeast', 'Minor'),
('Ohio Valley', 'Minor'),
('Patriot', 'Minor'),
('Southland', 'Minor'),
('SWAC', 'Minor'),
('MEAC', 'Minor');
GO

-- Create a view to classify games by conference type
IF OBJECT_ID('dbo.vw_GamesWithConferences', 'V') IS NOT NULL
    DROP VIEW dbo.vw_GamesWithConferences;
GO

CREATE VIEW dbo.vw_GamesWithConferences
AS
SELECT
    g.*,
    -- Try to determine conference type based on team names
    -- This is a heuristic - we'll need to manually map teams properly
    CASE
        -- Major conference teams (common examples)
        WHEN g.HomeTeam IN ('Alabama', 'Auburn', 'Kentucky', 'Tennessee', 'Arkansas', 'Florida', 'Georgia', 'LSU', 'Mississippi St.', 'Missouri', 'Ole Miss', 'South Carolina', 'Texas A&M', 'Vanderbilt') THEN 'Major'
        WHEN g.HomeTeam IN ('Illinois', 'Indiana', 'Iowa', 'Maryland', 'Michigan', 'Michigan St.', 'Minnesota', 'Nebraska', 'Northwestern', 'Ohio St.', 'Penn St.', 'Purdue', 'Rutgers', 'Wisconsin') THEN 'Major'
        WHEN g.HomeTeam IN ('Boston College', 'Clemson', 'Duke', 'Florida St.', 'Georgia Tech', 'Louisville', 'Miami-Florida', 'North Carolina', 'NC State', 'Notre Dame', 'Pittsburgh', 'Syracuse', 'Virginia', 'Virginia Tech', 'Wake Forest') THEN 'Major'
        WHEN g.HomeTeam IN ('Baylor', 'Iowa St.', 'Kansas', 'Kansas St.', 'Oklahoma', 'Oklahoma St.', 'TCU', 'Texas', 'Texas Tech', 'West Virginia') THEN 'Major'
        WHEN g.HomeTeam IN ('Arizona', 'Arizona St.', 'California', 'Colorado', 'Oregon', 'Oregon St.', 'Stanford', 'UCLA', 'USC', 'Utah', 'Washington', 'Washington St.') THEN 'Major'
        WHEN g.HomeTeam IN ('Butler', 'Creighton', 'DePaul', 'Georgetown', 'Marquette', 'Providence', 'Seton Hall', 'St. John''s', 'Villanova', 'Xavier') THEN 'Major'
        -- Add more mid-major and minor classifications as needed
        ELSE 'Unknown'
    END AS HomeConferenceType,
    CASE
        WHEN g.RoadTeam IN ('Alabama', 'Auburn', 'Kentucky', 'Tennessee', 'Arkansas', 'Florida', 'Georgia', 'LSU', 'Mississippi St.', 'Missouri', 'Ole Miss', 'South Carolina', 'Texas A&M', 'Vanderbilt') THEN 'Major'
        WHEN g.RoadTeam IN ('Illinois', 'Indiana', 'Iowa', 'Maryland', 'Michigan', 'Michigan St.', 'Minnesota', 'Nebraska', 'Northwestern', 'Ohio St.', 'Penn St.', 'Purdue', 'Rutgers', 'Wisconsin') THEN 'Major'
        WHEN g.RoadTeam IN ('Boston College', 'Clemson', 'Duke', 'Florida St.', 'Georgia Tech', 'Louisville', 'Miami-Florida', 'North Carolina', 'NC State', 'Notre Dame', 'Pittsburgh', 'Syracuse', 'Virginia', 'Virginia Tech', 'Wake Forest') THEN 'Major'
        WHEN g.RoadTeam IN ('Baylor', 'Iowa St.', 'Kansas', 'Kansas St.', 'Oklahoma', 'Oklahoma St.', 'TCU', 'Texas', 'Texas Tech', 'West Virginia') THEN 'Major'
        WHEN g.RoadTeam IN ('Arizona', 'Arizona St.', 'California', 'Colorado', 'Oregon', 'Oregon St.', 'Stanford', 'UCLA', 'USC', 'Utah', 'Washington', 'Washington St.') THEN 'Major'
        WHEN g.RoadTeam IN ('Butler', 'Creighton', 'DePaul', 'Georgetown', 'Marquette', 'Providence', 'Seton Hall', 'St. John''s', 'Villanova', 'Xavier') THEN 'Major'
        ELSE 'Unknown'
    END AS RoadConferenceType
FROM dbo.Games g
WHERE g.SportID = 1; -- NCAAB only
GO

PRINT 'Conference data structure created!';
GO
