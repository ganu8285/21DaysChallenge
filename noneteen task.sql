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