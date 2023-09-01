create database FBI_Criminal_Database;
Use FBI_Criminal_Database;

CREATE TABLE CRIMINALS (
    Criminal_id VARCHAR(45) PRIMARY KEY,
    Criminal_name VARCHAR(45)
    -- other attributes
);

CREATE TABLE CASES (
    Case_id VARCHAR(45) PRIMARY KEY,
    Current_status VARCHAR(25),
    Closed_date DATE,
    Charges TEXT,
    Law_enforcement_agency VARCHAR(45),
    Court_hearings TEXT,
    Opened_date DATE,
    Assigned_investigator VARCHAR(45),
    Duration VARCHAR(10)
);

CREATE TABLE ARRESTED_CRIMINALS (
    Arrested_date_time DATETIME,
    Case_id VARCHAR(45),
    Criminal_id VARCHAR(45),
    PRIMARY KEY (Case_id, Criminal_id),
	CONSTRAINT FK_Case_ArrestedCriminals FOREIGN KEY (Case_id) REFERENCES CASES(Case_id),
    CONSTRAINT FK_Criminal_ArrestedCriminals FOREIGN KEY (Criminal_id) REFERENCES CRIMINALS(Criminal_id)
);

-- Weak Entity: JAIL
CREATE TABLE JAIL (
    Arrest_id VARCHAR(45),  -- Partial key
    Jail_name VARCHAR(45),  -- Partial key
    Status VARCHAR(25),
    Capacity INT,
    Location VARCHAR(45),
    Security_level VARCHAR(25),
    PRIMARY KEY (Arrest_id, Jail_name),
    CONSTRAINT FK_ArrestedCriminals_Jail FOREIGN KEY (Arrest_id, Jail_name) REFERENCES ARRESTED_CRIMINALS(Case_id, Criminal_id)
);


DROP DATABASE IF EXISTS FBI_Criminal_Database;

