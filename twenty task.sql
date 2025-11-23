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