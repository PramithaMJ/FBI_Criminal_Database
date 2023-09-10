-- Create a database called "criminal_DBMS" and use it
CREATE DATABASE IF NOT EXISTS criminal_DBMS;
USE criminal_DBMS;

-- Create the CRIMINAL table
CREATE TABLE IF NOT EXISTS CRIMINAL (
    Criminal_ID VARCHAR(10) NOT NULL,
    Health_condition TEXT,
    Blood_group VARCHAR(3),
    Nationality VARCHAR(20),
    Gender VARCHAR(10) NOT NULL,
    Criminal_name VARCHAR(50) NOT NULL,
    Date_of_birth DATE,
    Age INT DEFAULT NULL,
    Unique_circumstances TEXT,
    Weight FLOAT,
    Height FLOAT,
    Alias VARCHAR(50),
    Photo TEXT,
    Country VARCHAR(20),
    Current_status VARCHAR(50) NOT NULL,
    PRIMARY KEY (Criminal_ID)
);

-- Create a trigger to calculate the age before insert
DELIMITER //
CREATE TRIGGER calculate_age BEFORE INSERT ON CRIMINAL
FOR EACH ROW
BEGIN
    SET NEW.Age = YEAR(CURDATE()) - YEAR(NEW.Date_of_birth);
END;
//
DELIMITER ;

-- Create the REHABILITATION table
CREATE TABLE IF NOT EXISTS REHABILITATION (
    Rehabilitation_ID VARCHAR(10) NOT NULL,
    Criminal_ID VARCHAR(10),
    Institution_name TEXT,
    Date_admitted DATE,
    Additional_details TEXT,
    Duration_months DECIMAL(3, 1),
    PRIMARY KEY (Rehabilitation_ID),
    CONSTRAINT fk_criminal_rehabilitation FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID) ON UPDATE CASCADE ON DELETE SET NULL
);

/*
-- Create the CRIMINAL_FINGERPRINT table
CREATE TABLE IF NOT EXISTS CRIMINAL_FINGERPRINT (
	Fingerprint_ID varchar(25),
    Criminal_ID VARCHAR(10),
    Fingerprint TEXT,
    PRIMARY KEY (Fingerprint_ID),
    CONSTRAINT fk_criminal_fingerprint FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID) ON UPDATE CASCADE ON DELETE SET NULL
);
*/

-- junction table

CREATE TABLE IF NOT EXISTS FINGERPRINT (
    Fingerprint_ID varchar(15) PRIMARY KEY,
    Fingerprint TEXT
);

CREATE TABLE IF NOT EXISTS CRIMINAL_FINGERPRINT (
    Criminal_Fingerprint_ID varchar(15) PRIMARY KEY,
    Criminal_ID VARCHAR(10) NOT NULL,
    Fingerprint_ID varchar(15) NOT NULL,
    FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Fingerprint_ID) REFERENCES FINGERPRINT(Fingerprint_ID) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Create the CRIMINAL_ADDRESS table
/*
CREATE TABLE IF NOT EXISTS CRIMINAL_ADDRESS (
	Crimianl_Address_ID varchar(25),
    Criminal_ID VARCHAR(10),
    Province VARCHAR(50),
    Street VARCHAR(50),
    City VARCHAR(50),
	PRIMARY KEY (Crimianl_Address_ID),
    CONSTRAINT fk_criminal_ca FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID) ON UPDATE CASCADE ON DELETE SET NULL
); 
*/

-- Create the CRIMINAL_ADDRESS table
CREATE TABLE IF NOT EXISTS CRIMINAL_ADDRESS (
    Address_ID VARCHAR(10) PRIMARY KEY,
    Province VARCHAR(50),
    Street VARCHAR(50),
    City VARCHAR(50)
);

-- Create the CRIMINAL_ADDRESS_RELATION table with foreign key constraints
CREATE TABLE IF NOT EXISTS CRIMINAL_ADDRESS_RELATION (
    Criminal_ID VARCHAR(10) NOT NULL,
    Address_ID VARCHAR(10) NOT NULL,
    PRIMARY KEY (Criminal_ID, Address_ID),
    FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Address_ID) REFERENCES CRIMINAL_ADDRESS(Address_ID) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Create the Crime entity and related tables
CREATE TABLE IF NOT EXISTS Crime (
    CrimeID VARCHAR(50),
	Criminal_ID VARCHAR(10),    -- Foreign key to link with CRIMINAL table
    Description TEXT,
    Status VARCHAR(20),
    Location VARCHAR(100),
    DateTime DATETIME,
    Type VARCHAR(50),
	PRIMARY KEY (CrimeID),
    CONSTRAINT fk_criminal_crime FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID)
);


CREATE TABLE IF NOT EXISTS Witness (
    WitnessID VARCHAR(20),
	-- CrimeID VARCHAR(50),
    WitnessName VARCHAR(255),
    Statement TEXT,
    Description TEXT,
    ContactNumber VARCHAR(20),
    PRIMARY KEY (WitnessID)
    -- CONSTRAINT fk_witness_crime FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Create the CrimeWitnessVictim table
CREATE TABLE IF NOT EXISTS CrimeWitnessVictim (
    CrimeID VARCHAR(50),
    WitnessID VARCHAR(20),
    PRIMARY KEY (CrimeID, WitnessID),
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID),
    FOREIGN KEY (WitnessID) REFERENCES Witness(WitnessID)
);

CREATE TABLE IF NOT EXISTS Victim (
    VictimID VARCHAR(20),
    Statement TEXT,
    Description TEXT,
    Gender CHAR(1),
    DateOfBirth DATE,
    BloodGroup VARCHAR(5),
    AgeAtCrime INT,
    HouseNumber VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
	PRIMARY KEY (VictimID)
);
/*
CREATE TABLE IF NOT EXISTS VictimContact (
    ContactID INT AUTO_INCREMENT PRIMARY KEY,
    VictimID VARCHAR(20),
    ContactName VARCHAR(255),
    ContactNumber VARCHAR(20),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID)
);
*/
CREATE TABLE IF NOT EXISTS VictimContact (
    ContactID VARCHAR(10) PRIMARY KEY,
    VictimID VARCHAR(20),
    ContactName VARCHAR(255),
    ContactNumber VARCHAR(20),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID)
);


/*
Create table if not exists VictimAddress(
	Victim_Address_ID varchar(25) auto_increment primary key,
	VictimID VARCHAR(20),
	HouseNumber VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
	FOREIGN KEY (VictimID) REFERENCES Victim(VictimID)
);*/

CREATE TABLE IF NOT EXISTS VictimCrime (
    VictimID VARCHAR(20),
    CrimeID VARCHAR(50),
    PRIMARY KEY (VictimID, CrimeID),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID),
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE IF NOT EXISTS CloseContacts (
    VictimID VARCHAR(20),
    CloseContactName VARCHAR(100),
    RelationshipType VARCHAR(100),
    Age INT,
    HouseNumber VARCHAR(50),
    Street VARCHAR(255),
    City VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
    PRIMARY KEY (CloseContactName, VictimID)
);

CREATE TABLE IF NOT EXISTS VictimCloseContacts (
    VictimID VARCHAR(20),
    CloseContactName VARCHAR(100),
    PRIMARY KEY (VictimID, CloseContactName),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID),
    FOREIGN KEY (CloseContactName) REFERENCES CloseContacts(CloseContactName)
);

-- Create a trigger to calculate the age at the time of the crime
DELIMITER //
CREATE TRIGGER CalculateAgeAtCrime
BEFORE INSERT ON VictimCrime
FOR EACH ROW
BEGIN
    DECLARE victim_dob DATE;
    DECLARE crime_date DATETIME;
    DECLARE age INT;

    SELECT DateOfBirth INTO victim_dob
    FROM Victim
    WHERE VictimID = NEW.VictimID;

    SELECT DateTime INTO crime_date
    FROM Crime
    WHERE CrimeID = NEW.CrimeID;

    SET age = TIMESTAMPDIFF(YEAR, victim_dob, crime_date);

    UPDATE Victim
    SET AgeAtCrime = age
    WHERE VictimID = NEW.VictimID;
END;
//
DELIMITER ;

-- Create the CASES table and related tables
CREATE TABLE IF NOT EXISTS CASES (
    Case_ID VARCHAR(45) PRIMARY KEY,
    Current_status VARCHAR(25),
    Closed_date DATE,
    Charges INT,
    Law_enforcement_agency VARCHAR(45),
    Court_hearings VARCHAR(45),
    Opened_date DATE,
    Assigned_investigator VARCHAR(45),
    Duration VARCHAR(10)
);


/*
-- Create the ARRESTEDCASECRIMINALTABLE
CREATE TABLE IF NOT EXISTS ARRESTED_CASE_CRIMINAL (
    CaseID VARCHAR(45),
    CriminalID VARCHAR(45),
    PRIMARY KEY (CaseID, CriminalID),
    CONSTRAINT FK_Case_ArrestedCaseCriminalTable FOREIGN KEY (CaseID) REFERENCES CASES(Case_ID),
    CONSTRAINT FK_Criminal_ArrestedCaseCriminalTable FOREIGN KEY (CriminalID) REFERENCES CRIMINAL(Criminal_ID)
);

-- Create the ARRESTED_CRIMINAL table
CREATE TABLE IF NOT EXISTS ARRESTED_CRIMINAL (
    ArrestID VARCHAR(45) PRIMARY KEY,
    ArrestedDate DATETIME
);
 */
CREATE TABLE IF NOT EXISTS ARRESTED_CRIMINALS (
    Arrested_date_time DATETIME,
    Case_Id VARCHAR(45),
    Criminal_ID VARCHAR(45),
    PRIMARY KEY (Case_ID, Criminal_ID),
    CONSTRAINT FK_Case_ArrestedCriminals FOREIGN KEY (Case_Id) REFERENCES CASES(Case_ID),
    CONSTRAINT FK_Criminal_ArrestedCriminals FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID)
);

-- week entity

CREATE TABLE IF NOT EXISTS JAIL (
    Case_Id VARCHAR(45),
    Criminal_ID VARCHAR(45),
    Jail_name VARCHAR(45),
    Status VARCHAR(25),
    Capacity INT,
    Location VARCHAR(45),
    Security_level VARCHAR(25),
    PRIMARY KEY (Case_Id, Criminal_ID, Jail_name),
    CONSTRAINT FK_ArrestedCriminals_Jail FOREIGN KEY (Case_Id, Criminal_ID) REFERENCES ARRESTED_CRIMINALS(Case_Id, Criminal_ID)
);

-- Insert data to criminal table

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1001', 'No known health issues', 'A+', 'American', 'Male', 'John Doe', '1990-05-15', 'None', 180.5, 6.2, 'Unknown', 'photo1.jpg', 'USA', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1002', 'Asthma', 'O-', 'Canadian', 'Female', 'Jane Smith', '1985-09-23', 'Tattoo on right arm', 150.0, 5.6, 'Jess', 'photo2.jpg', 'Canada', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1003', 'Diabetes', 'B+', 'Mexican', 'Male', 'Carlos Rodriguez', '1978-12-10', 'Scars on face', 200.0, 5.9, 'Charlie', 'photo3.jpg', 'Mexico', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1004', 'No known health issues', 'AB-', 'British', 'Male', 'David Johnson', '1995-02-28', 'None', 170.0, 5.11, 'Dave', 'photo4.jpg', 'UK', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1005', 'High Blood pressure', 'A-', 'French', 'Female', 'Sophie Martin', '1987-07-03', 'None', 140.0, 5.5, 'None', 'photo5.jpg', 'France', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1006', 'No known health issues', 'O+', 'German', 'Male', 'Michael Schmidt', '1980-11-20', 'Tattoo on left forearm', 190.0, 6.0, 'Mike', 'photo6.jpg', 'Germany', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1007', 'No known health issues', 'A+', 'Russian', 'Male', 'Ivan Petrov', '1992-04-12', 'None', 175.0, 5.8, 'None', 'photo7.jpg', 'Russia', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1008', 'High blood pressure', 'B-', 'Chinese', 'Female', 'Ling Zhang', '1983-08-07', 'Scar on right hand', 160.0, 5.7, 'Lucy', 'photo8.jpg', 'China', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1009', 'No known health issues', 'AB+', 'Japanese', 'Male', 'Takashi Tanaka', '1991-01-25', 'None', 165.0, 5.10, 'Taka', 'photo9.jpg', 'Japan', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1010', 'Epilepsy', 'A-', 'Australian', 'Female', 'Emily Davis', '1989-06-15', 'None', 145.0, 5.4, 'Em', 'photo10.jpg', 'Australia', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1011', 'Anxiety disorder', 'B+', 'Italian', 'Male', 'Marco Rossi', '1982-09-08', 'None', 175.5, 5.9, 'None', 'photo11.jpg', 'Italy', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1012', 'No known health issues', 'O-', 'Spanish', 'Female', 'Elena Garcia', '1986-06-21', 'Tattoo on left shoulder', 150.0, 5.6, 'Lena', 'photo12.jpg', 'Spain', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1013', 'No known health issues', 'A+', 'Brazilian', 'Male', 'Luiz Silva', '1993-03-14', 'None', 185.0, 6.1, 'None', 'photo13.jpg', 'Brazil', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1014', 'High cholesterol', 'AB-', 'Dutch', 'Female', 'Sophia van der Veen', '1984-12-30', 'Scar on right leg', 160.0, 5.7, 'Sophie', 'photo14.jpg', 'Netherlands', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1015', 'No known health issues', 'A-', 'Swedish', 'Male', 'Erik Andersson', '1977-07-17', 'None', 175.0, 6.0, 'None', 'photo15.jpg', 'Sweden', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1016', 'Depression', 'O+', 'Norwegian', 'Female', 'Mia Olsen', '1988-02-04', 'Tattoo on back', 145.0, 5.4, 'None', 'photo16.jpg', 'Norway', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1017', 'Asthma', 'B-', 'Greek', 'Male', 'Nikos Papadopoulos', '1990-11-11', 'None', 180.0, 6.2, 'None', 'photo17.jpg', 'Greece', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1018', 'No known health issues', 'AB+', 'South Korean', 'Female', 'Ji-hyun Kim', '1994-05-29', 'Tattoo on left wrist', 155.0, 5.5, 'Ji', 'photo18.jpg', 'South Korea', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1019', 'No known health issues', 'A-', 'Indian', 'Male', 'Raj Patel', '1981-08-03', 'None', 170.0, 5.11, 'None', 'photo19.jpg', 'India', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1020', 'High blood pressure', 'O+', 'Chinese', 'Female', 'Xia Wang', '1989-04-18', 'Scar on left cheek', 140.0, 5.6, 'Sherry', 'photo20.jpg', 'China', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1021', 'No known health issues', 'A+', 'Russian', 'Female', 'Olga Petrova', '1996-12-08', 'None', 150.0, 5.5, 'None', 'photo21.jpg', 'Russia', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1022', 'High cholesterol', 'O-', 'Japanese', 'Male', 'Hiroshi Tanaka', '1983-03-27', 'Scar on left arm', 175.0, 6.0, 'Hiro', 'photo22.jpg', 'Japan', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1023', 'No known health issues', 'AB-', 'Australian', 'Female', 'Sophie Williams', '1985-08-14', 'None', 140.0, 5.4, 'None', 'photo23.jpg', 'Australia', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1024', 'Epilepsy', 'A-', 'Canadian', 'Male', 'David Mitchell', '1990-01-19', 'Tattoo on chest', 185.0, 6.2, 'Dave', 'photo24.jpg', 'Canada', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1025', 'No known health issues', 'B+', 'German', 'Female', 'Anna Schneider', '1987-06-25', 'Scar on right leg', 155.0, 5.6, 'None', 'photo25.jpg', 'Germany', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1026', 'Asthma', 'O+', 'Mexican', 'Male', 'Javier Gomez', '1984-10-30', 'None', 180.0, 6.1, 'Javi', 'photo26.jpg', 'Mexico', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1027', 'No known health issues', 'A-', 'British', 'Female', 'Emma Johnson', '1993-05-12', 'None', 150.0, 5.5, 'None', 'photo27.jpg', 'UK', 'In jail');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1028', 'Depression', 'AB+', 'French', 'Male', 'Jean Dupont', '1988-02-08', 'Tattoo on left shoulder', 175.0, 5.9, 'None', 'photo28.jpg', 'France', 'Wanted');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1029', 'No known health issues', 'B-', 'Chinese', 'Female', 'Mei Li', '1992-07-19', 'None', 140.0, 5.4, 'None', 'photo29.jpg', 'China', 'In custody');

INSERT INTO CRIMINAL (Criminal_ID, Health_condition, Blood_group, Nationality, Gender, Criminal_name, Date_of_birth, Unique_circumstances, Weight, Height, Alias, Photo, Country, Current_status)
VALUES ('C1030', 'High blood pressure', 'O-', 'Swiss', 'Male', 'Lukas Müller', '1979-11-26', 'Scar on right arm', 190.0, 6.0, 'None', 'photo30.jpg', 'Switzerland', 'Wanted');


-- insert data to rehabilitaion 


INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1001', 'C1005', 'Rehab Center A', '2022-03-15', 'Good progress', 6.5);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1003', 'C1006', 'Rehab Center A', '2022-02-10', 'Excellent behavior', 8.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1007', 'C1010', 'Rehab Center E', '2022-01-25', 'Participates in group sessions', 6.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1009', 'C1011', 'Rehab Center B', '2022-03-05', 'Cooperative with staff', 7.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES ('R1002', 'C1016', 'Rehab Center B', '2021-11-20', 'Needs counseling', 9.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1004', 'C1018', 'Rehab Center D', '2021-09-05', 'Continuing therapy', 7.5);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1005', 'C1020', 'Rehab Center C', '2022-04-30', 'Making improvements', 5.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1006', 'C1022', 'Rehab Center C', '2021-10-12', 'Requires close monitoring', 10.0);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1008', 'C1024', 'Rehab Center E', '2021-08-18', 'Showing improvement', 8.5);

INSERT INTO REHABILITATION (Rehabilitation_ID, Criminal_ID, Institution_name, Date_admitted, Additional_details, Duration_months)
VALUES('R1010', 'C1028', 'Rehab Center D', '2021-12-15', 'Needs specialized treatment', 9.5);


-- Insert data into FINGERPRINT table
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1001', 'Fingerprint data 1');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1002', 'Fingerprint data 2');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1003', 'Fingerprint data 3');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1004', 'Fingerprint data 4');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1005', 'Fingerprint data 5');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1006', 'Fingerprint data 6');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1007', 'Fingerprint data 7');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1008', 'Fingerprint data 8');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1009', 'Fingerprint data 9');
INSERT INTO FINGERPRINT (Fingerprint_ID, Fingerprint) VALUES ('F1010', 'Fingerprint data 10');


-- Insert data into CRIMINAL_FINGERPRINT table
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1001', 'C1001', 'F1001');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1002', 'C1002', 'F1002');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1003', 'C1003', 'F1003');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1004', 'C1004', 'F1004');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1005', 'C1005', 'F1005');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1006', 'C1006', 'F1006');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1007', 'C1007', 'F1007');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1008', 'C1008', 'F1008');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1009', 'C1009', 'F1009');
INSERT INTO CRIMINAL_FINGERPRINT (Criminal_Fingerprint_ID, Criminal_ID, Fingerprint_ID) VALUES ('CF1010', 'C1010', 'F1010');



-- Insert data into CRIMINAL_ADDRESS table
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1001', 'Province1', 'Street1', 'City1');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1002', 'Province2', 'Street2', 'City2');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1003', 'Province3', 'Street3', 'City3');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1004', 'Province4', 'Street4', 'City4');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1005', 'Province5', 'Street5', 'City5');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1006', 'Province6', 'Street6', 'City6');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1007', 'Province7', 'Street7', 'City7');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1008', 'Province8', 'Street8', 'City8');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1009', 'Province9', 'Street9', 'City9');
INSERT INTO CRIMINAL_ADDRESS (Address_ID, Province, Street, City) VALUES ('CA1010', 'Province10', 'Street10', 'City10');


-- Insert data into CRIMINAL_ADDRESS_RELATION table
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1001', 'CA1001');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1002', 'CA1002');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1003', 'CA1003');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1004', 'CA1004');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1005', 'CA1005');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1006', 'CA1006');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1007', 'CA1007');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1008', 'CA1008');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1009', 'CA1009');
INSERT INTO CRIMINAL_ADDRESS_RELATION (Criminal_ID, Address_ID) VALUES ('C1010', 'CA1010');


-- update criminal table 

update CRIMINAL
set Health_condition = 'Allergies', Blood_group = 'A-', Nationality = 'Spanish', Gender = 'Male', Criminal_name = 'Juan Gonzales', Date_of_birth = '1986-03-10', Unique_circumstances = 'Tattoo on left arm', Weight = 175.0, Height = 5.8, Alias = 'None', Photo = 'photo_updated1.jpg', Country = 'Spain', Current_status = 'In custody'
where Criminal_ID = 'C1001';

update CRIMINAL
set Health_condition = 'High Blood pressure', Blood_group = 'A+', Nationality = 'Russian', Gender = 'Male', Criminal_name = 'Sergei Ivanov', Date_of_birth = '1983-06-25', Unique_circumstances = 'None', Weight = 190.0, Height = 6.1, Alias = 'Serge', Photo = 'photo_updated3.jpg', Country = 'Russia', Current_status = 'In custody'
where Criminal_ID = 'C1007';

update CRIMINAL
set Health_condition = 'No known health issues', Blood_group = 'AB-', Nationality = 'Chinese', Gender = 'Female', Criminal_name = 'Li Wei', Date_of_birth = '1989-09-13', Unique_circumstances = 'None', Weight = 155.0, Height = 5.5, Alias = 'Lily', Photo = 'photo_updated4.jpg', Country = 'China', Current_status = 'Wanted'
where Criminal_ID = 'C1008';

update CRIMINAL
set Health_condition = 'Depression', Blood_group = 'O-', Nationality = 'Greek', Gender = 'Male', Criminal_name = 'Nikos Papadakis', Date_of_birth = '1981-12-04', Unique_circumstances = 'Tattoo on right arm', Weight = 180.0, Height = 6.2, Alias = 'None', Photo = 'photo_updated5.jpg', Country = 'Greece', Current_status = 'In custody'
where Criminal_ID = 'C1017';

update CRIMINAL
SET Health_condition = 'No known health issues', Blood_group = 'B-', Nationality = 'South Korean', Gender = 'Female', Criminal_name = 'Ji-eun Kim', Date_of_birth = '1985-04-27', Unique_circumstances = 'None', Weight = 150.0, Height = 5.6, Alias = 'Jenny', Photo = 'photo_updated6.jpg', Country = 'South Korea', Current_status = 'Wanted'
where Criminal_ID = 'C1018';

update CRIMINAL
set Health_condition = 'No known health issues', Blood_group = 'AB+', Nationality = 'Indian', Gender = 'Male', Criminal_name = 'Raj Kapoor', Date_of_birth = '1987-11-30', Unique_circumstances = 'None', Weight = 175.0, Height = 6.0, Alias = 'None', Photo = 'photo_updated7.jpg', Country = 'India', Current_status = 'In custody'
where Criminal_ID = 'C1019';

update CRIMINAL
set Health_condition = 'High blood pressure', Blood_group = 'A+', Nationality = 'Swiss', Gender = 'Male', Criminal_name = 'Lukas Weber', Date_of_birth = '1990-02-15', Unique_circumstances = 'None', Weight = 185.0, Height = 5.9, Alias = 'None', Photo = 'photo_updated8.jpg', Country = 'Switzerland', Current_status = 'Wanted'
where Criminal_ID = 'C1030';

update CRIMINAL
set Health_condition = 'No known health issues', Blood_group = 'O+', Nationality = 'American', Gender = 'Female', Criminal_name = 'Jennifer White', Date_of_birth = '1988-07-12', Unique_circumstances = 'Tattoo on left arm', Weight = 155.0, Height = 5.7, Alias = 'Jenny', Photo = 'photo_updated9.jpg', Country = 'USA', Current_status = 'In custody'
where Criminal_ID = 'C1029';

update CRIMINAL
set Health_condition = 'Diabetes', Blood_group = 'B+', Nationality = 'Canadian', Gender = 'Male', Criminal_name = 'Robert Anderson', Date_of_birth = '1984-05-20', Unique_circumstances = 'Tattoo on right arm', Weight = 170.0, Height = 5.11, Alias = 'Rob', Photo = 'photo_updated10.jpg', Country = 'Canada', Current_status = 'Wanted'
where Criminal_ID = 'C1024';


-- delete criminal records
delete from CRIMINAL where Criminal_ID = 'C1010';
delete from CRIMINAL where Criminal_ID = 'C1015';
delete from CRIMINAL where Criminal_ID = 'C1021';
delete from CRIMINAL where Criminal_ID = 'C1025';
delete from CRIMINAL where Criminal_ID = 'C1026';


-- update fingerprint table
/*
update FINGERPRINT
set fingerprint = 'new_fingerprint1.jpg'
where fingerprint_ID = 'F1001';

update criminal_fingerprint
set fingerprint = 'new_fingerprint2.jpg'
where criminal_id = 'c1002';

update criminal_fingerprint
set fingerprint = 'new_fingerprint3.jpg'
where criminal_id = 'c1003';

update criminal_fingerprint
set fingerprint = 'new_fingerprint4.jpg'
where criminal_id = 'c1004';

update criminal_fingerprint
set fingerprint = 'new_fingerprint5.jpg'
where criminal_id = 'c1005';

update criminal_fingerprint
set fingerprint = 'new_fingerprint6.jpg'
where criminal_id = 'c1006';

update criminal_fingerprint
set fingerprint = 'new_fingerprint7.jpg'
where criminal_id = 'c1007';

update criminal_fingerprint
set fingerprint = 'new_fingerprint8.jpg'
where criminal_id = 'c1008';
*/
update FINGERPRINT
set fingerprint = 'new_fingerprint1.jpg'
where fingerprint_ID = 'F1001';

update FINGERPRINT
set fingerprint = 'new_fingerprint2.jpg'
where fingerprint_ID = 'F1002';

update FINGERPRINT
set fingerprint = 'new_fingerprint3.jpg'
where fingerprint_ID = 'F1003';

update FINGERPRINT
set fingerprint = 'new_fingerprint4.jpg'
where fingerprint_ID = 'F1004';

update FINGERPRINT
set fingerprint = 'new_fingerprint4.jpg'
where fingerprint_ID = 'F1005';

delete from criminal_fingerprint where Criminal_ID = 'C1011';
delete from criminal_fingerprint where Criminal_ID = 'C1017';
delete from criminal_fingerprint where Criminal_ID = 'C1023';
delete from criminal_fingerprint where Criminal_ID = 'C1024';
delete from criminal_fingerprint where Criminal_ID = 'C1029';

-- update criminal_address table
-- Update multiple records in the CRIMINAL_ADDRESS table

UPDATE CRIMINAL_ADDRESS
SET
  Province = 
    CASE 
      WHEN Address_ID = 'CA1001' THEN 'New Province 1'
      WHEN Address_ID = 'CA1002' THEN 'New Province 2'
      WHEN Address_ID = 'CA1003' THEN 'New Province 3'
      WHEN Address_ID = 'CA1004' THEN 'New Province 4'
      WHEN Address_ID = 'CA1005' THEN 'New Province 5'
    END,
  Street = 
    CASE 
      WHEN Address_ID = 'CA1001' THEN 'New Street 1'
      WHEN Address_ID = 'CA1002' THEN 'New Street 2'
      WHEN Address_ID = 'CA1003' THEN 'New Street 3'
      WHEN Address_ID = 'CA1004' THEN 'New Street 4'
      WHEN Address_ID = 'CA1005' THEN 'New Street 5'
    END,
  City = 
    CASE 
      WHEN Address_ID = 'CA1001' THEN 'New City 1'
      WHEN Address_ID = 'CA1002' THEN 'New City 2'
      WHEN Address_ID = 'CA1003' THEN 'New City 3'
      WHEN Address_ID = 'CA1004' THEN 'New City 4'
      WHEN Address_ID = 'CA1005' THEN 'New City 5'
    END
WHERE Address_ID IN ('CA1001', 'CA1002', 'CA1003', 'CA1004', 'CA1005');


-- Delete the first record from the CRIMINAL_ADDRESS table
DELETE FROM CRIMINAL_ADDRESS WHERE Address_ID = 'CA1001';

-- Delete the second record from the CRIMINAL_ADDRESS table
DELETE FROM CRIMINAL_ADDRESS WHERE Address_ID = 'CA1002';


-- Update Rehabilitation  table

UPDATE REHABILITATION
SET Institution_name = 'Rehab Center A (Updated)',
    Date_admitted = '2022-04-10',
    Additional_details = 'Excellent progress',
    Duration_months = 7.0
WHERE Rehabilitation_ID = 'R1001';

UPDATE REHABILITATION
SET Institution_name = 'Rehab Center B',
    Date_admitted = '2022-05-20',
    Additional_details = 'Active participation in therapy',
    Duration_months = 8.0
WHERE Rehabilitation_ID = 'R1007';

UPDATE REHABILITATION
SET Institution_name = 'Rehab Center C',
    Date_admitted = '2022-03-01',
    Additional_details = 'Attending group sessions regularly',
    Duration_months = 6.5
WHERE Rehabilitation_ID = 'R1009';

UPDATE REHABILITATION
SET Institution_name = 'Rehab Center D (Updated)',
    Date_admitted = '2022-04-15',
    Additional_details = 'Responding well to therapy',
    Duration_months = 7.5
WHERE Rehabilitation_ID = 'R1004';

UPDATE REHABILITATION
SET Institution_name = 'Rehab Center E',
    Date_admitted = '2022-05-10',
    Additional_details = 'Engaging in counseling sessions',
    Duration_months = 6.0
WHERE Rehabilitation_ID = 'R1008';


-- delete entries from rehabilitation table

DELETE FROM REHABILITATION WHERE Rehabilitation_ID = 'R1001';
DELETE FROM REHABILITATION WHERE Rehabilitation_ID = 'R1002';
DELETE FROM REHABILITATION WHERE Rehabilitation_ID = 'R1003';

-- Sample data for the Crime table

-- Entry 1
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1001', 'Robbery at a convenience store', 'Pending', '123 Main St, Los Angeles', '2023-08-15 14:30:00', 'Robbery', 'C1001');

INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1002', 'Burglary of a residence', 'Solved', '456 Elm St, New York', '2023-07-20 09:45:00', 'Burglary', 'C1002');

-- Entry 3
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1003', 'Vandalism of a parked car', 'Pending', '789 Oak St, Chicago', '2023-09-05 17:15:00', 'Vandalism', 'C1003');

-- Entry 4
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1004', 'Assault in a bar', 'Solved', '101 Maple St, San Francisco', '2023-07-25 22:00:00', 'Assault', 'C1004');

-- Entry 5
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1005', 'Shoplifting at a mall', 'Pending', '202 Pine St, Houston', '2023-08-03 16:40:00', 'Shoplifting', 'C1005');

-- Entry 6
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1006', 'Drug trafficking', 'Solved', '303 Cedar St, Miami', '2023-07-10 18:20:00', 'Drug Offense', 'C1006');

-- Entry 7
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1007', 'Breaking and entering', 'Pending', '404 Birch St, Dallas', '2023-09-10 11:55:00', 'Breaking and Entering', 'C1007');

-- Entry 8
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1008', 'Armed robbery at a bank', 'Solved', '505 Redwood St, New Orleans', '2023-07-02 13:10:00', 'Robbery', 'C1008');

-- Entry 9
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1009', 'Assault on a public transport', 'Pending', '606 Sequoia St, Los Angeles', '2023-08-08 08:15:00', 'Assault', 'C1009');

-- Entry 10
INSERT INTO Crime (CrimeID, Description, Status, Location, DateTime, Type, Criminal_ID)
VALUES ('CR1011', 'Fraudulent activities', 'Solved', '707 Spruce St, San Diego', '2023-07-15 14:50:00', 'Fraud', 'C1011');



-- Update data in the Crime table

-- Update Entry 1
UPDATE Crime
SET Description = 'Armed robbery at a convenience store',
    Status = 'Solved',
    Location = '123 Main St, Los Angeles',
    DateTime = '2023-08-15 14:30:00',
    Type = 'Robbery',
    Criminal_ID = 'C1001'
WHERE CrimeID = 'CR1001';

-- Update Entry 2
UPDATE Crime
SET Description = 'Breaking and entering of a residence',
    Status = 'Pending',
    Location = '456 Elm St, New York',
    DateTime = '2023-07-20 09:45:00',
    Type = 'Breaking and Entering',
    Criminal_ID = 'C1002'
WHERE CrimeID = 'CR1002';

-- Update Entry 3
UPDATE Crime
SET Description = 'Vandalism of a parked car in a parking lot',
    Status = 'Solved',
    Location = '789 Oak St, Chicago',
    DateTime = '2023-09-05 17:15:00',
    Type = 'Vandalism',
    Criminal_ID = 'C1003'
WHERE CrimeID = 'CR1003';

-- Update Entry 4
UPDATE Crime
SET Description = 'Assault outside a nightclub',
    Status = 'Pending',
    Location = '101 Maple St, San Francisco',
    DateTime = '2023-08-03 16:40:00',
    Type = 'Assault',
    Criminal_ID = 'C1004'
WHERE CrimeID = 'CR1004';

-- Update Entry 5
UPDATE Crime
SET Description = 'Shoplifting at a department store',
    Status = 'Solved',
    Location = '202 Pine St, Houston',
    DateTime = '2023-07-25 22:00:00',
    Type = 'Shoplifting',
    Criminal_ID = 'C1005'
WHERE CrimeID = 'CR1005';


-- Delete data from the Crime table

DELETE FROM Crime WHERE CrimeID = 'CR1001';
DELETE FROM Crime WHERE CrimeID = 'CR1002';
DELETE FROM Crime WHERE CrimeID = 'CR1003';


-- Insert data into the Witness table
INSERT INTO Witness (WitnessID, WitnessName, Statement, Description, ContactNumber)
VALUES
('W1001', 'John Smith', 'I saw the suspect running from the scene.', 'Tall, dark-haired man wearing a black jacket.', '555-1234'),
('W1002', 'Alice Johnson', 'I heard a loud noise and saw the suspect leaving in a hurry.', 'Short, blonde woman with glasses.', '555-5678'),
('W1003', 'Robert Davis', 'I didn’t see anything, but I heard a car screeching away.', 'No description available.', '555-9876'),
('W1004', 'Emily White', 'I was walking my dog and saw the suspect acting suspiciously.', 'Medium build, wearing a baseball cap.', '555-4321'),
('W1005', 'Michael Brown', 'I saw the suspect near the crime scene talking on a phone.', 'Tall, well-dressed man in a suit.', '555-8765'),
('W1006', 'Jennifer Lee', 'I witnessed the suspect entering the building before the incident.', 'Average height, wearing a hoodie.', '555-7890'),
('W1007', 'David Miller', 'I saw the suspect leaving a backpack near the scene and walking away.', 'Medium height, carrying a backpack.', '555-2345'),
('W1008', 'Sarah Wilson', 'I heard a commotion and saw the suspect running away from a store.', 'Short, dark-haired person with a backpack.', '555-6543'),
('W1009', 'Matthew Clark', 'I noticed the suspect acting nervously near the crime scene.', 'Tall, wearing a beanie hat.', '555-3210'),
('W1010', 'Olivia Hall', 'I saw the suspect in a car speeding away after the incident.', 'Couldn’t see the driver clearly.', '555-7890');


-- Update data in the Witness table
UPDATE Witness
SET WitnessName = 'Mark Johnson', Statement = 'I saw the suspect wearing a red hat.', Description = 'Tall man with a red hat.', ContactNumber = '555-5555'
WHERE WitnessID = 'W1001';

UPDATE Witness
SET WitnessName = 'Emma Garcia', Statement = 'I noticed the suspect acting suspiciously near the scene.', Description = 'Short woman with a backpack.', ContactNumber = '555-7777'
WHERE WitnessID = 'W1004';

UPDATE Witness
SET WitnessName = 'William Brown', Statement = 'I witnessed the suspect entering the building just before the incident.', Description = 'Average height, wearing a hoodie.', ContactNumber = '555-8888'
WHERE WitnessID = 'W1006';

UPDATE Witness
SET WitnessName = 'Sophia Martinez', Statement = 'I heard a loud noise and saw the suspect fleeing in a hurry.', Description = 'Short person wearing sunglasses.', ContactNumber = '555-9999'
WHERE WitnessID = 'W1007';

UPDATE Witness
SET WitnessName = 'James Taylor', Statement = 'I saw the suspect talking on a phone near the crime scene.', Description = 'Tall, well-dressed man in a suit.', ContactNumber = '555-0000'
WHERE WitnessID = 	'W1005';

-- Delete data from the Witness table
DELETE FROM Witness WHERE WitnessID = 'W1001';
DELETE FROM Witness WHERE WitnessID = 'W1002';
DELETE FROM Witness WHERE WitnessID = 'W1003';

-- Insert data into the CrimeWitnessVictim table
INSERT INTO CrimeWitnessVictim (CrimeID, WitnessID)
VALUES
    ('CR1004', 'W1004'),
    ('CR1005', 'W1005'),
    ('CR1006', 'W1006'),
    ('CR1007', 'W1007'),
    ('CR1008', 'W1008'),
    ('CR1009', 'W1009'),
    ('CR1011', 'W1010');


-- Insert 10 entries into the Victim table
INSERT INTO Victim (VictimID, Statement, Description, Gender, DateOfBirth, BloodGroup, HouseNumber, Street, City, Province, Country, AgeAtCrime)
VALUES
    ('V1001', 'I saw the incident happen in front of my house.', 'Eye-witness to the crime', 'M', '1990-05-15', 'A+', '123', 'Main St', 'Los Angeles', 'California', 'USA', 32),
    ('V1002', 'I heard a loud noise and then saw the suspect running away.', 'Heard the crime but did not see it.', 'F', '1985-08-20', 'B-', '456', 'Maple Ave', 'New York', 'New York', 'USA', 36),
    ('V1003', 'I was in the vicinity when the crime occurred.', 'Near the scene but didn’t witness it.', 'M', '2000-02-10', 'O+', '789', 'Oak St', 'Chicago', 'Illinois', 'USA', 22),
    ('V1004', 'I saw the suspect fleeing the scene.', 'Witnessed suspect escaping after the crime.', 'F', '1975-11-30', 'AB-', '101', 'Pine Rd', 'San Francisco', 'California', 'USA', 47),
    ('V1005', 'I was inside my car when I saw the incident.', 'Witnessed from inside a vehicle', 'M', '1998-04-25', 'A-', '202', 'Cedar Ln', 'Houston', 'Texas', 'USA', 24),
    ('V1006', 'I live nearby and heard shouting before the police arrived.', 'Heard commotion before the crime was reported.', 'M', '1982-07-12', 'B+', '303', 'Birch St', 'Miami', 'Florida', 'USA', 41),
    ('V1007', 'I was jogging in the park and saw the crime happening.', 'Eye-witness while jogging', 'F', '1995-03-18', 'A-', '404', 'Elm Ave', 'Phoenix', 'Arizona', 'USA', 27),
    ('V1008', 'I saw the suspect entering the building before the incident.', 'Witnessed the suspect before the crime.', 'M', '1992-09-05', 'AB+', '505', 'Redwood Rd', 'Seattle', 'Washington', 'USA', 29),
    ('V1009', 'I was walking my dog when I heard gunshots.', 'Heard gunshots during a walk.', 'F', '1987-12-28', 'O-', '606', 'Spruce St', 'Denver', 'Colorado', 'USA', 34),
    ('V1010', 'I saw the entire incident unfold in front of my shop.', 'Clear eye-witness to the crime.', 'M', '1980-01-10', 'B-', '707', 'Maple St', 'Portland', 'Oregon', 'USA', 43);


-- Update Victim table entries
UPDATE Victim
SET Statement = 'I witnessed the crime from my balcony.',
    Description = 'Saw the entire incident from a higher vantage point.',
    Gender = 'M',
    DateOfBirth = '1991-06-25',
    BloodGroup = 'A+',
    HouseNumber = '1234',
    Street = 'Hillside Rd',
    City = 'Los Angeles',
    Province = 'California',
    Country = 'USA',
    AgeAtCrime = 30
WHERE VictimID = 'V1001';

UPDATE Victim
SET Statement = 'I heard the commotion and then saw the suspect running away.',
    Description = 'Heard the crime before witnessing the suspect fleeing.',
    Gender = 'F',
    DateOfBirth = '1984-11-10',
    BloodGroup = 'B-',
    HouseNumber = '5678',
    Street = 'Grove St',
    City = 'New York',
    Province = 'New York',
    Country = 'USA',
    AgeAtCrime = 37
WHERE VictimID = 'V1002';

UPDATE Victim
SET Statement = 'I was on the phone with a friend when I heard shouting.',
    Description = 'Heard the commotion while on a phone call.',
    Gender = 'M',
    DateOfBirth = '1999-03-02',
    BloodGroup = 'O-',
    HouseNumber = '9876',
    Street = 'Haven Ave',
    City = 'Chicago',
    Province = 'Illinois',
    Country = 'USA',
    AgeAtCrime = 23
WHERE VictimID = 'V1003';

UPDATE Victim
SET Statement = 'I witnessed the entire incident from my apartment window.',
    Description = 'Had a clear view of the crime from a high-rise building.',
    Gender = 'F',
    DateOfBirth = '1976-08-15',
    BloodGroup = 'AB-',
    HouseNumber = '4567',
    Street = 'Summit Rd',
    City = 'San Francisco',
    Province = 'California',
    Country = 'USA',
    AgeAtCrime = 46
WHERE VictimID = 'V1004';

UPDATE Victim
SET Statement = 'I was inside a coffee shop when I heard gunshots.',
    Description = 'Heard gunshots while inside a nearby café.',
    Gender = 'M',
    DateOfBirth = '1997-05-18',
    BloodGroup = 'A-',
    HouseNumber = '3456',
    Street = 'Java St',
    City = 'Houston',
    Province = 'Texas',
    Country = 'USA',
    AgeAtCrime = 25
WHERE VictimID = 'V1005';

-- Delete Victim table entries
DELETE FROM Victim WHERE VictimID = 'V1001';
DELETE FROM Victim WHERE VictimID = 'V1002';
DELETE FROM Victim WHERE VictimID = 'V1003';


INSERT INTO VictimCrime (VictimID, CrimeID)
VALUES
    ('V1004', 'CR1004'),
    ('V1005', 'CR1005'),
    ('V1006', 'CR1006'),
    ('V1007', 'CR1007'),
    ('V1008', 'CR1008'),
    ('V1009', 'CR1009'),
    ('V1010', 'CR1011');


/*
-- Then insert victim contact data
INSERT INTO VictimContact (VictimID, ContactName, ContactNumber)
VALUES
('V1001', 'John Doe', '+1-123-456-7890'),
('V1002', 'Jane Smith', '+1-987-654-3210'),
('V1003', 'Robert Johnson', '+1-555-555-5555'),
('V1004', 'Emily Davis', '+1-888-888-8888'),
('V1005', 'Michael Wilson', '+1-777-777-7777'),
('V1009', 'Sarah Brown', '+1-333-333-3333'),
('V1010', 'David Lee', '+1-222-222-2222');
*/

-- Insert data into the VictimContact table referencing the Victim table


INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1004', 'V1004', 'Michael Wilson', '555-4444');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1005', 'V1005', 'Elizabeth Brown', '555-5555');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1006', 'V1006', 'David Lee', '555-6666');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1007', 'V1007', 'Sarah Clark', '555-7777');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1008', 'V1008', 'William White', '555-8888');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1009', 'V1009', 'Olivia Martinez', '555-9999');

INSERT INTO VictimContact (ContactID, VictimID, ContactName, ContactNumber)
VALUES ('VC1010', 'V1010', 'Matthew Taylor', '555-0000');

/*
UPDATE VictimContact
SET
    ContactName = CASE
        WHEN VictimID = 'V1001' THEN 'John M. Doe'
        WHEN VictimID = 'V1002' THEN 'Jane S. Smith'
        WHEN VictimID = 'V1003' THEN 'Robert J. Davis'
        WHEN VictimID = 'V1004' THEN 'Emily Davis'
        WHEN VictimID = 'V1005' THEN 'M. Wilson'
    END,
    ContactNumber = CASE
        WHEN VictimID = 'V1001' THEN '+1-111-111-1111'
        WHEN VictimID = 'V1003' THEN '+1-555-555-5556'
        WHEN VictimID = 'V1004' THEN '+1-888-888-8889'
    END
WHERE VictimID IN ('V1001', 'V1002', 'V1003', 'V1004', 'V1005');
*/

-- Update VictimContact data
UPDATE VictimContact
SET ContactName = 'Updated Name 1', ContactNumber = '555-1111'
WHERE ContactID = 'VC1004';

UPDATE VictimContact
SET ContactName = 'Updated Name 2', ContactNumber = '555-2222'
WHERE ContactID = 'VC1005';

UPDATE VictimContact
SET ContactName = 'Updated Name 3', ContactNumber = '555-3333'
WHERE ContactID = 'VC1006';

UPDATE VictimContact
SET ContactName = 'Updated Name 4', ContactNumber = '555-4444'
WHERE ContactID = 'VC1007';

UPDATE VictimContact
SET ContactName = 'Updated Name 5', ContactNumber = '555-5555'
WHERE ContactID = 'VC1008';


-- Delete entries from VictimContact table
DELETE FROM VictimContact WHERE ContactID = 'VC1004';
DELETE FROM VictimContact WHERE ContactID = 'VC1005';
DELETE FROM VictimContact WHERE ContactID = 'VC1006';



INSERT INTO CloseContacts (VictimID, CloseContactName, RelationshipType, Age, HouseNumber, Street, City, Province, Country)
VALUES
    ('V1001', 'Mary Johnson', 'Mother', 55, '123', 'Main St', 'Los Angeles', 'California', 'USA'),
    ('V1001', 'Robert Johnson', 'Father', 60, '123', 'Main St', 'Los Angeles', 'California', 'USA'),
    ('V1002', 'Karen Smith', 'Sister', 30, '456', 'Maple Ave', 'New York', 'New York', 'USA'),
    ('V1002', 'David Smith', 'Brother', 28, '456', 'Maple Ave', 'New York', 'New York', 'USA'),
    ('V1003', 'Susan Johnson', 'Cousin', 22, '789', 'Oak St', 'Chicago', 'Illinois', 'USA'),
    ('V1004', 'Lisa Davis', 'Sister', 42, '101', 'Pine Rd', 'San Francisco', 'California', 'USA'),
    ('V1005', 'Matthew Wilson', 'Brother', 23, '202', 'Cedar Ln', 'Houston', 'Texas', 'USA'),
    ('V1006', 'James Smith', 'Brother', 39, '303', 'Birch St', 'Miami', 'Florida', 'USA'),
    ('V1007', 'Emily Taylor', 'Sister', 28, '404', 'Elm Ave', 'Phoenix', 'Arizona', 'USA'),
    ('V1008', 'Daniel Martinez', 'Brother', 31, '505', 'Redwood Rd', 'Seattle', 'Washington', 'USA');

-- Update CloseContacts table entries
UPDATE CloseContacts
SET RelationshipType = 'Mother',
    Age = 57,
    HouseNumber = '124',
    Street = 'Hillside Rd',
    City = 'Los Angeles',
    Province = 'California',
    Country = 'USA'
WHERE VictimID = 'V1001' AND CloseContactName = 'Mary Johnson';

UPDATE CloseContacts
SET RelationshipType = 'Father',
    Age = 62,
    HouseNumber = '125',
    Street = 'Hillside Rd',
    City = 'Los Angeles',
    Province = 'California',
    Country = 'USA'
WHERE VictimID = 'V1001' AND CloseContactName = 'Robert Johnson';

UPDATE CloseContacts
SET RelationshipType = 'Sister',
    Age = 32,
    HouseNumber = '457',
    Street = 'Grove St',
    City = 'New York',
    Province = 'New York',
    Country = 'USA'
WHERE VictimID = 'V1002' AND CloseContactName = 'Karen Smith';

UPDATE CloseContacts
SET RelationshipType = 'Brother',
    Age = 30,
    HouseNumber = '458',
    Street = 'Grove St',
    City = 'New York',
    Province = 'New York',
    Country = 'USA'
WHERE VictimID = 'V1002' AND CloseContactName = 'David Smith';

UPDATE CloseContacts
SET RelationshipType = 'Cousin',
    Age = 23,
    HouseNumber = '790',
    Street = 'Oak St',
    City = 'Chicago',
    Province = 'Illinois',
    Country = 'USA'
WHERE VictimID = 'V1003' AND CloseContactName = 'Susan Johnson';

-- Delete CloseContacts table entries
DELETE FROM CloseContacts
WHERE VictimID = 'V1001' AND CloseContactName = 'Mary Johnson';

DELETE FROM CloseContacts
WHERE VictimID = 'V1002' AND CloseContactName = 'David Smith';

DELETE FROM CloseContacts
WHERE VictimID = 'V1003' AND CloseContactName = 'Susan Johnson';

/*
-- Automatically populate the VictimCloseContacts table from the CloseContacts table
INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
SELECT DISTINCT v.VictimID, c.CloseContactName
FROM Victim v
CROSS JOIN CloseContacts c
WHERE v.VictimID IS NOT NULL;
*/

-- Sample data for the VictimCloseContacts table

/* -- manuvalu add
INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
VALUES ('V1004', 'Lisa Davis');

INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
VALUES ('V1005', 'Matthew Wilson');

INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
VALUES ('V1006', 'James Smith');

INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
VALUES ('V1007', 'Emily Taylor');

INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
VALUES ('V1008', 'Daniel Martinez');
*/

-- Automatically generate VictimCloseContacts based on common criteria.
INSERT INTO VictimCloseContacts (VictimID, CloseContactName)
SELECT v.VictimID, cc.CloseContactName
FROM Victim v
JOIN CloseContacts cc ON v.City = cc.City;

-- This query creates relationships between victims and close contacts
-- based on a common criteria, such as the same city.


INSERT INTO CASES (Case_ID, Current_status, Closed_date, Charges, Law_enforcement_agency, Court_hearings, Opened_date, Assigned_investigator, Duration)
VALUES
    ('CASE001', 'Open', NULL, 3, 'City Police Department', 'Pending', '2022-08-15', 'Investigator Smith', NULL),
    ('CASE002', 'Closed', '2022-09-30', 5, 'County Sheriff Office', 'Completed', '2022-08-20', 'Investigator Johnson', '45 days'),
    ('CASE003', 'Open', NULL, 2, 'State Bureau of Investigation', 'Scheduled', '2022-09-05', 'Investigator Brown', NULL),
    ('CASE004', 'Closed', '2022-10-10', 4, 'Federal Bureau of Investigation', 'Completed', '2022-09-01', 'Investigator Davis', '40 days'),
    ('CASE005', 'Open', NULL, 1, 'City Police Department', 'Pending', '2022-08-10', 'Investigator Wilson', NULL),
    ('CASE006', 'Closed', '2022-09-25', 3, 'County Sheriff Office', 'Completed', '2022-08-25', 'Investigator Lee', '31 days'),
    ('CASE007', 'Open', NULL, 2, 'State Bureau of Investigation', 'Scheduled', '2022-09-15', 'Investigator Taylor', NULL),
    ('CASE008', 'Closed', '2022-10-05', 6, 'Federal Bureau of Investigation', 'Completed', '2022-09-10', 'Investigator Martinez', '25 days'),
    ('CASE009', 'Open', NULL, 1, 'City Police Department', 'Pending', '2022-08-05', 'Investigator Garcia', NULL),
    ('CASE010', 'Open', NULL, 4, 'County Sheriff Office', 'Scheduled', '2022-09-20', 'Investigator Smith', NULL);


-- Update the Current_status and Duration of the first case (CASE001)
UPDATE CASES
SET Current_status = 'Closed',
    Duration = '60 days'
WHERE Case_ID = 'CASE001';

-- Update the Current_status and Duration of the second case (CASE002)
UPDATE CASES
SET Current_status = 'Open',
    Duration = NULL
WHERE Case_ID = 'CASE002';

-- Update the Current_status and Duration of the third case (CASE003)
UPDATE CASES
SET Current_status = 'Closed',
    Duration = '50 days'
WHERE Case_ID = 'CASE003';

-- Update the Current_status and Duration of the fourth case (CASE004)
UPDATE CASES
SET Current_status = 'Open',
    Duration = NULL
WHERE Case_ID = 'CASE004';

-- Update the Current_status and Duration of the fifth case (CASE005)
UPDATE CASES
SET Current_status = 'Closed',
    Duration = '55 days'
WHERE Case_ID = 'CASE005';


-- Delete the cases 
DELETE FROM CASES WHERE Case_ID = 'CASE001';
DELETE FROM CASES WHERE Case_ID = 'CASE002';
DELETE FROM CASES WHERE Case_ID = 'CASE003';


-- Insert 10 entries into the ARRESTED_CRIMINALS table
INSERT INTO ARRESTED_CRIMINALS (Arrested_date_time, Case_Id, Criminal_ID)
VALUES
    ('2023-08-18 16:10:00', 'CASE004', 'C1004'),
    ('2023-08-19 11:55:00', 'CASE005', 'C1005'),
    ('2023-08-20 13:25:00', 'CASE006', 'C1006'),
    ('2023-08-21 08:40:00', 'CASE007', 'C1007'),
    ('2023-08-22 17:15:00', 'CASE008', 'C1008'),
    ('2023-08-23 12:05:00', 'CASE009', 'C1009'),
    ('2023-08-24 15:50:00', 'CASE010', 'C1011');
    
-- Update 5 entries in the ARRESTED_CRIMINALS table
UPDATE ARRESTED_CRIMINALS
SET Arrested_date_time = CASE
    WHEN Case_Id = 'CASE004' AND Criminal_ID = 'C1004' THEN '2023-08-19 09:30:00'
    WHEN Case_Id = 'CASE005' AND Criminal_ID = 'C1005' THEN '2023-08-20 10:15:00'
    WHEN Case_Id = 'CASE006' AND Criminal_ID = 'C1006' THEN '2023-08-21 11:20:00'
    WHEN Case_Id = 'CASE007' AND Criminal_ID = 'C1007' THEN '2023-08-22 14:05:00'
    WHEN Case_Id = 'CASE008' AND Criminal_ID = 'C1008' THEN '2023-08-23 16:50:00'
    ELSE Arrested_date_time
END
WHERE Case_Id IN ('CASE004', 'CASE005', 'CASE006', 'CASE007', 'CASE008')
AND Criminal_ID IN ('C1004', 'C1005', 'C1006', 'C1007', 'C1008');

DELETE FROM ARRESTED_CRIMINALS
WHERE Case_Id = 'CASE004' AND Criminal_ID = 'C1004';
DELETE FROM ARRESTED_CRIMINALS
WHERE Case_Id = 'CASE004' AND Criminal_ID = 'C1005';
DELETE FROM ARRESTED_CRIMINALS
WHERE Case_Id = 'CASE004' AND Criminal_ID = 'C1006';


/*
DELETE FROM ARRESTED_CRIMINALS
WHERE Arrested_date_time < '2023-08-21 00:00:00';
*/

-- Insert data into the JAIL table
INSERT INTO JAIL (Case_Id, Criminal_ID, Jail_name, Status, Capacity, Location, Security_level)
VALUES
 
    ('CASE005', 'C1005', 'County Jail', 'Enough Space', 100, 'New York', 'Medium Security'),
    ('CASE006', 'C1006', 'County Jail', 'Not Enough Space', 75, 'Miami', 'High Security'),
    ('CASE007', 'C1007', 'Federal Prison', 'Enough Space', 300, 'Chicago', 'Maximum Security'),
    ('CASE008', 'C1008', 'City Jail', 'Not Enough Space', 30, 'San Francisco', 'Medium Security'),
    ('CASE009', 'C1009', 'State Prison', 'Enough Space', 200, 'Houston', 'High Security'),
    ('CASE010', 'C1011', 'County Jail', 'Enough Space', 80, 'Phoenix', 'Medium Security');

UPDATE VictimContact
SET ContactNumber = '555-1234'
WHERE VictimID = 'V1001';

-- update jail table
UPDATE JAIL
SET Capacity = 60, Security_level = 'High Security'
WHERE Case_Id = 'CASE006' AND Criminal_ID = 'C1006';

UPDATE JAIL
SET Status = 'Not Enough Space'
WHERE Case_Id = 'CASE007' AND Criminal_ID = 'C1007';

UPDATE JAIL
SET Status = 'Enough Space'
WHERE Case_Id = 'CASE008' AND Criminal_ID = 'C1008';

UPDATE JAIL
SET Location = 'Los Angeles'
WHERE Case_Id = 'CASE009' AND Criminal_ID = 'C1009';

UPDATE JAIL
SET Capacity = 90, Status = 'Enough Space'
WHERE Case_Id = 'CASE010' AND Criminal_ID = 'C1011';

-- Delete a Jail entry based on Case_Id and Criminal_ID
DELETE FROM JAIL
WHERE Case_Id = 'CASE005' AND Criminal_ID = 'C1005';

DELETE FROM JAIL
WHERE Case_Id = 'CASE007' AND Criminal_ID = 'C1006';

DELETE FROM JAIL
WHERE Case_Id = 'CASE009' AND Criminal_ID = 'C1007';


-- DROP DATABASE criminal_DBMS;

