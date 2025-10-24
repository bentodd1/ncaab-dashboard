-- Add common team name variations that appear in the CSV files
-- This handles cases where CSV uses different names than our official team names

USE SportsAnalytics;
GO

-- Add aliases for teams with common variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
-- Big 12 variations
('Central Florida', 4),  -- UCF alias
('UConn', 6),  -- Connecticut alias

-- ACC variations
('Miami', 3),  -- Miami FL alias
('Pitt', 3),  -- Pittsburgh alias
('NC St.', 3),  -- NC State alias

-- Big Ten variations
('Mich. St.', 2),  -- Michigan St. alias

-- Mid-Major variations
('St. Mary''s CA', 8),  -- Saint Mary's alias
('San Diego St', 9),  -- San Diego St. alias (no period)
('Loyola Chicago', 7),  -- Loyola-Chicago alias
('UMass', 7),  -- Massachusetts alias
('St. Joseph''s PA', 7),  -- Saint Joseph's alias

-- Minor variations
('UConn', 6),
('Miami', 3),
('Arkansas Little Rock', 15),  -- Arkansas-Little Rock alias
('UT Arlington', 16),  -- UT Arlington (no dash)
('SF Austin', 30),  -- Stephen F. Austin alias
('ETSU', 18),  -- East Tennessee St. alias
('UNCG', 18),  -- UNC Greensboro alias
('FIU', 11),  -- Florida International alias
('UAB', 10),  -- Already added but common
('UTEP', 11),  -- Already added
('WKU', 11),  -- Western Kentucky alias
('MTSU', 11),  -- Middle Tennessee St. alias
('La Tech', 11),  -- Louisiana Tech alias
('UL Lafayette', 15),  -- Louisiana alias
('ULM', 15),  -- Louisiana-Monroe alias
('App State', 15),  -- Appalachian St. alias
('Ga. Southern', 15),  -- Georgia Southern alias
('Georgia State', 15),  -- Georgia St. alias
('Coastal', 17),  -- Coastal Carolina alias
('JMU', 15);  -- James Madison alias

GO

PRINT 'Team aliases added!';
PRINT 'Note: Some duplicates may have been rejected - this is expected';
GO
