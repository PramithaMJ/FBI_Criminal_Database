-- Data retrieve and advance queries

-- Table Retrieves
SELECT * FROM criminal_DBMS.ARRESTED_CRIMINALS;
SELECT * FROM criminal_DBMS.CASES;
SELECT * FROM criminal_DBMS.CloseContacts;
SELECT * FROM criminal_DBMS.Crime;
SELECT * FROM criminal_DBMS.CrimeWitnessVictim;
SELECT * FROM criminal_DBMS.CRIMINAL;
SELECT * FROM criminal_DBMS.CRIMINAL_ADDRESS;
SELECT * FROM criminal_DBMS.CRIMINAL_ADDRESS_RELATION;
SELECT * FROM criminal_DBMS.CRIMINAL_FINGERPRINT;
SELECT * FROM criminal_DBMS.FINGERPRINT;
SELECT * FROM criminal_DBMS.JAIL;
SELECT * FROM criminal_DBMS.REHABILITATION;
SELECT * FROM criminal_DBMS.Victim;
SELECT * FROM criminal_DBMS.VictimCloseContacts;
SELECT * FROM criminal_DBMS.VictimContact;
SELECT * FROM criminal_DBMS.VictimCrime;
SELECT * FROM criminal_DBMS.Witness;

-- Simple Queries

-- 1.Retrieve all records from the CRIMINAL table:
SELECT * FROM CRIMINAL;

-- 2.Project Operation: Retrieve only the Criminal Name and Nationality from the CRIMINAL table.
SELECT Criminal_name, Nationality FROM CRIMINAL;

-- 3.Cartesian Product Operation: Retrieve a Cartesian product of Criminals and Crimes, showing all possible combinations.
SELECT Criminal_name, CrimeID FROM CRIMINAL, Crime;

-- 4.Creating a User View: Create a view named "HighSecurityJails" that shows the names and locations of jails with a "High Security" level.
CREATE VIEW HighSecurityJails AS
SELECT Jail_name, Location
FROM JAIL
WHERE Security_level = 'High Security';
select * from HighSecurityJails;

-- 5.Renaming Operation: Retrieve the Criminal ID and Alias, but rename Alias as "Nickname."
SELECT Criminal_ID, Alias AS Nickname FROM CRIMINAL;

-- 6. Aggregation Function
	-- 1.Calculate and retrieve the average age of criminals.
	SELECT AVG(Age) AS AverageAge FROM CRIMINAL;

	-- 2.Retrieve the count of criminals by gender:
	SELECT Gender, COUNT(*) AS Count
	FROM CRIMINAL
	GROUP BY Gender;

	-- 3.Retrieve the total number of closed cases:
	SELECT COUNT(*) AS TotalClosedCases
	FROM CASES
	WHERE Current_status = 'Closed';


-- 7.Find the crimes that occurred in a specific city and their respective criminal names:
SELECT CR.Description, CR.Location, C.Criminal_name
FROM Crime AS CR
JOIN CRIMINAL AS C ON CR.Criminal_ID = C.Criminal_ID
WHERE CR.Location LIKE '%Los Angeles%';


-- 8.Get a list of unique nationalities from the CRIMINAL table:
SELECT DISTINCT Nationality FROM CRIMINAL;

-- 9.Get the names of criminals with a specific blood group:
SELECT Criminal_name
FROM CRIMINAL
WHERE Blood_group = 'A+';

-- 10.Find the criminals with aliases and their respective criminal names:
SELECT Criminal_name, Alias
FROM CRIMINAL
WHERE Alias IS NOT NULL;

-- =======================================================================


-- Advance queries
-- 1.Union:
SELECT Criminal_name FROM CRIMINAL
UNION
SELECT WitnessName FROM Witness;

-- 2.Intersection:
/*
SELECT * FROM Victim
INTERSECT
SELECT * FROM CloseContacts;
*/

SELECT V.*
FROM Victim V
INNER JOIN CloseContacts C ON V.VictimID = C.VictimID;


-- 3.Set Difference (Victims not in CloseContacts):
/*
SELECT * FROM Victim
EXCEPT
SELECT * FROM CloseContacts;
*/
SELECT V.*
FROM Victim AS V
LEFT JOIN CloseContacts AS CC ON V.VictimID = CC.VictimID
WHERE CC.VictimID IS NULL;


-- 4.Division (Victims who witnessed all crimes):

SELECT VictimID
FROM Victim
WHERE VictimID NOT IN (
    SELECT VictimID
    FROM VictimCrime
    WHERE CrimeID NOT IN (
        SELECT CrimeID
        FROM Crime
        WHERE Type = 'Murder'
    )
);


-- Join Operations (Using User Views):
-- 5.Inner Join (Victims and Crimes):
SELECT V.*, C.*
FROM Victim AS V
INNER JOIN VictimCrime AS VC ON V.VictimID = VC.VictimID
INNER JOIN Crime AS C ON VC.CrimeID = C.CrimeID;

-- 6.Natural Join (CloseContacts and CloseContactsDetails):


-- 7.Left Outer Join 
	-- 1.(Victims and VictimContact):
	SELECT V.*, VC.*
	FROM Victim AS V
	LEFT JOIN VictimContact AS VC ON V.VictimID = VC.VictimID;

	-- 2.Retrieve the rehabilitation details of criminals with their name
	SELECT C.Criminal_name, R.Institution_name, R.Date_admitted
	FROM CRIMINAL AS C
	LEFT JOIN REHABILITATION AS R ON C.Criminal_ID = R.Criminal_ID;


-- 8.Right Outer Join (Victims and VictimContact):
SELECT V.*, VC.*
FROM VictimContact AS VC
RIGHT JOIN Victim AS V ON V.VictimID = VC.VictimID;


-- 9.Full Outer Join (Victims and VictimContact):

-- Nested Queries (Combined with Other Operations):

-- 10.Nested Query with Union (Combining Victims and Criminals in a City):


-- 11.Nested Query with Inner Join (Victims with Crime Details):


-- 12.Nested Query with Division (Victims who witnessed all Crimes in a City):


-- 13. Get the total number of crimes committed by each criminal:
SELECT C.Criminal_name, COUNT(*) AS TotalCrimes
FROM CRIMINAL AS C
LEFT JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
GROUP BY C.Criminal_name;

-- 14. Retrieve the total number of crimes reported by year:
SELECT YEAR(DateTime) AS Year, COUNT(*) AS TotalCrimes
FROM Crime
GROUP BY Year
ORDER BY Year;

-- 15. List the criminals with their ages who have committed more than 5 crimes:
-- no data----------------------------------------------------------------
SELECT Criminal_name, Age
FROM CRIMINAL
WHERE Criminal_ID IN (
    SELECT Criminal_ID
    FROM Crime
    GROUP BY Criminal_ID
    HAVING COUNT(*) > 2
);

-- 16. -- Create a table that shows the crimes with the highest number of witnesses, including their descriptions and the witness count:
SELECT CR.Description, COUNT(CWV.WitnessID) AS NumberOfWitnesses
FROM Crime AS CR
LEFT JOIN CrimeWitnessVictim AS CWV ON CR.CrimeID = CWV.CrimeID
GROUP BY CR.CrimeID, CR.Description
HAVING NumberOfWitnesses = (
    SELECT MAX(NumberOfWitnesses)
    FROM (
        SELECT CR.CrimeID, COUNT(CWV.WitnessID) AS NumberOfWitnesses
        FROM Crime AS CR
        LEFT JOIN CrimeWitnessVictim AS CWV ON CR.CrimeID = CWV.CrimeID
        GROUP BY CR.CrimeID
    ) AS MaxWitnesses
);

-- 18. Retrieve the most common blood group among criminals:
SELECT Blood_group, COUNT(*) AS Count
FROM CRIMINAL
GROUP BY Blood_group
ORDER BY Count DESC
LIMIT 1;

-- 19. -- Retrieve a table displaying the top 5 cities with the highest and lowest average age of criminals:
(
    SELECT CR.Location, AVG(C.Age) AS AverageAge
    FROM CRIMINAL AS C
    JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
    GROUP BY CR.Location
    ORDER BY AverageAge DESC
    LIMIT 5
)
UNION ALL
(
    SELECT CR.Location, AVG(C.Age) AS AverageAge
    FROM CRIMINAL AS C
    JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
    GROUP BY CR.Location
    ORDER BY AverageAge ASC
    LIMIT 5
)
ORDER BY AverageAge DESC;







-- Inner Join with Aggregation
-- no data
SELECT C.Criminal_name, COUNT(*) AS TotalCrimes
FROM CRIMINAL AS C
JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
GROUP BY C.Criminal_name
HAVING TotalCrimes > 5;


























-- ------------------------------------------------------------------------------------










-- Complex Queries:











-- Get the average age of male and female criminals separately:
SELECT Gender, AVG(Age) AS AverageAge
FROM CRIMINAL
GROUP BY Gender;

-- Retrieve the most common blood group among criminals:
SELECT Blood_group, COUNT(*) AS Count
FROM CRIMINAL
GROUP BY Blood_group
ORDER BY Count DESC
LIMIT 1;

-- Find the crimes with the highest and lowest number of witnesses:
SELECT CR.Description, COUNT(CWV.WitnessID) AS NumberOfWitnesses
FROM Crime AS CR
LEFT JOIN CrimeWitnessVictim AS CWV ON CR.CrimeID = CWV.CrimeID
GROUP BY CR.CrimeID, CR.Description
ORDER BY NumberOfWitnesses DESC
LIMIT 1;

SELECT CR.Description, COUNT(CWV.WitnessID) AS NumberOfWitnesses
FROM Crime AS CR
LEFT JOIN CrimeWitnessVictim AS CWV ON CR.CrimeID = CWV.CrimeID
GROUP BY CR.CrimeID, CR.Description
ORDER BY NumberOfWitnesses ASC
LIMIT 1;

-- Retrieve the criminals who have been rehabilitated and their rehabilitation duration:
SELECT C.Criminal_name, R.Institution_name, R.Duration_months
FROM CRIMINAL AS C
JOIN REHABILITATION AS R ON C.Criminal_ID = R.Criminal_ID
WHERE R.Institution_name IS NOT NULL;

-- Find the cities with the highest and lowest number of reported crimes:
SELECT CR.Location, COUNT(*) AS NumberOfCrimes
FROM Crime AS CR
GROUP BY CR.Location
ORDER BY NumberOfCrimes DESC
LIMIT 1;

SELECT CR.Location, COUNT(*) AS NumberOfCrimes
FROM Crime AS CR
GROUP BY CR.Location
ORDER BY NumberOfCrimes ASC
LIMIT 1;

-- Retrieve the crimes with the longest and shortest description lengths:
SELECT CR.Description, LENGTH(CR.Description) AS DescriptionLength
FROM Crime AS CR
ORDER BY DescriptionLength DESC
LIMIT 1;

SELECT CR.Description, LENGTH(CR.Description) AS DescriptionLength
FROM Crime AS CR
ORDER BY DescriptionLength ASC
LIMIT 1;

-- Get the criminals with aliases who have committed crimes in multiple cities:
-- no datas----------------------------------------------------------------------
SELECT C.Criminal_name, C.Alias, COUNT(DISTINCT CR.Location) AS NumberOfCities
FROM CRIMINAL AS C
JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
WHERE C.Alias IS NOT NULL
GROUP BY C.Criminal_name, C.Alias
HAVING NumberOfCities > 1;

-- Retrieve a table showing the top 10 criminals with the highest number of crimes, including their names and the count of crimes:
SELECT C.Criminal_name, COUNT(*) AS TotalCrimes
FROM CRIMINAL AS C
JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
GROUP BY C.Criminal_name
ORDER BY TotalCrimes DESC
LIMIT 10;

-- Create a table that displays the average age of criminals by gender and blood group:
SELECT Gender, Blood_group, AVG(Age) AS AverageAge
FROM CRIMINAL
GROUP BY Gender, Blood_group;

-- Generate a table that shows the number of crimes reported by each witness along with their names and contact numbers:
SELECT W.WitnessName, W.ContactNumber, COUNT(CWV.CrimeID) AS TotalCrimes
FROM Witness AS W
LEFT JOIN CrimeWitnessVictim AS CWV ON W.WitnessID = CWV.WitnessID
GROUP BY W.WitnessName, W.ContactNumber;









