create database cdb;
use cdb;
-- creating crime entity
CREATE TABLE Crime (
    CrimeID VARCHAR(50) PRIMARY KEY,
    Description TEXT,
    Status VARCHAR(20),
    Location VARCHAR(100),
    DateTime DATETIME,
    Type VARCHAR(50)
);
-- creating witness entity
CREATE TABLE Witness (
    WitnessID VARCHAR(20) PRIMARY KEY,
    WitnessName VARCHAR(255),
    Statement TEXT,
    Description TEXT,
    ContactNumber VARCHAR(20)
);
-- creating relationship between witness and crime
CREATE TABLE CrimeWitnessVictim (
    CrimeID VARCHAR(50),
    WitnessID VARCHAR(20),
    PRIMARY KEY (CrimeID, WitnessID),
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID),
    FOREIGN KEY (WitnessID) REFERENCES Witness(WitnessID)
);

-- creating victim table
CREATE TABLE Victim (
    VictimID VARCHAR(20) PRIMARY KEY,
    Statement TEXT,
    Description TEXT,
    Gender CHAR(1),
    DateOfBirth DATE,
    BloodGroup VARCHAR(5),
    HouseNumber VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
    AgeAtCrime int
);

-- creating the contact attribute which is composite and multivalued
CREATE TABLE VictimContact (
    ContactID INT AUTO_INCREMENT PRIMARY KEY,
    VictimID VARCHAR(20),
    ContactName VARCHAR(255),
    ContactNumber VARCHAR(20),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID)
);

-- creating relationship between victim and crime
CREATE TABLE VictimCrime (
    VictimID VARCHAR(20),
    CrimeID VARCHAR(50),
    PRIMARY KEY (VictimID, CrimeID),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID),
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- creating the close contact table
CREATE TABLE CloseContacts (
    VictimID VARCHAR(20),
    CloseContactName VARCHAR(100),
    RelationshipType VARCHAR(100),
    Age INT,
    HouseNumber VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
    PRIMARY KEY (CloseContactName,VictimID)
);

-- Creating the connection between victim and close contacts
CREATE TABLE VictimCloseContacts (
    VictimID VARCHAR(20),
    CloseContactName VARCHAR(100),
    PRIMARY KEY (VictimID, CloseContactName),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID),
    FOREIGN KEY (CloseContactName) REFERENCES CloseContacts(CloseContactName)
);

-- deriving attributes from others

DELIMITER //

-- Create a BEFORE INSERT trigger to calculate AgeAtCrime
CREATE TRIGGER CalculateAgeAtCrime
BEFORE INSERT ON VictimCrime
FOR EACH ROW
BEGIN
    DECLARE victim_dob DATE;
    DECLARE crime_date DATETIME;
    DECLARE age INT;

    -- Retrieve the date of birth of the victim
    SELECT DateOfBirth INTO victim_dob
    FROM Victim
    WHERE VictimID = NEW.VictimID;

    -- Retrieve the date of the crime
    SELECT DateTime INTO crime_date
    FROM Crime
    WHERE CrimeID = NEW.CrimeID;

    -- Calculate the age at the time of the crime
    SET age = TIMESTAMPDIFF(YEAR, victim_dob, crime_date);

    -- Set the calculated age in the AgeAtCrime column of the Victim table
    UPDATE Victim
    SET AgeAtCrime = age
    WHERE VictimID = NEW.VictimID;
END;
//
DELIMITER ;








