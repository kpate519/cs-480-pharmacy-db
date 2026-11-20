CREATE TABLE patient (
    patient_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    deceased_flag VARCHAR(20) NOT NULL DEFAULT 'Not Deceased'
        CHECK (deceased_flag IN ('Deceased', 'Not Deceased')),
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    zip VARCHAR(20) NOT NULL
);

CREATE TABLE patient_phone (
    patient_id VARCHAR(20) REFERENCES patient(patient_id),
    phone VARCHAR(20),
    primary_flag VARCHAR(20)
        CHECK (primary_flag IN ('Primary', 'Not Primary')),
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
    license_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE doctor_phone (
    DEA_number VARCHAR(20) PRIMARY KEY,
    phone VARCHAR(20),
    primary_flag VARCHAR(20)
        CHECK (primary_flag IN ('Primary', 'Not Primary')),
    PRIMARY KEY (DEA_number, phone)
);

CREATE TABLE drug (
    NDC VARCHAR(20) PRIMARY KEY,
    drug_name VARCHAR(50) NOT NULL UNIQUE,
    strength VARCHAR(20) NOT NULL,
    dosage_form VARCHAR(30) NOT NULL,
    drug_schedule VARCHAR(20) NOT NULL
        CHECK (drug_schedule IN ('Controlled', 'Non-controlled')),
    drug_status VARCHAR(20) NOT NULL
        CHECK (drug_status IN ('Active', 'Inactive'))
);

CREATE TABLE supplier (
    supplier_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL UNIQUE
);