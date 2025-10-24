-- ============================================
-- Create Tables for Sports Analytics Database
-- ============================================
-- Run this from sqlcmd: sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i 02_CreateTables.sql

USE SportsAnalytics;
GO

-- ============================================
-- Sports Reference Table
-- ============================================
IF OBJECT_ID('dbo.Sports', 'U') IS NOT NULL
    DROP TABLE dbo.Sports;
GO

CREATE TABLE dbo.Sports (
    SportID INT IDENTITY(1,1) PRIMARY KEY,
    SportName NVARCHAR(50) NOT NULL UNIQUE,
    SportCode NVARCHAR(10) NOT NULL UNIQUE,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Seasons Reference Table
-- ============================================
IF OBJECT_ID('dbo.Seasons', 'U') IS NOT NULL
    DROP TABLE dbo.Seasons;
GO

CREATE TABLE dbo.Seasons (
    SeasonID INT IDENTITY(1,1) PRIMARY KEY,
    SportID INT NOT NULL FOREIGN KEY REFERENCES dbo.Sports(SportID),
    SeasonYear NVARCHAR(20) NOT NULL, -- e.g., '2023-24', '2024'
    StartDate DATE,
    EndDate DATE,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Sport_Season UNIQUE (SportID, SeasonYear)
);
GO

-- ============================================
-- Prediction Models Reference Table
-- ============================================
IF OBJECT_ID('dbo.PredictionModels', 'U') IS NOT NULL
    DROP TABLE dbo.PredictionModels;
GO

CREATE TABLE dbo.PredictionModels (
    ModelID INT IDENTITY(1,1) PRIMARY KEY,
    ModelName NVARCHAR(100) NOT NULL UNIQUE,
    ModelCode NVARCHAR(50) NOT NULL UNIQUE, -- e.g., 'ESPN', 'SAGARIN', 'KENPOM'
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Main Games Table
-- ============================================
IF OBJECT_ID('dbo.Games', 'U') IS NOT NULL
    DROP TABLE dbo.Games;
GO

CREATE TABLE dbo.Games (
    GameID INT IDENTITY(1,1) PRIMARY KEY,
    SportID INT NOT NULL FOREIGN KEY REFERENCES dbo.Sports(SportID),
    SeasonID INT NOT NULL FOREIGN KEY REFERENCES dbo.Seasons(SeasonID),
    GameDate DATE NOT NULL,
    HomeTeam NVARCHAR(100) NOT NULL,
    RoadTeam NVARCHAR(100) NOT NULL,
    HomeScore INT,
    RoadScore INT,
    IsNeutralSite BIT DEFAULT 0,
    RoundNumber INT NULL, -- for tournament games
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Game UNIQUE (SportID, SeasonID, GameDate, HomeTeam, RoadTeam)
);
GO

CREATE INDEX IX_Games_GameDate ON dbo.Games(GameDate);
CREATE INDEX IX_Games_HomeTeam ON dbo.Games(HomeTeam);
CREATE INDEX IX_Games_RoadTeam ON dbo.Games(RoadTeam);
GO

-- ============================================
-- Game Predictions Table
-- ============================================
IF OBJECT_ID('dbo.GamePredictions', 'U') IS NOT NULL
    DROP TABLE dbo.GamePredictions;
GO

CREATE TABLE dbo.GamePredictions (
    PredictionID INT IDENTITY(1,1) PRIMARY KEY,
    GameID INT NOT NULL FOREIGN KEY REFERENCES dbo.Games(GameID),
    ModelID INT NOT NULL FOREIGN KEY REFERENCES dbo.PredictionModels(ModelID),
    PredictedLine DECIMAL(10,2), -- Positive = Home favored, Negative = Road favored
    PredictedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_GameModel UNIQUE (GameID, ModelID)
);
GO

CREATE INDEX IX_GamePredictions_GameID ON dbo.GamePredictions(GameID);
CREATE INDEX IX_GamePredictions_ModelID ON dbo.GamePredictions(ModelID);
GO

-- ============================================
-- Aggregate Lines Table (for consensus/opening/etc)
-- ============================================
IF OBJECT_ID('dbo.GameLines', 'U') IS NOT NULL
    DROP TABLE dbo.GameLines;
GO

CREATE TABLE dbo.GameLines (
    LineID INT IDENTITY(1,1) PRIMARY KEY,
    GameID INT NOT NULL FOREIGN KEY REFERENCES dbo.Games(GameID),
    LineType NVARCHAR(50) NOT NULL, -- 'OPENING', 'CONSENSUS', 'CLOSING'
    Line DECIMAL(10,2),
    StandardDeviation DECIMAL(10,4) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_GameLineType UNIQUE (GameID, LineType)
);
GO

PRINT 'Tables created successfully!';
GO
