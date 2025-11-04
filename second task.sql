select * from patients;

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


