CREATE TABLE patient (
    patient_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    deceased_flag VARCHAR(20) NOT NULL DEFAULT 'not deceased'
        CHECK (deceased_flag IN ('deceased', 'not deceased')),
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    zip VARCHAR(20) NOT NULL
);

CREATE TABLE patient_phone (
    patient_id VARCHAR(20) REFERENCES patient(patient_id),
    phone VARCHAR(20),
    primary_flag VARCHAR(20)
        CHECK (primary_flag IN ('primary', 'not primary')),
    PRIMARY KEY (patient_id, phone)
);

CREATE TABLE allergy (
    patient_id VARCHAR(20) REFERENCES patient(patient_id),
    allergy_name VARCHAR(50),
    PRIMARY KEY (patient_id, allergy_name)
);

CREATE TABLE health_condition (
    patient_id VARCHAR(20) REFERENCES patient(patient_id),
    condition_name VARCHAR(50),
    PRIMARY KEY (patient_id, condition_name)
);

CREATE TABLE doctor (
    DEA_number VARCHAR(20) PRIMARY KEY,
    license_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);