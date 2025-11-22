select * from services_weekly;

SELECT
    service,
    total_admitted,
    CASE
        WHEN total_admitted > avg_admitted THEN 'Above Average'        ELSE 'Below Average'    END AS performance
FROM (
    SELECT
        service,
        SUM(patients_admitted) AS total_admitted,
        (SELECT AVG(total)
         FROM (SELECT SUM(patients_admitted) AS total
               FROM services_weekly
               GROUP BY service)) AS avg_admitted
    FROM services_weekly
    GROUP BY service
) AS service_stats;