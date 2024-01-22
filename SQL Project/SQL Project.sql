#create scheme called VivaKHR	
create schema if not exists VivaKHR;	
	
Use VivaKHR;	
	
#create the table regions to store details of the regions	
create table if not exists regions (	
	region_id int auto_increment,
	region_name varchar(50) default null,
constraint region_pk primary key(region_id)	
);	
	
#create the table countries to store details of the countries	
create table if not exists countries (	
	country_id char(2),
	country_name varchar(40),
	region_id int not null,
	constraint country_pk primary key(country_id),
	constraint country_fk foreign key(region_id)
	references regions(region_id)
	on update cascade
	on delete cascade
);	
	
#create the table locations to store details of the locations   	
create table if not exists locations (	
	location_id int auto_increment,
	location_code int,
	street_address varchar(40) unique,
	postal_code varchar(12) default null,
	city varchar(30),
	state_province varchar(25) default null,
	country_id char(2),
	constraint location_pk primary key(location_id),
	constraint location_fk foreign key(country_id)
	references countries(country_id)
	on update cascade
	on delete cascade
);	
	
#create the table jobs to store details of each job	
create table if not exists jobs(	
	job_id int auto_increment,
	job_title varchar(40) unique,
	min_salary double (10,2) default 0,
	max_salary double (10,2) default 0,
	department_name varchar(50),
	Reports_to int,
	constraint job_pk primary key(job_id)
);	
	
#create the table departments to store details of each department	
create table if not exists departments(	
	department_id int auto_increment,
	department_name varchar(30),
	constraint department_pk primary key(department_id)
);	
	
#create the table employees to store details of each employee	
create table if not exists employees(	
	employee_id int,
	first_name varchar(30),
	last_name varchar(30),
	email varchar(40) unique,
	phone_number varchar(50),
	job_id int,
	salary double(10,2) default 0,
	Report_to int,
	location_id int,
	hire_date date,
	experience_at_VivaK int default 0,
	last_performance_rating double(10,2) default 0,
	salary_after_increment double(10,2) default 0,
	constraint employee_pk primary key(employee_id),
	constraint employee_fk foreign key(job_id)
	references jobs(job_id)
	on update cascade
	on delete cascade,
	constraint employee_fk2 foreign key(location_id)
	references locations(location_id)
	on update cascade
	on delete cascade
);	
	
#create the table dependents to store details of the dependents	
create table if not exists dependents(	
	dependent_id int auto_increment,
	first_name varchar(40),
	last_name varchar(40),
	relationship varchar(30),
	employee_id int,
	annual_dependent_benefit double(10,2) default 0,
	constraint dependent_pk primary key(dependent_id),
	constraint dependent_fk foreign key(employee_id)
	references employees(employee_id)
	);	
    
  ---------------------------------------------------------------------	
#insert data into table regions from schema HR	
insert into vivakhr.regions	
select * from hr.regions;	
----------------------------------------------------------------------	
#insert data into table countries from schema HR	
insert into vivakhr.countries	
select * from hr.countries;	
------------------------------------------------------------------------	
#insert data into table locations from schema HR	
insert into vivakhr.locations(location_code, street_address, postal_code, city, state_province,	
country_id)	
select * from hr.locations;	
---------------------------------------------------------------------------------------	
#insert data into table jobs. uploaded csv file to HR schema. 	
insert into vivakhr.jobs(job_id, job_title, min_salary, max_salary, department_name)	
select job_id, job_title, min_salary, max_salary, department_name from hr.jobs;	
	
update vivakhr.jobs	
inner join hr.jobs on hr.jobs.job_id=vivakhr.jobs.job_id	
set vivakhr.jobs.Reports_to = hr.jobs.Reports_to	
where vivakhr.jobs.job_id >1;	
-----------------------------------------------------------------------------------------	
#insert data into table departments by uploading csv file	
select * from  vivakhr.departments;	
---------------------------------------------------------------------------------------	
#insert data into table employees by uploading jsaon file	
	
insert into vivakhr.employees(employee_id, first_name, last_name, email, phone_number, job_id, salary,	
 location_id, hire_date)	
select employee_id, first_name, last_name, email, phone_number, job_id, salary,	
department_id, hire_date from hr.employees;	
------------------------------------------------------------------------------------	
#insert data into table dependents.	
alter table dependents	
drop foreign key dependent_fk;	
	
insert into vivakhr.dependents(first_name, last_name, relationship,employee_id)	
select first_name, last_name, relationship,employee_id from hr.dependent;	
	
alter table dependents	
add constraint dependent_fk foreign key(employee_id)	
references employees(employee_id);	
-------------------------------------------------------------------------	
#Handle duplicates	
# check table regions for duplicate	
select distinct region_name,count(region_name) from regions	
group by region_name	
having  count(region_name) >1;	
	
#Table locations has two columns with same types of data; location id and location code. 	
#hence, location code was removed as its duplicate	
	
Alter table locations	
drop column location_code;	
	
select distinct street_address, count(street_address) from locations	
group by street_address	
having count(street_address) >1;	
	
#check table departments for duplicates	
select distinct department_name, count(department_name) from departments	
group by department_name	
having count(department_name)>1;	
	
#check table employees for duplicates	
select distinct email, count(email) from employees	
group by email	
having count(email)>1;

select distinct phone_number, count(phone_number) from employees	
group by phone_number	
having count(phone_number)>1;
---------------------------------------------------------------------------	
#Format data - floating data point	
	
#table jobs	
show columns from jobs	
where field in ('min_salary', 'max_salary');	
	
#table employees	
show columns from employees	
where field in ('salary', 'last_performance_rating','salary_after_increment');	
	
#table dependents	
show columns from dependents	
where field =  'annual_dependent_benefit';	
------------------------------------------------------------------------------------------	
#Format data - phone number from table employees	

create temporary table employees_phn as	
select employee_id, phone_number, country_id	
from employees e	
inner join locations l on e.location_id = l.location_id;	

create temporary table employees_phn2 as	
select employee_id, phone_number,country_id, 	
case	
	when country_id ='US' then concat('+001','-',substr(phone_number,1,3),'-',substr(phone_number,5,3),'-',substr(phone_number,9,4))
    when country_id = 'UK' then concat('+044','-',substr(phone_number,1,3),'-',substr(phone_number,5,3),'-',substr(phone_number,9,4))	
    when country_id = 'DE' then concat('+045','-',substr(phone_number,1,3),'-',substr(phone_number,5,3),'-',substr(phone_number,9,4))	
    when country_id ='CA' then concat('+001','-',substr(phone_number,1,3),'-',substr(phone_number,5,3),'-',substr(phone_number,9,4))	
    else 0	
end as phn2	
from  employees_phn	;
	
update employees e	
inner join employees_phn2 phn2 on e.employee_id = phn2.employee_id	
set e.phone_number = phn2.phn2;	
---------------------------------------------------------------------------------------------	
#Formatting data - dates in 'yyy-mm-dd' fromat	
update employees	
set hire_date = date_format(hire_date, '%Y-%m-%d')	
where employee_id >0;	
---------------------------------------------------------------------------------------------	
#Treat Missing Values:	
#Fill up the report_to column by analyzing the available data.	
	
create temporary table employee_reportjob as
select e.employee_id, e.job_id, e.location_id,j.reports_to as manager_jobid  from employees e
inner join jobs j on e.job_id = j.job_id;    

create temporary table employee_reportjob2 as	
select er.employee_id, er.job_id, er.location_id,er.manager_jobid,	
case	
	when er.manager_jobid = 1 then 100
	else e.employee_id
end as manager_id	
from employee_reportjob er	
left join employees e on e.job_id=er.manager_jobid and e.location_id = er.location_id;	
	
update employees e
inner join employee_reportjob2 er on e.employee_id = er.employee_id
set e.Report_to = er.manager_id;
--------------------------------------------------------------------------------	
#Treat Missing Values:	
#Devise a strategy to fill in the missing entries in the salary column. Justify your answers and state your assumptions.	
#no of employees has no salary	

select count(employee_id) from employees	
where salary = 0;	

create temporary table Tavg_salary as	
select distinct job_id, avg(salary) as avg_salary from employees	
group by job_id	
order by job_id;	
	
update employees	
inner join  Tavg_salary on  Tavg_salary.job_id=employees.job_id	
set employees.salary = Tavg_salary.avg_salary	
where employees.salary=0;	
	
-------------------------------------------------------------------------------------------	
#experience_at_VivaK: calculate the time difference (in months) between the hire date 	
#and the current date for each employee and update the column.	
	
update employees	
set employees.experience_at_VivaK = round((datediff(current_date(),hire_date)/30),0)	
where employee_id>0;	
-------------------------------------------------------------------------------------------	
#last_performance_rating: to test the system, 	
#generate a random performance rating figure (a decimal number with two decimal points between 0 and 10) 	
#for each employee and update the column.	
	
update employees	
set employees.last_performance_rating = round(RAND(),2)	
where employee_id>0;	
	
--------------------------------------------------------------------------------------------------	
#salary_after_increment: calculate the salary after the performance appraisal 	
#and update the column by using the following formulas	
	
create temporary table T_increment as	
select e.employee_id, e.job_id, e.salary,e.location_id,e.experience_at_VivaK,e.last_performance_rating,	
case	
	when last_performance_rating >=0.9 then salary*(1+(0.01*experience_at_VivaK)+0.15)
	when last_performance_rating >=0.8 then salary*(1+(0.01*experience_at_VivaK)+0.12)
	when last_performance_rating >=0.7 then salary*(1+(0.01*experience_at_VivaK)+0.10)
	when last_performance_rating >=0.6 then salary*(1+(0.01*experience_at_VivaK)+0.08)
	when last_performance_rating >=0.5 then salary*(1+(0.01*experience_at_VivaK)+0.15)
	when last_performance_rating <0.5 then salary*(1+(0.01*experience_at_VivaK)+0.02)
	else 0
end as increment_salary, j.max_salary as max_salary	
from employees e	
inner join jobs j on j.job_id = e.job_id;	

create temporary table T_increment2 as	
select ti.employee_id, ti.job_id, ti.salary,ti.location_id,ti.experience_at_VivaK,	
ti.last_performance_rating, ti.increment_salary, ti.max_salary,	
case 	
	when increment_salary>max_salary then max_salary 
	else increment_salary
end as annual_increment	
from T_increment ti;	
	
update employees 	
inner join  T_increment2 on  T_increment2.employee_id=employees.employee_id	
set employees.salary_after_increment = T_increment2.annual_increment	
where employees.employee_id>0;	
----------------------------------------------------------------------------------------------	
use vivakhr;

create temporary table D_benefit as	
select d.dependent_id, d.employee_id, d.annual_dependent_benefit, 	
j.job_id, j.job_title, j.department_name, e.salary, 
case 	
	when j.department_name = 'Executive' then 'executive'
    when right(trim(j.job_title),7) = 'Manager' then 'manager'
	else 'other'
end as title
from dependents d	
inner join employees e on d.employee_id = e.employee_id	
inner join jobs j on j.job_id = e.job_id;	

create temporary table D_benefit2 as
select dependent_id, employee_id, job_id, job_title, department_name, salary, title, 
case 	
	when title = 'Executive' then 0.2*salary*12
    when title = 'Manager' then 0.15*salary*12
	else 0.05*salary*12
end as benefit
from D_benefit;	

update dependents d
inner join d_benefit2 db on d.dependent_id = db.dependent_id
set d.annual_dependent_benefit = db.benefit;
--------------------------------------------------------------------------------------------------	
#email: Until recently, the employees were using their private email addresses, 	
#and the company has recently bought the domain VivaK.com. 	
#Replace employee email addressed to ‘<emailID>@vivaK.com’. 	
#emailID is the part of the current employee email before the @ sign.	
	
create temporary table email1	
select employee_id, concat(substring_index(email,'@',1),'@vivaK.com') as email2	
from employees;	
	
update employees 	
inner join  email1 on  email1.employee_id=employees.employee_id	
set employees.email = email1.email2	
where employees.employee_id>0;	
----------------------------------------------------------------------------------------------	
