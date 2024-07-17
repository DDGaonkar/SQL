SELECT * FROM sqltutorials.employees;

Truncate table sqltutorials.employees;

drop table sqltutorials.employees;

/*query to create a table in a database*/
CREATE TABLE sqltutorials.employees (
    emp_id INT NOT NULL AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,
    emp_department VARCHAR(50) NOT NULL,
    emp_salary DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    PRIMARY KEY (emp_id)
);

/*alter table sqltutorials.employee rename to sqltutorials.employees;*/

/*query to insert values in table*/
insert into sqltutorials.employees (emp_name, emp_department, emp_salary) values 
('Rose', 'HR', 1968),
('Angela', 'Sales', 3443),
('Frank', 'HR', 1608),
('Patrick', 'IT', 1345),
('Lisa', 'IT', 2330),
('Kimberly', 'IT', 4372),
('Bonnie', 'Sales', 1771),
('Micheal', 'Finance', 2017),
('Todd', 'Finance', 3396),
('Joe', 'Finance', 3573),
('Anshuman', 'Engineering', 3573),
('Rajesh', 'Finance', 2000),
('Nakul', 'Finance', 1800),
('Royce', 'IT', 3000),
('Neha', 'IT', 1500),
('Ajinkya', 'IT', 3200),
('Renuka', 'HR', 2800),
('Prerna', 'Sales', 2900),
('Chirantan', 'Sales', 1200);


/*alter table sqltutorials.employees auto_increment=10;*/

# current date 
select curdate();

/* query to find the maximum total earnings for all employees and the number of employees who have the maximum total earnings.*/
select emp_months*emp_salary as total_sal, count(*) as count_ 
from sqltutorials.employees 
group by total_sal
order by total_sal desc limit 1;

/*==============================================================================================================================*/
														/*Window Functions*/
select distinct emp_department as Department, sum(emp_salary) 
over (partition by emp_department) as Total_Salary
from sqltutorials.employees;

/*below query gives the same result as above query*/
select distinct emp_department as Department, sum(emp_salary) as Total_Salary
from sqltutorials.employees 
group by Department
order by Total_salary desc; 

/*Q. Query the name of the employee with highest salary in each department*/ 
/* using concept of CTE (Common Table Expression) here. 
In SQL, a Common Table Expression (CTE) is a temporary named result set defined within a single query. 
It acts like a virtual table that you can refer later in the same query. 
CTEs are a powerful tool for simplifying complex queries and improving readability.*/

/* using ROW_NUMBER()*/
select emp_id, emp_name, emp_department, emp_salary  
from  (select emp_id, emp_name, emp_department, emp_salary,
		row_number() over (partition by emp_department order by emp_salary desc) as ranked 
		from sqltutorials.employees) ranked_employees
where ranked = 1;                                                        

/* using RANK() */
with RankedEmployees as (
	select emp_id, emp_name, emp_department, emp_salary, 
    rank() over (partition by emp_department order by emp_salary desc) as ranked_salary
    from sqltutorials.employees
)
select emp_id, emp_name, emp_department, emp_salary
from rankedemployees 
where ranked_salary = 1;


/*Q. Query to calculate the cumulative salary for each department sorted by employee ID?*/
select emp_id, emp_department, emp_salary, 
sum(emp_salary) over (partition by emp_department order by emp_id) as cumulative_salary
from sqltutorials.employees
order by emp_department, emp_id;

/*Q. Who are the top three highest paid employees across all departments?*/
with rankedemployees as (
	select emp_id, emp_department, emp_salary,
	rank() over (partition by emp_department order by emp_salary desc) as ranked_salary
	from sqltutorials.employees
)
select emp_id, emp_department, emp_salary
from rankedemployees 
where ranked_salary <= 3;

/*Q. Query to count the number of employees in each department*/
select distinct emp_department, 
count(emp_id) over (partition by emp_department) as number_of_employees
from sqltutorials.employees;

/*Q. Which department has the highest salary expenditure? */
select distinct emp_department,
sum(emp_salary) over (partition by emp_department) as total_salary_expenditure
from sqltutorials.employees;

/*Q. Query to update the salary of employees in IT department by 5%*/
update sqltutorials.employees
set emp_salary = emp_salary * 1.05
where emp_department = 'IT';

/*Q. Query to find the employees with salary higher than the average salary (of IT department)*/
with avgsalary as (
select emp_id, emp_name, emp_department, emp_salary,
avg(emp_salary) over (partition by emp_department) as dept_avgsalary
from sqltutorials.employees
)
select emp_id, emp_name, emp_department, emp_salary, dept_avgsalary
from avgsalary 
where emp_salary > dept_avgsalary and emp_department = 'IT';

/*Q. Query the list of employees whose name starts with R*/
select emp_id, emp_name from sqltutorials.employees where left(emp_name, 1) = 'R';
select emp_id, emp_name from sqltutorials.employees where emp_name like 'r%';