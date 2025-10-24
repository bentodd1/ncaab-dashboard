-- Update team conference mappings with comprehensive D1 team classifications
-- Using actual ConferenceIDs from the Conferences table
-- Classification per user request:
-- Major: SEC, Big Ten, Big 12, ACC, Big East, Pac-12
-- Mid-Major: Mountain West (9), A-10 (7), American (10), WCC (8)
-- Minor: Everything else

USE SportsAnalytics;
GO

-- Clear existing teams
DELETE FROM dbo.Teams;
GO

-- Insert Major Conference Teams (Power 6)
-- SEC (ID=1)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Alabama', 1), ('Arkansas', 1), ('Auburn', 1), ('Florida', 1),
('Georgia', 1), ('Kentucky', 1), ('LSU', 1), ('Ole Miss', 1),
('Mississippi St.', 1), ('Missouri', 1), ('South Carolina', 1),
('Tennessee', 1), ('Texas A&M', 1), ('Vanderbilt', 1),
('Texas', 1), ('Oklahoma', 1);

-- Big Ten (ID=2)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Illinois', 2), ('Indiana', 2), ('Iowa', 2), ('Maryland', 2),
('Michigan', 2), ('Michigan St.', 2), ('Minnesota', 2), ('Nebraska', 2),
('Northwestern', 2), ('Ohio St.', 2), ('Penn St.', 2), ('Purdue', 2),
('Rutgers', 2), ('Wisconsin', 2), ('UCLA', 2), ('USC', 2),
('Oregon', 2), ('Washington', 2);

-- ACC (ID=3)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Boston College', 3), ('Clemson', 3), ('Duke', 3), ('Florida St.', 3),
('Georgia Tech', 3), ('Louisville', 3), ('Miami FL', 3), ('North Carolina', 3),
('NC State', 3), ('Notre Dame', 3), ('Pittsburgh', 3), ('Syracuse', 3),
('Virginia', 3), ('Virginia Tech', 3), ('Wake Forest', 3),
('California', 3), ('Stanford', 3), ('SMU', 3);

-- Big 12 (ID=4)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Baylor', 4), ('Iowa St.', 4), ('Kansas', 4), ('Kansas St.', 4),
('Oklahoma St.', 4), ('TCU', 4), ('Texas Tech', 4), ('West Virginia', 4),
('BYU', 4), ('Cincinnati', 4), ('Houston', 4), ('UCF', 4),
('Arizona', 4), ('Arizona St.', 4), ('Colorado', 4), ('Utah', 4);

-- Pac-12 (ID=5) - remaining teams
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Washington St.', 5), ('Oregon St.', 5);

-- Big East (ID=6)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Butler', 6), ('Connecticut', 6), ('Creighton', 6), ('DePaul', 6),
('Georgetown', 6), ('Marquette', 6), ('Providence', 6), ('St. John''s', 6),
('Seton Hall', 6), ('Villanova', 6), ('Xavier', 6);

-- Insert Mid-Major Conference Teams (per user classification)
-- Atlantic 10 (ID=7)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Davidson', 7), ('Dayton', 7), ('Duquesne', 7), ('Fordham', 7),
('George Mason', 7), ('George Washington', 7), ('La Salle', 7), ('Loyola-Chicago', 7),
('Massachusetts', 7), ('Rhode Island', 7), ('Richmond', 7), ('St. Bonaventure', 7),
('Saint Joseph''s', 7), ('Saint Louis', 7), ('VCU', 7);

-- West Coast Conference / WCC (ID=8)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Gonzaga', 8), ('Saint Mary''s', 8), ('San Francisco', 8), ('Santa Clara', 8),
('Loyola Marymount', 8), ('Pepperdine', 8), ('Pacific', 8), ('Portland', 8),
('San Diego', 8);

-- Mountain West (ID=9)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Air Force', 9), ('Boise St.', 9), ('Colorado St.', 9), ('Fresno St.', 9),
('Nevada', 9), ('New Mexico', 9), ('San Diego St.', 9), ('San Jose St.', 9),
('UNLV', 9), ('Utah St.', 9), ('Wyoming', 9);

-- American Athletic Conference (ID=10)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('East Carolina', 10), ('Memphis', 10), ('South Florida', 10), ('Temple', 10),
('Tulane', 10), ('Tulsa', 10), ('Wichita St.', 10), ('UAB', 10),
('Charlotte', 10), ('Florida Atlantic', 10), ('North Texas', 10), ('Rice', 10),
('UTSA', 10);

-- Insert Minor Conference Teams (all others)
-- Conference USA (ID=11) - NOW MINOR per user request
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Florida International', 11), ('Jacksonville St.', 11),
('Louisiana Tech', 11), ('Middle Tennessee St.', 11), ('New Mexico St.', 11),
('Sam Houston St.', 11), ('UTEP', 11), ('Western Kentucky', 11);

-- Missouri Valley (ID=12) - NOW MINOR per user request
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Belmont', 12), ('Bradley', 12), ('Drake', 12), ('Evansville', 12),
('Illinois St.', 12), ('Indiana St.', 12), ('Missouri St.', 12),
('Murray St.', 12), ('Northern Iowa', 12), ('Southern Illinois', 12),
('UIC', 12), ('Valparaiso', 12);

-- Horizon (ID=13)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Cleveland St.', 13), ('Detroit', 13), ('Green Bay', 13), ('Illinois-Chicago', 13),
('Milwaukee', 13), ('Northern Kentucky', 13), ('Oakland', 13),
('Purdue Fort Wayne', 13), ('Robert Morris', 13), ('Wright St.', 13),
('Youngstown St.', 13);

-- Summit (ID=14)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Denver', 14), ('Kansas City', 14), ('North Dakota', 14), ('North Dakota St.', 14),
('Omaha', 14), ('Oral Roberts', 14), ('South Dakota', 14), ('South Dakota St.', 14),
('St. Thomas', 14);

-- Sun Belt (ID=15)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Appalachian St.', 15), ('Arkansas St.', 15), ('Arkansas-Little Rock', 15),
('Coastal Carolina', 15), ('Georgia Southern', 15), ('Georgia St.', 15),
('James Madison', 15), ('Louisiana', 15), ('Louisiana-Monroe', 15),
('Marshall', 15), ('Old Dominion', 15), ('South Alabama', 15),
('Southern Miss', 15), ('Texas St.', 15), ('Troy', 15), ('UL Monroe', 15);

-- WAC (ID=16)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Abilene Christian', 16), ('California Baptist', 16), ('Grand Canyon', 16),
('Seattle', 16), ('Southern Utah', 16), ('Stephen F Austin', 16),
('Tarleton St.', 16), ('UT Arlington', 16), ('Utah Tech', 16), ('Utah Valley', 16);

-- Colonial (ID=17)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Charleston', 17), ('Delaware', 17), ('Drexel', 17), ('Elon', 17),
('Hofstra', 17), ('Hampton', 17), ('Monmouth', 17), ('Northeastern', 17),
('Towson', 17), ('UNC Wilmington', 17), ('William & Mary', 17);

-- Southern (ID=18)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Chattanooga', 18), ('Citadel', 18), ('East Tennessee St.', 18),
('Furman', 18), ('Mercer', 18), ('Samford', 18), ('UNC Greensboro', 18),
('VMI', 18), ('Western Carolina', 18), ('Wofford', 18);

-- MAC (ID=19)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Akron', 19), ('Ball St.', 19), ('Bowling Green', 19), ('Buffalo', 19),
('Central Michigan', 19), ('Eastern Michigan', 19), ('Kent St.', 19),
('Miami OH', 19), ('Northern Illinois', 19), ('Ohio', 19), ('Toledo', 19),
('Western Michigan', 19);

-- Ivy League (ID=20)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Brown', 20), ('Columbia', 20), ('Cornell', 20), ('Dartmouth', 20),
('Harvard', 20), ('Pennsylvania', 20), ('Princeton', 20), ('Yale', 20);

-- Big South (ID=21)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Charleston Southern', 21), ('Gardner Webb', 21), ('High Point', 21),
('Longwood', 21), ('Presbyterian', 21), ('Radford', 21), ('UNC Asheville', 21),
('Winthrop', 21);

-- Big Sky (ID=22)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Eastern Washington', 22), ('Idaho', 22), ('Idaho St.', 22), ('Montana', 22),
('Montana St.', 22), ('Northern Arizona', 22), ('Northern Colorado', 22),
('Portland St.', 22), ('Sacramento St.', 22), ('Weber St.', 22);

-- Big West (ID=23)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Cal Poly', 23), ('Cal St. Bakersfield', 23), ('Cal St. Fullerton', 23),
('Cal St. Northridge', 23), ('Hawaii', 23), ('Long Beach St.', 23),
('UC Davis', 23), ('UC Irvine', 23), ('UC Riverside', 23), ('UC Santa Barbara', 23);

-- ASUN (ID=24)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Bellarmine', 24), ('Central Arkansas', 24), ('Eastern Kentucky', 24), ('Florida Gulf Coast', 24),
('Jacksonville', 24), ('Kennesaw St.', 24), ('Liberty', 24), ('Lipscomb', 24),
('North Florida', 24), ('Queens', 24), ('Stetson', 24);

-- America East (ID=25)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Albany-NY', 25), ('Binghamton', 25), ('Bryant', 25), ('Maine', 25),
('UMass Lowell', 25), ('UMBC', 25), ('New Hampshire', 25), ('Stony Brook', 25),
('Vermont', 25);

-- Metro Atlantic / MAAC (ID=26)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Canisius', 26), ('Fairfield', 26), ('Iona', 26), ('Manhattan', 26),
('Marist', 26), ('Mount St. Mary''s', 26), ('Niagara', 26), ('Quinnipiac', 26),
('Rider', 26), ('Siena', 26), ('Saint Peter''s', 26);

-- Northeast (ID=27)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Central Connecticut St.', 27), ('Fairleigh Dickinson', 27), ('Le Moyne', 27),
('LIU', 27), ('Merrimack', 27), ('Sacred Heart', 27),
('Saint Francis-PA', 27), ('Stonehill', 27), ('Wagner', 27);

-- Ohio Valley (ID=28)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Austin Peay', 28), ('Eastern Illinois', 28), ('Lindenwood', 28),
('Little Rock', 28), ('Morehead St.', 28), ('SE Missouri St.', 28),
('SIU-Edwardsville', 28), ('Tennessee St.', 28), ('Tennessee Tech', 28),
('UT Martin', 28), ('Western Illinois', 28);

-- Patriot (ID=29)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('American', 29), ('Army', 29), ('Boston University', 29), ('Bucknell', 29),
('Colgate', 29), ('Holy Cross', 29), ('Lafayette', 29), ('Lehigh', 29),
('Loyola-MD', 29), ('Navy', 29);

-- Southland (ID=30)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Houston Christian', 30), ('Incarnate Word', 30), ('Lamar', 30),
('McNeese St.', 30), ('New Orleans', 30), ('Nicholls St.', 30),
('Northwestern St.', 30), ('SE Louisiana', 30), ('Stephen F. Austin', 30),
('Texas A&M Commerce', 30), ('A&M-Commerce', 30), ('Texas A&M-Corpus Christi', 30);

-- SWAC (ID=31)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Alabama A&M', 31), ('Alabama St.', 31), ('Alcorn St.', 31),
('Arkansas Pine Bluff', 31), ('Bethune Cookman', 31), ('Florida A&M', 31),
('Grambling St.', 31), ('Jackson St.', 31), ('Mississippi Valley St.', 31),
('Prairie View A&M', 31), ('Southern', 31), ('Texas Southern', 31);

-- MEAC (ID=32)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Coppin St.', 32), ('Delaware St.', 32), ('Howard', 32), ('Maryland-Eastern Shore', 32),
('Morgan St.', 32), ('Norfolk St.', 32), ('North Carolina A&T', 32),
('North Carolina Central', 32), ('South Carolina St.', 32);

-- Independent / Other teams
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Chicago St.', 28), ('NJIT', 27), ('Boston', 29);

GO

-- Verify the distribution by conference type
SELECT
    c.ConferenceType,
    COUNT(DISTINCT t.TeamID) AS TeamCount,
    COUNT(DISTINCT c.ConferenceID) AS ConferenceCount
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

PRINT 'Team conference mappings updated successfully!';
PRINT 'Major: Power 6 conferences';
PRINT 'Mid-Major: Mountain West, A-10, American, WCC';
PRINT 'Minor: All other conferences';
GO
