-- Patient
INSERT INTO patient (patient_id, first_name, last_name, date_of_birth, deceased_flag, street, city, state_info, zip) VALUES 
('P001', 'John', 'Smith', '1990-05-12', 'Not Deceased', '123 Main St', 'Chicago', 'IL', '60607'),
('P002', 'Maria', 'Lopez', '1985-08-21', 'Not Deceased', '456 Oak St', 'Chicago', 'IL', '60608'),
('P003', 'David', 'Brown', '2001-03-10', 'Not Deceased', '789 Pine St', 'Chicago', 'IL', '60609'),
('P004', 'Linda', 'Garcia', '1952-11-03', 'Not Deceased', '2100 S Michigan Ave', 'Chicago', 'IL', '60616');


-- Patient Phone
INSERT INTO patient_phone (patient_id, phone, primary_flag) VALUES
('P001', '312-555-0101', 'Primary'),
('P001', '312-555-0199', 'Not Primary'),
('P002', '773-555-0142', 'Primary'),
('P003', '630-555-0177', 'Primary'),
('P004', '312-55-0188', 'Primary');


-- Allergies and Health Conditions 
INSERT INTO allergy (patient_id, allergy_name) VALUES
('P001', 'Penicillin'),
('P002', 'Sulfa'),
('P004', 'Aspirin');

INSERT INTO health_condition (patient_id, condition name) VALUES
('P001', 'Hypertension'),
('P002', 'Type 2 Diabetes'),
('P004', 'Asthma');



-- Doctor




-- Doctor Phone




-- Drug




-- Supplier




-- Insurance Plan




-- Staff Member




-- Prescription




-- Fill




-- Covered By




-- Supplied By




-- Billed To 
