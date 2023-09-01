create database FBI_Criminal_Database;
Use FBI_Criminal_Database;

create table CRIMINAL (  
 Criminal_ID varchar(45) not null,
 Health_condition text,
 Blood_group varchar(3),
 Nationality varchar(20),
 Gender varchar(10) not null,
 Criminal_name varchar(50)not null,
 Date_of_birth date,
 Age int default null,
 Unique_circumstances text,
 Weight float, 
 Height float, 
 Alias varchar(50),
 Photo text,
 Country varchar(20),
 Current_status varchar(50) not null,
 primary key(Criminal_ID)
);

create table CRIME (  
 Crime_ID varchar(45) not null,

 primary key(Crime_ID)
);

CREATE TABLE CASES (
    Case_ID varchar(45) PRIMARY KEY,
    Current_status varchar(25),
    Closed_date DATE,
    Charges int,
    Law_enforcement_agency varchar(45),
    Court_hearings varchar(45),
    Opened_date date,
    Assigned_investigator varchar(45),
    Duration varchar(10)
);

CREATE TABLE ARRESTED_CRIMINALS (
    Arrested_date_time datetime,
    Case_Id varchar(45),
    Criminal_ID varchar(45),
    PRIMARY KEY (Case_ID, Criminal_ID),
	CONSTRAINT FK_Case_ArrestedCriminals FOREIGN KEY (Case_iD) REFERENCES CASES(Case_ID),
    CONSTRAINT FK_Criminal_ArrestedCriminals FOREIGN KEY (Criminal_ID) REFERENCES CRIMINAL(Criminal_ID)
);

-- Weak Entity: JAIL
CREATE TABLE JAIL (
    Arrest_ID varchar(45),  -- Partial key
    Jail_name varchar(45),  -- Partial key
    Status varchar(25),
    Capacity int,
    Location varchar(45),
    Security_level varchar(25),
    PRIMARY KEY (Arrest_ID, Jail_name),
    CONSTRAINT FK_ArrestedCriminals_Jail FOREIGN KEY (Arrest_Id, Jail_name) REFERENCES ARRESTED_CRIMINALS(Case_ID, Criminal_ID)
);


DROP DATABASE IF EXISTS FBI_Criminal_Database;

