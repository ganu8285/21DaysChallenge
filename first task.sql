-- Table: patients
CREATE TABLE patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INTEGER,
    arrival_date DATE,
    departure_date DATE,
    service VARCHAR(50) NOT NULL,
    satisfaction INTEGER
);

-- Table: services_weekly
CREATE TABLE services_weekly (
    week INTEGER,
    month INTEGER,
    service VARCHAR(50),
    available_beds INTEGER,
    patients_request INTEGER,
    patients_admitted INTEGER,
    patients_refused INTEGER,
    patient_satisfaction INTEGER,
    staff_morale INTEGER,
    event VARCHAR(100),
    PRIMARY KEY (week, service)
);

-- Table: staff
CREATE TABLE staff (
    staff_id VARCHAR(50) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    service VARCHAR(50)
);

-- Table: staff_schedule
CREATE TABLE staff_schedule (
    week INTEGER,
    staff_id VARCHAR(50),
    staff_name VARCHAR(100),
    role VARCHAR(50),
    service VARCHAR(50),
    present INTEGER,
    PRIMARY KEY (week, staff_id)
);


SELECT * from patients;
select * from staff;
select * from staff_schedule;
select * from services_weekly;

drop table services_weekly;


select distinct service from services_weekly;