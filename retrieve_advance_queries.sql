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

-- Retrieve all records from the CRIMINAL table:
SELECT * FROM CRIMINAL;

-- Project Operation: Retrieve only the Criminal Name and Nationality from the CRIMINAL table.
SELECT Criminal_name, Nationality FROM CRIMINAL;

-- Cartesian Product Operation: Retrieve a Cartesian product of Criminals and Crimes, showing all possible combinations.
SELECT Criminal_name, CrimeID FROM CRIMINAL, Crime;

-- Creating a User View: Create a view named "HighSecurityJails" that shows the names and locations of jails with a "High Security" level.
CREATE VIEW HighSecurityJails AS
SELECT Jail_name, Location
FROM JAIL
WHERE Security_level = 'High Security';

-- Renaming Operation: Retrieve the Criminal ID and Alias, but rename Alias as "Nickname."
SELECT Criminal_ID, Alias AS Nickname FROM CRIMINAL;

-- Aggregation Function (Average): Calculate and retrieve the average age of criminals.
SELECT AVG(Age) AS AverageAge FROM CRIMINAL;

-- Find the crimes that occurred in a specific city and their respective criminal names:
SELECT CR.Description, CR.Location, C.Criminal_name
FROM Crime AS CR
JOIN CRIMINAL AS C ON CR.Criminal_ID = C.Criminal_ID
WHERE CR.Location LIKE '%Los Angeles%';


-- Advance queries
-- Union:
SELECT Criminal_name FROM CRIMINAL
UNION
SELECT WitnessName FROM Witness;

-- Intersection:


-- Division:
SELECT VictimID
FROM Victim
WHERE VictimID NOT IN (
    SELECT VictimID
    FROM VictimCrime
    WHERE CrimeID NOT IN (
        SELECT CrimeID
        FROM Crime
        WHERE Type = 'Robbery'
    )
);

-- Inner Join with Aggregation
-- no data
SELECT C.Criminal_name, COUNT(*) AS TotalCrimes
FROM CRIMINAL AS C
JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
GROUP BY C.Criminal_name
HAVING TotalCrimes > 5;


























-- ------------------------------------------------------------------------------------
-- Get a list of unique nationalities from the CRIMINAL table:
SELECT DISTINCT Nationality FROM CRIMINAL;

-- Retrieve the count of criminals by gender:
SELECT Gender, COUNT(*) AS Count
FROM CRIMINAL
GROUP BY Gender;

-- Find the average age of criminals:
SELECT AVG(Age) AS AverageAge FROM CRIMINAL;

-- Get the names of criminals with a specific blood group:
SELECT Criminal_name
FROM CRIMINAL
WHERE Blood_group = 'A+';

-- Retrieve the total number of closed cases:
SELECT COUNT(*) AS TotalClosedCases
FROM CASES
WHERE Current_status = 'Closed';



-- Complex Queries:

-- Find the criminals with aliases and their respective criminal names:
SELECT Criminal_name, Alias
FROM CRIMINAL
WHERE Alias IS NOT NULL;

-- Retrieve the rehabilitation details of criminals with their name

--  look again 
SELECT C.Criminal_name, R.Institution_name, R.Date_admitted
FROM CRIMINAL AS C
LEFT JOIN REHABILITATION AS R ON C.Criminal_ID = R.Criminal_ID;

-- Get the total number of crimes committed by each criminal:
SELECT C.Criminal_name, COUNT(*) AS TotalCrimes
FROM CRIMINAL AS C
LEFT JOIN Crime AS CR ON C.Criminal_ID = CR.Criminal_ID
GROUP BY C.Criminal_name;



-- Retrieve the total number of crimes reported by year:
SELECT YEAR(DateTime) AS Year, COUNT(*) AS TotalCrimes
FROM Crime
GROUP BY Year
ORDER BY Year;

-- List the criminals with their ages who have committed more than 5 crimes:
-- no data----------------------------------------------------------------
SELECT Criminal_name, Age
FROM CRIMINAL
WHERE Criminal_ID IN (
    SELECT Criminal_ID
    FROM Crime
    GROUP BY Criminal_ID
    HAVING COUNT(*) > 5
);

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

-- Retrieve a table displaying the top 5 cities with the highest and lowest average age of criminals:
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


-- Create a table that shows the crimes with the highest number of witnesses, including their descriptions and the witness count:
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


