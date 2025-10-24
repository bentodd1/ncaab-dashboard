-- ============================================
-- Insert Reference Data
-- ============================================
-- Run this from sqlcmd: sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i 03_InsertReferenceData.sql

USE SportsAnalytics;
GO

-- ============================================
-- Insert Sports
-- ============================================
SET IDENTITY_INSERT dbo.Sports ON;

INSERT INTO dbo.Sports (SportID, SportName, SportCode)
VALUES
    (1, 'NCAA Men''s Basketball', 'NCAAB'),
    (2, 'NCAA Women''s Basketball', 'NCAAW'),
    (3, 'NFL', 'NFL'),
    (4, 'NBA', 'NBA'),
    (5, 'NCAA Football', 'NCAAF'),
    (6, 'MLB', 'MLB'),
    (7, 'NHL', 'NHL');

SET IDENTITY_INSERT dbo.Sports OFF;
GO

-- ============================================
-- Insert Seasons for NCAAB
-- ============================================
INSERT INTO dbo.Seasons (SportID, SeasonYear, StartDate, EndDate)
VALUES
    (1, '2021-22', '2021-11-01', '2022-04-30'),
    (1, '2022-23', '2022-11-01', '2023-04-30'),
    (1, '2023-24', '2023-11-01', '2024-04-30'),
    (1, '2024-25', '2024-11-01', '2025-04-30');
GO

-- ============================================
-- Insert Prediction Models
-- ============================================
INSERT INTO dbo.PredictionModels (ModelName, ModelCode, Description)
VALUES
    ('ESPN BPI', 'ESPN', 'ESPN Basketball Power Index'),
    ('Sagarin Ratings', 'SAGARIN', 'Jeff Sagarin''s rating system'),
    ('Ken Pomeroy', 'KENPOM', 'KenPom.com advanced metrics'),
    ('Massey Ratings', 'MASSEY', 'Kenneth Massey''s rating system'),
    ('Dunkel Index', 'DUNKEL', 'Dunkel Index ratings'),
    ('Dokter Entropy', 'DOKTER', 'Dokter Entropy ratings'),
    ('Moore Rankings', 'MOORE', 'Moore computer rankings'),
    ('Pugh Ratings', 'PUGH', 'Pugh Matrix ratings'),
    ('Donchess Inference', 'DONCHESS', 'Donchess Inference system'),
    ('Talis Rankings', 'TALIS', 'Talis ranking system'),
    ('Piratings', 'PIRATINGS', 'Piratings system'),
    ('Seven Overtimes', 'SEVENTIMES', '7OT rankings'),
    ('Effective Ratings', 'EFFRATING', 'Effective rating system'),
    ('David Dodds', 'DODDS', 'David Dodds ratings'),
    ('Fox Sports', 'FOX', 'Fox Sports predictions');
GO

PRINT 'Reference data inserted successfully!';
GO
