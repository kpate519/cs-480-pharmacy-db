DROP DATABASE IF EXISTS pharmacy;
CREATE DATABASE pharmacy;
USE pharmacy;

CREATE TABLE patient (
    patient_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    deceased_flag VARCHAR(20) NOT NULL DEFAULT 'Not Deceased'
        CHECK (deceased_flag IN ('Deceased', 'Not Deceased')),
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state_info VARCHAR(20) NOT NULL,
    zip VARCHAR(20) NOT NULL,
    UNIQUE (first_name, last_name, date_of_birth, street, city, state_info, zip)
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
    doctor_license_number VARCHAR(20) NOT NULL UNIQUE,
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
        CHECK (drug_schedule IN ('C2', 'C3', 'C4', 'C5', 'None')),
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

CREATE TABLE prescription (
    prescription_number VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20) NOT NULL,
    DEA_number VARCHAR(20) NOT NULL,
    NDC VARCHAR(20) NOT NULL,
    employee_id VARCHAR(20) NOT NULL,
    date_written DATE NOT NULL,
    quantity INTEGER NOT NULL
        CHECK (quantity > 0),
    days_supply INTEGER NOT NULL
        CHECK (days_supply > 0),
    directions TEXT NOT NULL,
    store_number VARCHAR(20) NOT NULL,
    refills_authorized INTEGER NOT NULL
        CHECK (refills_authorized >= 0),
    PRN VARCHAR(20)
        CHECK (PRN = 'As Needed'),
        FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (DEA_number) REFERENCES doctor(DEA_number) ON DELETE RESTRICT,
    FOREIGN KEY (NDC) REFERENCES drug(NDC) ON DELETE RESTRICT,
    FOREIGN KEY (employee_id) REFERENCES staff_member(employee_id) ON DELETE RESTRICT
);

CREATE TABLE fill (
    fill_id VARCHAR(20) PRIMARY KEY,
    fill_date DATE NOT NULL,
    quantity INTEGER NOT NULL
        CHECK (quantity > 0),
    fill_status VARCHAR(20) NOT NULL
        CHECK (fill_status IN ('Ready', 'Sold', 'Returned to Stock')),
    employee_id VARCHAR(20) NOT NULL,
    prescription_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES staff_member(employee_id),
    FOREIGN KEY (prescription_number) REFERENCES prescription(prescription_number)
);

CREATE TABLE covered_by (
    patient_id VARCHAR(20),
    plan_id VARCHAR(20),
    PRIMARY KEY (patient_id, plan_id),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES insurance_plan(plan_id)
         ON DELETE CASCADE
);

CREATE TABLE supplied_by (
    NDC VARCHAR(20),
    supplier_id VARCHAR(20),
    PRIMARY KEY (NDC, supplier_id),
    FOREIGN KEY (NDC) REFERENCES drug(NDC)
        ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
         ON DELETE CASCADE
);

CREATE TABLE billed_to (
    fill_id VARCHAR(20),
    plan_id VARCHAR(20),
    claim_result VARCHAR(20) NOT NULL
        CHECK (claim_result IN ('Paid', 'Rejected')),
    PRIMARY KEY (fill_id, plan_id),
        FOREIGN KEY (employee_id) REFERENCES staff_member(employee_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (prescription_number) REFERENCES prescription(prescription_number)
        ON DELETE RESTRICT
);
