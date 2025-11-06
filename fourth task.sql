select * from patients ;

-- first practice question
select * 
from patients 
limit 5 offset 0;

-- second practice question

select *
from patients
limit 10 offset 10;

-- third practice question

select arrival_date 
from patients 
order by arrival_date desc
limit 10 ;

-- Daily Challenge

select patient_id,
		 name,
		service,
		satisfaction 
from patients
order by satisfaction desc
limit 5 offset 2;