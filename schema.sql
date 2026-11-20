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

CREATE TABLE patient_phone {
    patient_id INTEGER REFERENCES patient(patient_id),
    phone VARCHAR(20),
    primary_flag VARCHAR(20)
        CHECK (primary_flag IN ('primary', 'not primary')),
    PRIMARY KEY (patient_id, phone)
};

