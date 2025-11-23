-- 1. Aggregate Service Data
WITH Svc_Stats AS (
    SELECT service, 
           SUM(patients_admitted) as total_adm, 
           SUM(patients_refused) as total_ref, 
           AVG(patient_satisfaction) as avg_sat
    FROM services_weekly GROUP BY service
),
-- 2. Aggregate Staff Data
Staff_Stats AS (
    SELECT service, 
           COUNT(DISTINCT staff_id) as distinct_staff,
           -- Cast to INT just in case 'present' is stored as BOOLEAN
           AVG(present::INT) as attendance_rate
    FROM staff_schedule GROUP BY service
),
-- 3. Aggregate Patient Data
Patient_Stats AS (
    SELECT service, 
           AVG(age) as avg_patient_age
    FROM patients GROUP BY service
)
-- 4. Join it all together
SELECT 
    s.service,
    s.total_adm,
    s.total_ref,
    ROUND(s.avg_sat, 2) AS satisfaction,
    COALESCE(st.distinct_staff, 0) AS staff_count,
    -- Rounding attendance to 2 decimal places for cleaner look
    ROUND(COALESCE(st.attendance_rate, 0), 2) AS avg_weeks_present,
    ROUND(COALESCE(p.avg_patient_age, 0), 1) AS avg_age,
    -- Performance Score
    (s.total_adm * 0.6 + s.avg_sat * 10) AS perf_score 
FROM Svc_Stats s
LEFT JOIN Staff_Stats st ON s.service = st.service
LEFT JOIN Patient_Stats p ON s.service = p.service
ORDER BY perf_score DESC;

