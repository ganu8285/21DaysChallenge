select * from services_weekly;



SELECT 
    sw.service,
    SUM(sw.patients_admitted) AS total_patients_admitted,
    SUM(sw.patients_refused) AS total_patients_refused,
    AVG(sw.patient_satisfaction) AS avg_satisfaction,
    COUNT(DISTINCT st.staff_id) AS staff_assigned_count,
    COUNT(DISTINCT ss.staff_id) AS staff_present_week20
FROM services_weekly sw
LEFT JOIN staff st 
       ON st.service = sw.service
LEFT JOIN staff_schedule ss
       ON ss.service = sw.service 
      AND ss.week = 20
WHERE sw.week = 20
GROUP BY sw.service
ORDER BY total_patients_admitted DESC;
