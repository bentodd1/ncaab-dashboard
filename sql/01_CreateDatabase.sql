-- ============================================
-- Create Database for Sports Analytics
-- ============================================
-- Run this from sqlcmd: sqlcmd -S MSI\SQLEXPRESS -E -i 01_CreateDatabase.sql

USE master;
GO

-- Drop database if it exists (for clean reinstall)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SportsAnalytics')
BEGIN
    ALTER DATABASE SportsAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SportsAnalytics;
END
GO

-- Create the database
CREATE DATABASE SportsAnalytics;
GO

PRINT 'Database SportsAnalytics created successfully!';
GO
