-- Q1: R19 - Pickup Reminder Call List
SELECT f.fill_id, f.fill_date, p.first_name, p.last_name, pp.phone
FROM fill f
JOIN prescription rx
    ON f.prescription_number = rx.prescription_number
JOIN patient p
    ON rx.patient_id = p.patient_id
JOIN patient_phone pp
    ON p.patient_id = pp.patient_id
WHERE f.fill_status = 'Ready' AND pp.primary_flag = 'Primary'
ORDER BY f.fill_date ASC;


-- Q2: R20 - Recalled/Discontinued Drugs
SELECT
    d.drug_name,
    d.drug_status,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    doc.first_name AS doctor_first_name,
    doc.last_name AS doctor_last_name,
    dp.phone AS doctor_phone
FROM drug d
JOIN prescription rx
    ON d.NDC = rx.NDC
JOIN patient p
    ON rx.patient_id = p.patient_id
JOIN doctor doc
    ON rx.DEA_number = doc.DEA_number
JOIN doctor_phone dp
    ON doc.DEA_number = dp.DEA_number
WHERE d.drug_status = 'Inactive'
ORDER BY d.drug_name, p.last_name;
