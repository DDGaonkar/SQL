/*query to create a database*/
create database sqltutorials;

/*query to create a table in a database*/
CREATE TABLE sqltutorials.employee (
    new_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary DECIMAL(10 , 2 )
);

/*query to insert values in table*/
insert into sqltutorials.employee (new_id, name, salary) values 
(1, 'Ram', 100000.00),
(2, 'Laxman', 90000.00),
(3, 'Shyam', 120000.00),
(4, 'Gajodhar', 110000.00),
(5, 'Anshuman', 30000);

/* query to change the table name*/
alter table sqltutorials.employee rename to sqltutorials.employees;

/*query to change a column name in a table*/
alter table sqltutorials.employees rename column new_id to employee_id;

/*window functions*/
select row_number() over (order by salary desc) as row_num, employee_id, salary from sqltutorials.employees;

CREATE TABLE sqltutorials.table1 (
    new_id INT,
    new_cat VARCHAR(10)
);

/*==============================================================================================================================*/
														/*Window Functions*/
insert into sqltutorials.table1 (new_id, new_cat) values 
(100, 'Agni'),
(200, 'Agni'),
(500, 'Dharti'),
(700, 'Dharti'),
(200, 'Vayu'),
(300, 'Vayu'),
(500, 'Vayu');
                                                        
select new_id, new_cat, 
sum(new_id) over (partition by new_cat order by new_id) as "Total",
avg(new_id) over (partition by new_cat order by new_id) as "Average",
count(new_id) over (partition by new_cat order by new_id) as "Count",
min(new_id) over (partition by new_cat order by new_id) as "Min",
max(new_id) over (partition by new_cat order by new_id) as "Max"
from sqltutorials.table1;

select distinct new_cat,
sum(new_id) over (partition by new_cat) as "Total"
from  sqltutorials.table1;


