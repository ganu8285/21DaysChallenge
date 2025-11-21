select * from services_weekly;

select * from patients;

select * from staff_schedule;



 select 
patient_id, name, service,satisfaction
from patients
where service in 
(
select 
sw.service
from services_weekly sw
group by sw.service
having 
       ( sum(1.0 * patients_admitted  * patient_satisfaction) /                sum(patients_admitted) )
        <
        (select 
        sum(1.0 * patients_admitted  * patient_satisfaction) / sum(patients_admitted) 
        from services_weekly)
and 
service in
    (select 
    distinct service 
    from services_weekly 
    where patients_refused > 0)
) 
