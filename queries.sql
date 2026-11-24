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


