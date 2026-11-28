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


-- Q3: R21 - Monthly Fill Count by Staff Member
SELECT
    sm.employee_id,
    sm.first_name,
    sm.last_name,
    COUNT(f.fill_id) AS fill_count
FROM staff_member sm
JOIN fill f
    ON sm.employee_id = f.employee_id
WHERE YEAR(f.fill_date) = YEAR(CURDATE())
    AND MONTH(f.fill_date) = MONTH(CURDATE())
GROUP BY
    sm.employee_id,
    sm.first_name,
    sm.last_name
HAVING COUNT(f.fill_id) > 1
ORDER BY fill_count DESC;


-- Q4: R22 - C3-C5 prescriptions whose refills expire within the next 30 days
WITH ExpiringPrescriptions AS (
    SELECT
        p.prescription_number,
        p.patient_id,
        d.drug_name,
        d.drug_schedule,
        p.date_written,
        DATE_ADD(p.date_written, INTERVAL 6 MONTH) AS expiration_date
    FROM prescription p
    JOIN drug d
        ON p.NDC = d.NDC
    WHERE d.drug_schedule IN ('C3', 'C4', 'C5')
)

SELECT
    prescription_number,
    patient_id,
    drug_name,
    drug_schedule,
    date_written,
    expiration_date
FROM ExpiringPrescriptions
WHERE expiration_date BETWEEN CURDATE()
                         AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY expiration_date;


-- Q5: R23 - List patients who have no insurance plan on file
SELECT
    p.patient_id,
    p.first_name,
    p.last_name
FROM patient p
LEFT JOIN covered_by c
    ON p.patient_id = c.patient_id
WHERE c.patient_id IS NULL
ORDER BY p.last_name, p.first_name;


-- Q6: R24 - Patient drug profile with most recent fill date for each drug
WITH RankedFills AS (
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        d.drug_name,
        f.fill_date,
        ROW_NUMBER() OVER (
            PARTITION BY p.patient_id, d.drug_name
            ORDER BY f.fill_date DESC
        ) AS rn
    FROM patient p
    JOIN prescription rx
        ON p.patient_id = rx.patient_id
    JOIN drug d
        ON rx.NDC = d.NDC
    JOIN fill f
        ON rx.prescription_number = f.prescription_number
)

SELECT
    patient_id,
    first_name,
    last_name,
    drug_name,
    fill_date AS most_recent_fill_date
FROM RankedFills
WHERE rn = 1
ORDER BY patient_id, drug_name;


-- Q7: R25 - For each insurance plan, count the claims rejected this month, highest first
SELECT
    i.plan_id,
    i.plan_name,
    COUNT(*) AS rejected_claims
FROM insurance_plan i
JOIN billed_to b
    ON i.plan_id = b.plan_id
JOIN fill f
    ON b.fill_id = f.fill_id
WHERE b.claim_result = 'Rejected'
  AND YEAR(f.fill_date) = (
      SELECT YEAR(MAX(fill_date))
      FROM fill
  )
  AND MONTH(f.fill_date) = (
      SELECT MONTH(MAX(fill_date))
      FROM fill
  )
GROUP BY
    i.plan_id,
    i.plan_name
HAVING COUNT(*) > 0
ORDER BY rejected_claims DESC;


-- Q8: R26 - Refill-too-soon check: fills dispensed before the previous fill
-- of the same prescription should have run out (returned-to-stock fills ignored)
WITH FillGaps AS (
    SELECT
        f.fill_id,
        f.prescription_number,
        p.first_name,
        p.last_name,
        d.drug_name,
        d.drug_schedule,
        rx.days_supply,
        f.fill_date,
        LAG(f.fill_date) OVER (
            PARTITION BY f.prescription_number
            ORDER BY f.fill_date
        ) AS previous_fill_date
    FROM fill f
    JOIN prescription rx
        ON f.prescription_number = rx.prescription_number
    JOIN patient p
        ON rx.patient_id = p.patient_id
    JOIN drug d
        ON rx.NDC = d.NDC
    WHERE f.fill_status <> 'Returned to Stock'
)

SELECT
    fill_id,
    prescription_number,
    first_name,
    last_name,
    drug_name,
    drug_schedule,
    previous_fill_date,
    fill_date,
    DATEDIFF(fill_date, previous_fill_date) AS days_between,
    days_supply,
    days_supply - DATEDIFF(fill_date, previous_fill_date) AS days_early
FROM FillGaps
WHERE previous_fill_date IS NOT NULL
  AND DATEDIFF(fill_date, previous_fill_date) < days_supply
ORDER BY days_early DESC;


-- Q9: R27 - View of every fill waiting for pickup, with how many days it has waited
-- (read by Q10 and by the front end)
CREATE OR REPLACE VIEW ready_fills AS
SELECT
    f.fill_id,
    f.fill_date,
    DATEDIFF(CURDATE(), f.fill_date) AS days_waiting,
    rx.prescription_number,
    p.patient_id,
    p.first_name,
    p.last_name,
    d.drug_name
FROM fill f
JOIN prescription rx
    ON f.prescription_number = rx.prescription_number
JOIN patient p
    ON rx.patient_id = p.patient_id
JOIN drug d
    ON rx.NDC = d.NDC
WHERE f.fill_status = 'Ready';


-- Q10: R27 - Return-to-stock candidates: ready fills waiting more than 5 days,
-- with the number of paid claims that must be reversed (uses the Q9 view)
SELECT
    r.fill_id,
    r.first_name,
    r.last_name,
    r.drug_name,
    r.fill_date,
    r.days_waiting,
    COUNT(b.plan_id) AS paid_claims_to_reverse
FROM ready_fills r
LEFT JOIN billed_to b
    ON r.fill_id = b.fill_id
   AND b.claim_result = 'Paid'
WHERE r.days_waiting > 5
GROUP BY
    r.fill_id,
    r.first_name,
    r.last_name,
    r.drug_name,
    r.fill_date,
    r.days_waiting
ORDER BY r.days_waiting DESC;


-- Q11: R28 - Staff ranked by fills in the latest month within each role,
-- showing the top 2 per role
WITH MonthlyFills AS (
    SELECT
        sm.employee_id,
        sm.first_name,
        sm.last_name,
        sm.employee_role,
        COUNT(f.fill_id) AS fill_count
    FROM staff_member sm
    JOIN fill f
        ON sm.employee_id = f.employee_id
    WHERE YEAR(f.fill_date) = (SELECT YEAR(MAX(fill_date)) FROM fill)
      AND MONTH(f.fill_date) = (SELECT MONTH(MAX(fill_date)) FROM fill)
    GROUP BY
        sm.employee_id,
        sm.first_name,
        sm.last_name,
        sm.employee_role
),
Ranked AS (
    SELECT
        employee_role,
        employee_id,
        first_name,
        last_name,
        fill_count,
        RANK() OVER (
            PARTITION BY employee_role
            ORDER BY fill_count DESC
        ) AS rank_in_role
    FROM MonthlyFills
)

SELECT *
FROM Ranked
WHERE rank_in_role <= 2
ORDER BY employee_role, rank_in_role;


-- Q12: R29 - Return an unclaimed fill to stock: change its status and reverse
-- its paid insurance claims together, so a claim is never left billed for a
-- drug that went back on the shelf
START TRANSACTION;

UPDATE fill
SET fill_status = 'Returned to Stock'
WHERE fill_id = 'F0003'
  AND fill_status = 'Ready';

DELETE FROM billed_to
WHERE fill_id = 'F0003'
  AND claim_result = 'Paid';

COMMIT;

-- Check the result
SELECT
    f.fill_id,
    f.fill_status,
    COUNT(b.plan_id) AS remaining_claims
FROM fill f
LEFT JOIN billed_to b
    ON f.fill_id = b.fill_id
WHERE f.fill_id = 'F0003'
GROUP BY f.fill_id, f.fill_status;


-- Q13: R30 - Record a new refill. The fill must point to an existing prescription
-- and staff member through its foreign keys
INSERT INTO fill (fill_id, fill_date, quantity, fill_status, employee_id, prescription_number)
VALUES ('F0073', CURDATE(), 30, 'Ready', 'E010', 'RX700113');

-- Check the result
SELECT
    f.fill_id,
    f.fill_date,
    f.fill_status,
    p.first_name,
    p.last_name,
    d.drug_name,
    sm.first_name AS filled_by
FROM fill f
JOIN prescription rx
    ON f.prescription_number = rx.prescription_number
JOIN patient p
    ON rx.patient_id = p.patient_id
JOIN drug d
    ON rx.NDC = d.NDC
JOIN staff_member sm
    ON f.employee_id = sm.employee_id
WHERE f.fill_id = 'F0073';

-- A fill for a prescription that does not exist is rejected by the foreign key.
-- Left commented out so this file runs without errors; run it by hand to show
-- ERROR 1452 (Cannot add or update a child row: a foreign key constraint fails)
-- INSERT INTO fill (fill_id, fill_date, quantity, fill_status, employee_id, prescription_number)
-- VALUES ('F0074', CURDATE(), 30, 'Ready', 'E010', 'RX799999');
