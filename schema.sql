CREATE TABLE patient (
    patient_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    deceased_flag VARCHAR(20) DEFAULT 'not deceased'
        CHECK (deceased_flag IN ('deceased', 'not deceased')),
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    zip INTEGER NOT NULL
);

