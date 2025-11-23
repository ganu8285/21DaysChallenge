--Day1

select distinct service from services_weekly;

--Day2
Expand
full21daychallenge!!!.sql
8 KB
select * from order_details;

select * from orders;

select * from pizza_types;
Expand
mini project.sql
3 KB
Girish
 pinned a message to this channel. See all pinned messages. — 6:12 pm
Girish
 pinned a message to this channel. See all pinned messages. — 6:13 pm
Girish
 pinned a message to this channel. See all pinned messages. — 6:13 pm
﻿
--Day1

select distinct service from services_weekly;

--Day2

select 
    patient_id,
    name,
    age,
    satisfaction
from 
    patients
where 
    service='surgery'
    AND satisfaction<70;

--Day3


select service,
    week,
    patients_refused,
    patients_request
from services_weekly
order by patients_refused desc
limit 5;


--Day4

select patient_id,
         name,
        service,
        satisfaction 
from patients
order by satisfaction desc
limit 5 offset 2;


--Day5

select * from services_weekly;

select 
    sum(patients_admitted) as admitted,
    sum(patients_refused) as refused,
    round(avg(patient_satisfaction),2) as satisfaction
from services_weekly;


--Day6

select 
    sum(patients_admitted) as total_patients_admitted,
    sum(patients_refused) as total_patients_refused,
    (sum(patients_admitted) *100.0/
    (sum(patients_admitted)+ sum(patients_refused))) as admission_rate
from services_weekly
group by 
    service
order by
    admission_rate desc;

--Day7

SELECT 
  sw.service,
  SUM(sw.patients_refused) AS total_refused,
  AVG(p.satisfaction) AS avg_satisfaction
FROM services_weekly sw
JOIN patients p
  ON sw.service = p.service
GROUP BY sw.service
HAVING 
  SUM(sw.patients_refused) > 100
  AND AVG(p.satisfaction) < 80;

--Day8


SELECT 
 patient_id,
 UPPER(name) AS upper_case_name,
 LOWER(service) AS service_in_lower_case,
 LENGTH(name) AS name_length,
 age,
CASE
 WHEN age >= 65 THEN 'Senior'
 WHEN age >= 18 THEN 'Adult'
 ELSE 'Minor'
END AS age_category,
FROM patients
WHERE LENGTH(name) > 10
ORDER BY upper_case_name, service_in_lower_case;

--Day9

SELECT service,
       count(patient_id) AS patient_count,
       ROUND(AVG(departure_date - arrival_date), 2) AS avg_stay_length
FROM patients
GROUP BY service
HAVING AVG(departure_date - arrival_date) > 7
ORDER BY avg_stay_length DESC;

--Day10

select service, count(patients_admitted) as total_patients,
case
    when avg(patient_satisfaction) >=80  then 'excellent'
    
    when avg(patient_satisfaction) >=70  then 'Good'
    
    when avg(patient_satisfaction)>=60  then 'Fair'

    else 'Needs Improvement'
    end as satisfaction_level
    from services_weekly    
    group by service    
order by avg(patient_satisfaction )desc ;

--Day11

select 
    service,
    event,
    count(*) as occurrences
from services_weekly
where event is not null
  and lower(event) <> 'none'
group by service, event
order by occurrences desc;

--Day12

SELECT
    CASE 
        WHEN event IS NOT NULL THEN 'With Event'
        ELSE 'No Event'
    END AS event_status,
    COUNT(*) AS week_count,
    AVG(patient_satisfaction) AS avg_satisfaction,
    AVG(staff_morale) AS avg_morale
FROM services_weekly
GROUP BY event_status
ORDER BY avg_satisfaction DESC;


--day13
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.age,
    p.service,
    s.staff_count
FROM patients p
JOIN (
    SELECT 
        service,
        COUNT() AS staff_count
    FROM staff
    GROUP BY service
    HAVING COUNT() > 5
) s
ON p.service = s.service
ORDER BY 
    s.staff_count DESC,
    p.name ASC;

--Day14
SELECT 
    s.staff_id,
    s.staff_name,
    s.role,
    s.service,
    COUNT(ss.week) AS weeks_present
FROM staff s
LEFT JOIN staff_schedule ss 
       ON s.staff_id = ss.staff_id
GROUP BY 
    s.staff_id, 
    s.staff_name, 
    s.role, 
    s.service
ORDER BY weeks_present DESC;

--16
SELECT 
    p.patient_id,
    p.name,
    p.service,
    p.satisfaction
FROM patients p
WHERE p.service IN (
    SELECT service
    FROM services_weekly
    GROUP BY service
    HAVING 
        MAX(patients_refused) > 0 
        AND AVG(patient_satisfaction) < (SELECT AVG(patient_satisfaction) FROM services_weekly)
);

--day17
SELECT 
    sub.service,
    sub.total_admitted,
    -- Compare this row's total to the average of all rows in this list
    (sub.total_admitted - AVG(sub.total_admitted) OVER()) AS diff_from_avg,
    CASE 
        WHEN sub.total_admitted > AVG(sub.total_admitted) OVER() THEN 'Above Average'
        WHEN sub.total_admitted = AVG(sub.total_admitted) OVER() THEN 'Average'
        ELSE 'Below Average'
    END AS rank_indicator
FROM (
    -- Inner Query: Calculate totals per service first
    SELECT service, SUM(patients_admitted) AS total_admitted
    FROM services_weekly
    GROUP BY service
) sub
ORDER BY sub.total_admitted DESC;

--day18
SELECT patient_id AS id, name, 'Patient' AS type, service 
FROM patients 
WHERE LOWER(service) IN ('surgery', 'emergency')

UNION ALL

SELECT staff_id AS id, staff_name, 'Staff' AS type, service 
FROM staff 
WHERE LOWER(service) IN ('surgery', 'emergency')

ORDER BY type, service, name;

--day19
WITH RankedWeeks AS (
    SELECT
        service,
        week,
        patient_satisfaction,
        patients_admitted,
        -- DENSE_RANK handles ties properly (e.g. two weeks tied for 1st place)
        DENSE_RANK() OVER(PARTITION BY service ORDER BY patient_satisfaction DESC) as ranking
    FROM services_weekly
)
SELECT * FROM RankedWeeks
WHERE ranking <= 3
ORDER BY service, ranking;

--day20
SELECT
    service,
    week,
    patients_admitted,
    -- Cumulative Sum
    SUM(patients_admitted) OVER(PARTITION BY service ORDER BY week) AS cumulative_admissions,
    -- 3-Week Moving Average
    AVG(patient_satisfaction) OVER(PARTITION BY service ORDER BY week ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3wk,
    -- Difference from THIS service's average
    -- Note: We cast to numeric to ensure decimal precision if needed, though AVG usually handles it
    patients_admitted - AVG(patients_admitted) OVER(PARTITION BY service) AS diff_from_service_avg
FROM services_weekly
WHERE week BETWEEN 10 AND 20
ORDER BY service, week;

--day21
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
