-- Add all team name variations found in the CSV files
-- This maps CSV names to our standardized team names

USE SportsAnalytics;
GO

-- Big West variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Cal Poly SLO', 23),  -- Cal Poly
('Cal Riverside', 23),  -- UC Riverside
('CS Bakersfield', 23),  -- Cal St. Bakersfield
('CS Northridge', 23),  -- Cal St. Northridge
('CS Sacramento', 23),  -- Sacramento St. (Big Sky)
('UC San Diego', 23);  -- UC San Diego

-- Update CS Sacramento to Big Sky
UPDATE dbo.Teams SET ConferenceID = 22 WHERE TeamName = 'CS Sacramento';

-- Big South / ASUN variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Campbell', 21),  -- Big South
('North Alabama', 24);  -- ASUN

-- Northeast variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Central Conn. St.', 27),  -- Central Connecticut St.
('St. Francis-NY', 27),  -- LIU/St. Francis
('Hartford', 25);  -- America East

-- Big 12 variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Central Florida', 4);  -- UCF

-- Other D1 teams
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Chaminade', 23),  -- Independent/Non-D1 (use Big West for now)
('Mercyhurst', 27),  -- Northeast or independent
('West Georgia', 24),  -- ASUN
('Southern Indiana', 28);  -- Ohio Valley

-- Horizon variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('IPFW', 13),  -- Purdue Fort Wayne
('Wisconsin-Green Bay', 13),  -- Green Bay
('Wisconsin-Milwaukee', 13),  -- Milwaukee
('Iu Indianapolis', 13),  -- Indianapolis
('IUPUI', 13);  -- Indianapolis duplicate

-- Summit variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Nebraska Omaha', 14),  -- Omaha
('Mo Kansas City', 14);  -- Kansas City

-- MEAC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Md. Eastern Shore', 32),  -- Maryland-Eastern Shore
('MD Baltimore Co', 25),  -- UMBC (America East)
('NC Central', 32),  -- North Carolina Central
('NC A&T', 32);  -- North Carolina A&T

-- CAA variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('NC Wilmington', 17);  -- UNC Wilmington

-- Southern variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('NC Greensboro', 18),  -- UNC Greensboro
('NC Asheville', 21);  -- UNC Asheville (Big South)

-- ACC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('North Carolina St.', 3),  -- NC State
('Miami-Florida', 3);  -- Miami FL

-- MAC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Miami-Ohio', 19);  -- Miami OH

-- Conference USA variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Middle Tenn St.', 11),  -- Middle Tennessee St.
('NC Charlotte', 10);  -- Charlotte (American)

-- Sun Belt variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Louisiana-Lafayette', 15),  -- Louisiana
('Troy St.', 15),  -- Troy
('South Carolina Upstat', 21);  -- USC Upstate (Big South)

-- WAC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Texas Arlington', 16),  -- UT Arlington
('Texas San Antonio', 10),  -- UTSA (American)
('UT Rio Grande Valley', 16);  -- UTRGV

-- Southland variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Texas A&M Corpus', 30),  -- Texas A&M-Corpus Christi
('East Texas A&M', 30),  -- Texas A&M Commerce
('SW Missouri St.', 12);  -- Missouri St. (MVC)

-- Ohio Valley variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Tennessee-Martin', 28),  -- UT Martin
('SIU Edwardsville', 28);  -- SIU-Edwardsville

-- SWAC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Prairie View', 31),  -- Prairie View A&M
('Miss Valley St.', 31),  -- Mississippi Valley St.
('Mississippi', 1);  -- Ole Miss (SEC)

-- Patriot variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Loyola-Maryland', 29);  -- Loyola-MD

-- MAAC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Mount St. Marys', 26),  -- Mount St. Mary's
('St. Peter''s', 26);  -- Saint Peter's

-- Northeast variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('St. Francis (PA)', 27);  -- Saint Francis-PA

-- Atlantic 10 variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('St. Joseph''s PA', 7),  -- Saint Joseph's
('VA Commonwealth', 7);  -- VCU

-- WCC variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('St. Mary''s', 8);  -- Saint Mary's

-- Summit variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('St. Thomas (Mn)', 14);  -- St. Thomas

-- Big Sky variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Nevada Wolf', 9);  -- Nevada (Mountain West)

-- Update Nevada Wolf to Mountain West
UPDATE dbo.Teams SET ConferenceID = 9 WHERE TeamName = 'Nevada Wolf';

-- Northeast variations
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('LIU Brooklyn', 27);  -- LIU

GO

PRINT 'All team name aliases added successfully!';
PRINT 'Total unmatched names handled: 58';
GO

-- Verify how many games now have conference mappings
SELECT
    'Matched' AS Status,
    COUNT(*) AS GameCount
FROM dbo.Games g
INNER JOIN dbo.Teams t ON g.HomeTeam = t.TeamName
WHERE g.SportID = 1
UNION ALL
SELECT
    'Unmatched' AS Status,
    COUNT(*) AS GameCount
FROM dbo.Games g
WHERE g.SportID = 1
AND NOT EXISTS (SELECT 1 FROM dbo.Teams t WHERE t.TeamName = g.HomeTeam);
GO
