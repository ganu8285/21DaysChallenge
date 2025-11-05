select * from patients;

-- first practice question 
select age
from patients 
order by age DESC;


-- second practice question 

SELECT *
FROM services_weekly
ORDER BY week ASC, patients_request DESC;

-- third practice question

select staff_name 
from staff
order by staff_name asc;


-- daily challenge

select service,
	week,
	patients_refused,
	patients_request
from services_weekly
order by patients_refused desc
limit 5;
