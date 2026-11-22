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
    patient_id VARCHAR(20),
    phone VARCHAR(20),
    primary_flag VARCHAR(20) NOT NULL
        CHECK (primary_flag IN ('Primary', 'Not Primary')),
    PRIMARY KEY (patient_id, phone),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE
);

CREATE TABLE allergy (
    patient_id VARCHAR(20),
    allergy_name VARCHAR(50),
    PRIMARY KEY (patient_id, allergy_name),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE
);

CREATE TABLE health_condition (
    patient_id VARCHAR(20),
    condition_name VARCHAR(50),
    PRIMARY KEY (patient_id, condition_name),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE
);

CREATE TABLE doctor (
    DEA_number VARCHAR(20) PRIMARY KEY,
    license_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE doctor_phone (
    DEA_number VARCHAR(20),
    phone VARCHAR(20),
    primary_flag VARCHAR(20) NOT NULL
        CHECK (primary_flag IN ('Primary', 'Not Primary')),
    PRIMARY KEY (DEA_number, phone),
    FOREIGN KEY (DEA_number) REFERENCES doctor(DEA_number)
        ON DELETE CASCADE
);

CREATE TABLE drug (
    NDC VARCHAR(20) PRIMARY KEY,
    drug_name VARCHAR(50) NOT NULL,
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

CREATE TABLE insurance_plan (
    plan_id VARCHAR(20) PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    insurance_type VARCHAR(20) NOT NULL
        CHECK (insurance_type IN ('Medicare', 'Medicaid', 'Private'))
);

CREATE TABLE staff_member (
    employee_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_role VARCHAR(50) NOT NULL
        CHECK (employee_role IN ('Technician', 'Pharmacist', 'Rx Operations Manager')),
    license_no VARCHAR(20) UNIQUE,
    hire_date DATE NOT NULL,
    national_cert VARCHAR(20) NOT NULL
        CHECK (national_cert IN ('Certified', 'Not Certified'))
);