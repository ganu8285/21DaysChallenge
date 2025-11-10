select * from services_weekly;

-- first practice question
select service,sum(patients_admitted) as admitted
from services_weekly
group by service
having sum(patients_admitted) > 500;

-- second practice question

select service,round(avg(patient_satisfaction),2) as total_satisfaction
from services_weekly
group by service
having sum(patient_satisfaction) > 70;

-- third practice question

select * from staff_schedule;

select week,sum(present) as total_staff
from staff_schedule
group by week 
having sum(present) < 50; 

-- Daily practice question

select * from patients;

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
