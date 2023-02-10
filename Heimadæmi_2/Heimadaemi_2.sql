-- Sævar Örn Valsson and Þórfríður Ina Arinbjarnardóttir
-- Hiemadæmi 2

-- A. (10%) 433 different employees started working in 2007. How many different
-- employees started working in 2015?
select count(distinct eid)
from Works
where EXTRACT(YEAR FROM start_date) = 2015;

-- B. (10%) What is difference in pay between the lowest and highest paid nurse? Show the
-- difference with the lowest pay as a percentage of the highest pay with rounded to two
-- decimal points. For technicians, it is 66.68%.

select concat(cast(cast(min(salary) AS Float)/cast(max(salary) as Float)*100 as decimal(4,2)), ' %') as percentage
from employee
where rid = (select id from role where name = 'Nurse');
 
-- C. (10%) The first patient with Asthma to be admitted to a hospital in the period was
-- admitted on January 4th, 2022. What day was the first patient with Chickenpox
-- admitted to a hospital in the period?

drop view if EXISTS PatientCondition

create view PatientCondition
AS
select P.name, P.id as patient, C.id, C.name as condition, A.admitted_date
from has H
join condition C
    on C.id = H.cid
join patient P
    on P.id = H.pid
join admitted A 
    on A.pid = P.id

select min(admitted_date)
from PatientCondition
where condition = 'Chickenpox'


-- D. (10%) Write a query that returns the name of each hospital in ascending order of their
-- name, along with whether their admitted patients have had a total of more than 400
-- conditions in a column named “More than 400 cases” with either “Yes” or “No”.

drop view if EXISTS Hospitalconditions

create view Hospitalconditions
AS
select C.id as condition, A.hid as hospital_id, Hp.name 
from Has H
join admitted A
    on H.pid = A.pid
join condition C 
    on C.id = H.cid
join patient P 
    on P.id = H.pid
join Hospital Hp
    on Hp.id = A.hid;

select H.name,
CASE
    WHEN count(distinct H.condition) > 400 THEN 'Yes'
    ELSE 'No'
END As "More than 400 cases"
from Hospitalconditions H
group by H.name
ORDER BY H.name ASC


-- E. (10%) Out of the employees that have quit at some point, who had worked the longest
-- in that hiring? Return their name(s), the day they started working and the day they
-- quit. (Note that they can have started working again)


drop view if EXISTS EmployeeQuit

create view EmployeeQuit
AS
select E.name, W.start_date, W.quit_date, (w.quit_date-w.start_date) as dateworked
from Works W
join employee E
    on E.id = W.eid
where W.quit_date is not null;

select name, start_date, quit_date
from EmployeeQuit
where dateworked = (select max(dateworked) from EmployeeQuit);


-- F. How many employees have salary that differs by less than 10% from the 
-- market average for their role and have treated a patient that is still admitted in a hospital?

