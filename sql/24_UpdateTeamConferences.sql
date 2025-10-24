-- Update team conference mappings with comprehensive D1 team classifications
-- Classification:
-- Major: SEC, Big Ten, Big 12, ACC, Big East, Pac-12
-- Mid-Major: Mountain West, A-10, American, WCC
-- Minor: Everything else

USE SportsAnalytics;
GO

-- Clear existing teams
DELETE FROM dbo.Teams;
GO

-- Insert Major Conference Teams (Power 6)
-- SEC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Alabama', 1), ('Arkansas', 1), ('Auburn', 1), ('Florida', 1),
('Georgia', 1), ('Kentucky', 1), ('LSU', 1), ('Ole Miss', 1),
('Mississippi St.', 1), ('Missouri', 1), ('South Carolina', 1),
('Tennessee', 1), ('Texas A&M', 1), ('Vanderbilt', 1),
('Texas', 1), ('Oklahoma', 1);

-- Big Ten
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Illinois', 1), ('Indiana', 1), ('Iowa', 1), ('Maryland', 1),
('Michigan', 1), ('Michigan St.', 1), ('Minnesota', 1), ('Nebraska', 1),
('Northwestern', 1), ('Ohio St.', 1), ('Penn St.', 1), ('Purdue', 1),
('Rutgers', 1), ('Wisconsin', 1), ('UCLA', 1), ('USC', 1),
('Oregon', 1), ('Washington', 1);

-- Big 12
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Baylor', 1), ('Iowa St.', 1), ('Kansas', 1), ('Kansas St.', 1),
('Oklahoma St.', 1), ('TCU', 1), ('Texas Tech', 1), ('West Virginia', 1),
('BYU', 1), ('Cincinnati', 1), ('Houston', 1), ('UCF', 1),
('Arizona', 1), ('Arizona St.', 1), ('Colorado', 1), ('Utah', 1);

-- ACC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Boston College', 1), ('Clemson', 1), ('Duke', 1), ('Florida St.', 1),
('Georgia Tech', 1), ('Louisville', 1), ('Miami FL', 1), ('North Carolina', 1),
('NC State', 1), ('Notre Dame', 1), ('Pittsburgh', 1), ('Syracuse', 1),
('Virginia', 1), ('Virginia Tech', 1), ('Wake Forest', 1),
('California', 1), ('Stanford', 1), ('SMU', 1);

-- Big East
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Butler', 1), ('Connecticut', 1), ('Creighton', 1), ('DePaul', 1),
('Georgetown', 1), ('Marquette', 1), ('Providence', 1), ('St. John''s', 1),
('Seton Hall', 1), ('Villanova', 1), ('Xavier', 1);

-- Pac-12 (remaining teams not in Big 12/ACC)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Washington St.', 1), ('Oregon St.', 1);

-- Insert Mid-Major Conference Teams
-- Mountain West
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Air Force', 2), ('Boise St.', 2), ('Colorado St.', 2), ('Fresno St.', 2),
('Nevada', 2), ('New Mexico', 2), ('San Diego St.', 2), ('San Jose St.', 2),
('UNLV', 2), ('Utah St.', 2), ('Wyoming', 2);

-- Atlantic 10
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Davidson', 2), ('Dayton', 2), ('Duquesne', 2), ('Fordham', 2),
('George Mason', 2), ('George Washington', 2), ('La Salle', 2), ('Loyola-Chicago', 2),
('Massachusetts', 2), ('Rhode Island', 2), ('Richmond', 2), ('St. Bonaventure', 2),
('Saint Joseph''s', 2), ('Saint Louis', 2), ('VCU', 2);

-- American Athletic Conference
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('East Carolina', 2), ('Memphis', 2), ('South Florida', 2), ('Temple', 2),
('Tulane', 2), ('Tulsa', 2), ('Wichita St.', 2), ('UAB', 2),
('Charlotte', 2), ('Florida Atlantic', 2), ('North Texas', 2), ('Rice', 2),
('UTSA', 2);

-- WCC (West Coast Conference)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Gonzaga', 2), ('Saint Mary''s', 2), ('San Francisco', 2), ('Santa Clara', 2),
('Loyola Marymount', 2), ('Pepperdine', 2), ('Pacific', 2), ('Portland', 2),
('San Diego', 2);

-- Insert Minor Conference Teams
-- America East
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Albany-NY', 3), ('Binghamton', 3), ('Bryant', 3), ('Maine', 3),
('UMass Lowell', 3), ('UMBC', 3), ('New Hampshire', 3), ('Stony Brook', 3),
('Vermont', 3);

-- ASUN
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Bellarmine', 3), ('Central Arkansas', 3), ('Eastern Kentucky', 3), ('Florida Gulf Coast', 3),
('Jacksonville', 3), ('Kennesaw St.', 3), ('Liberty', 3), ('Lipscomb', 3),
('North Florida', 3), ('Queens', 3), ('Stetson', 3);

-- Big Sky
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Eastern Washington', 3), ('Idaho', 3), ('Idaho St.', 3), ('Montana', 3),
('Montana St.', 3), ('Northern Arizona', 3), ('Northern Colorado', 3),
('Portland St.', 3), ('Sacramento St.', 3), ('Weber St.', 3);

-- Big South
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Charleston Southern', 3), ('Gardner Webb', 3), ('High Point', 3),
('Longwood', 3), ('Presbyterian', 3), ('Radford', 3), ('UNC Asheville', 3),
('Winthrop', 3);

-- Big West
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Cal Poly', 3), ('Cal St. Bakersfield', 3), ('Cal St. Fullerton', 3),
('Cal St. Northridge', 3), ('Hawaii', 3), ('Long Beach St.', 3),
('UC Davis', 3), ('UC Irvine', 3), ('UC Riverside', 3), ('UC Santa Barbara', 3);

-- CAA (Colonial Athletic Association)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Charleston', 3), ('Delaware', 3), ('Drexel', 3), ('Elon', 3),
('Hofstra', 3), ('Hampton', 3), ('Monmouth', 3), ('Northeastern', 3),
('Towson', 3), ('UNC Wilmington', 3), ('William & Mary', 3);

-- Conference USA
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Florida International', 3), ('Jacksonville St.', 3),
('Louisiana Tech', 3), ('Middle Tennessee St.', 3), ('New Mexico St.', 3),
('Sam Houston St.', 3), ('UTEP', 3), ('Western Kentucky', 3);

-- Horizon League
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Cleveland St.', 3), ('Detroit', 3), ('Green Bay', 3), ('Illinois-Chicago', 3),
('Milwaukee', 3), ('Northern Kentucky', 3), ('Oakland', 3),
('Purdue Fort Wayne', 3), ('Robert Morris', 3), ('Wright St.', 3),
('Youngstown St.', 3);

-- Ivy League
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Brown', 3), ('Columbia', 3), ('Cornell', 3), ('Dartmouth', 3),
('Harvard', 3), ('Pennsylvania', 3), ('Princeton', 3), ('Yale', 3);

-- MAAC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Canisius', 3), ('Fairfield', 3), ('Iona', 3), ('Manhattan', 3),
('Marist', 3), ('Mount St. Mary''s', 3), ('Niagara', 3), ('Quinnipiac', 3),
('Rider', 3), ('Siena', 3), ('Saint Peter''s', 3);

-- MAC (Mid-American Conference)
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Akron', 3), ('Ball St.', 3), ('Bowling Green', 3), ('Buffalo', 3),
('Central Michigan', 3), ('Eastern Michigan', 3), ('Kent St.', 3),
('Miami OH', 3), ('Northern Illinois', 3), ('Ohio', 3), ('Toledo', 3),
('Western Michigan', 3);

-- MEAC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Coppin St.', 3), ('Delaware St.', 3), ('Howard', 3), ('Maryland-Eastern Shore', 3),
('Morgan St.', 3), ('Norfolk St.', 3), ('North Carolina A&T', 3),
('North Carolina Central', 3), ('South Carolina St.', 3);

-- Missouri Valley
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Belmont', 3), ('Bradley', 3), ('Drake', 3), ('Evansville', 3),
('Illinois St.', 3), ('Indiana St.', 3), ('Missouri St.', 3),
('Murray St.', 3), ('Northern Iowa', 3), ('Southern Illinois', 3),
('UIC', 3), ('Valparaiso', 3);

-- Northeast Conference
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Central Connecticut St.', 3), ('Fairleigh Dickinson', 3), ('Le Moyne', 3),
('LIU', 3), ('Merrimack', 3), ('Sacred Heart', 3),
('Saint Francis-PA', 3), ('Stonehill', 3), ('Wagner', 3);

-- Ohio Valley
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Austin Peay', 3), ('Eastern Illinois', 3), ('Lindenwood', 3),
('Little Rock', 3), ('Morehead St.', 3), ('SE Missouri St.', 3),
('SIU-Edwardsville', 3), ('Tennessee St.', 3), ('Tennessee Tech', 3),
('UT Martin', 3), ('Western Illinois', 3);

-- Patriot League
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('American', 3), ('Army', 3), ('Boston University', 3), ('Bucknell', 3),
('Colgate', 3), ('Holy Cross', 3), ('Lafayette', 3), ('Lehigh', 3),
('Loyola-MD', 3), ('Navy', 3);

-- Southern Conference
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Chattanooga', 3), ('Citadel', 3), ('East Tennessee St.', 3),
('Furman', 3), ('Mercer', 3), ('Samford', 3), ('UNC Greensboro', 3),
('VMI', 3), ('Western Carolina', 3), ('Wofford', 3);

-- Southland Conference
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Houston Christian', 3), ('Incarnate Word', 3), ('Lamar', 3),
('McNeese St.', 3), ('New Orleans', 3), ('Nicholls St.', 3),
('Northwestern St.', 3), ('SE Louisiana', 3), ('Stephen F. Austin', 3),
('Texas A&M Commerce', 3), ('A&M-Commerce', 3), ('Texas A&M-Corpus Christi', 3);

-- Summit League
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Denver', 3), ('Kansas City', 3), ('North Dakota', 3), ('North Dakota St.', 3),
('Omaha', 3), ('Oral Roberts', 3), ('South Dakota', 3), ('South Dakota St.', 3),
('St. Thomas', 3);

-- Sun Belt
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Appalachian St.', 3), ('Arkansas St.', 3), ('Arkansas-Little Rock', 3),
('Coastal Carolina', 3), ('Georgia Southern', 3), ('Georgia St.', 3),
('James Madison', 3), ('Louisiana', 3), ('Louisiana-Monroe', 3),
('Marshall', 3), ('Old Dominion', 3), ('South Alabama', 3),
('Southern Miss', 3), ('Texas St.', 3), ('Troy', 3), ('UL Monroe', 3);

-- SWAC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Alabama A&M', 3), ('Alabama St.', 3), ('Alcorn St.', 3),
('Arkansas Pine Bluff', 3), ('Bethune Cookman', 3), ('Florida A&M', 3),
('Grambling St.', 3), ('Jackson St.', 3), ('Mississippi Valley St.', 3),
('Prairie View A&M', 3), ('Southern', 3), ('Texas Southern', 3);

-- WAC
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Abilene Christian', 3), ('California Baptist', 3), ('Grand Canyon', 3),
('Seattle', 3), ('Southern Utah', 3), ('Stephen F Austin', 3),
('Tarleton St.', 3), ('UT Arlington', 3), ('Utah Tech', 3), ('Utah Valley', 3);

-- Independent / Other teams that might appear
INSERT INTO dbo.Teams (TeamName, ConferenceID) VALUES
('Chicago St.', 3), ('NJIT', 3), ('Boston', 3);

GO

-- Verify the distribution
SELECT
    c.ConferenceName,
    c.ConferenceType,
    COUNT(*) AS TeamCount
FROM dbo.Teams t
INNER JOIN dbo.Conferences c ON t.ConferenceID = c.ConferenceID
GROUP BY c.ConferenceName, c.ConferenceType
ORDER BY c.ConferenceType, c.ConferenceName;
GO

PRINT 'Team conference mappings updated successfully!';
GO
