SELECT patient_id AS id, name, 'Patient' AS type, service 
FROM patients 
WHERE LOWER(service) IN ('surgery', 'emergency')

UNION ALL

SELECT staff_id AS id, staff_name, 'Staff' AS type, service 
FROM staff 
WHERE LOWER(service) IN ('surgery', 'emergency')

ORDER BY type, service, name;