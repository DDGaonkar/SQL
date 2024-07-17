drop table sqltutorials.students;

create table sqltutorials.students (
student_id int primary key,
name varchar(100), 
age int, 
course_id int 
);

drop table sqltutorials.courses;

create table sqltutorials.courses (
course_id int primary key,
course_name varchar(100)
);

insert into sqltutorials.courses(course_id, course_name) values
(101, 'Math'),
(102, 'History'),
(103, 'Science'),
(104, 'Geography'),
(105, 'Music'),
(106, 'Language'),
(107, 'Computer Science'),
(108, 'Craft'),
(109, 'Art');


insert into sqltutorials.students(student_id, name, age, course_id) values 
(1, 'Alice', 20, 101),
(2, 'Bob', 21, 102),
(3, 'Charlie', 20, NULL),
(4, 'David', 23, 103),
(5, 'Prerna', 25, 109),
(6, 'Chirantan', 29, 108),
(7, 'Royce', 24, 107),
(8, 'Renuka', 29, 106),
(9, 'Ajinkya', 28, 105),
(10, 'Srujan', 31, 104),
(11, 'Prachi', 26, 104),
(12, 'Shraddha', 32, 108),
(13, 'Nehal', 25, 103),
(14, 'Rahul', 27, 105),
(15, 'Aditya', 26, 109),
(16, 'Tarun', 22, 108),
(17, 'Manoj', 21, 107),
(18, 'Claudia', 20, 101),
(19, 'Ben', 19, 102),
(20, 'Sorcha', 20, 103);

insert into sqltutorials.students (student_id, name, age, course_id) values
(21, 'Angel', 22, 103),
(22, 'Vandhita', 28, 108),
(23, 'Alexandra', 23, 107),
(24, 'Biljana', 27, 108);

select * from sqltutorials.students;
select * from sqltutorials.courses;

/*Q. Retrieve the names of students in alphabetical order......................*/
select * from sqltutorials.students order by name;

/*Q. Retrieve the names of students who are not enrolled in any course...........................*/
select student_id, name from sqltutorials.students where course_id is NULL;

/*Q. Retrieve the names of students along with the names of the courses they are enrolled in.......................*/
select student_id, name, age, course_name from sqltutorials.students as s 
left join sqltutorials.courses as c on s.course_id = c.course_id;

/*Q. Count the number of students enrolled in each course...................................*/
/*using concept of CTE (Common Table Expression) and group by*/

with cte_table as (
	select student_id, name, age, course_name from sqltutorials.students as s 
	left join sqltutorials.courses as c on s.course_id = c.course_id
)
select course_name, count(student_id) as No_of_Students
from cte_table group by course_name;

/*using CTE and windows function*/
with cte_table as (
	select student_id, name, age, course_name from sqltutorials.students as s 
	left join sqltutorials.courses as c on s.course_id = c.course_id
)
select course_name, count(student_id) 
over (partition by course_name) as No_of_Students 
from cte_table;

/*using just group by*/
select c.course_name, count(s.student_id) as student_count 
from sqltutorials.courses as c left join sqltutorials.students as s on s.course_id = c.course_id 
group by c.course_name;

/*Q. Find the average age of students enrolled in each course............................*/
select c.course_name as Course_Name, avg(s.age) as Average_Age 
from sqltutorials.courses as c left join sqltutorials.students as s on c.course_id = s.course_id
group by c.course_name;

/*Q. Find the names of students who are enrolled in the same course as 'Alice'......................*/
select student_id, name from sqltutorials.students where course_id in 
(select course_id from sqltutorials.students where name = 'Alice');

/*Q. Rank the students by their age within each course.......................*/
select name, course_id, age,  
row_number() over (partition by course_id order by age) as ranked_by_age
from sqltutorials.students;

with cte_table as (
select s.student_id, s.name, s.age, c.course_name 
from sqltutorials.students as s left join sqltutorials.courses as c on s.course_id = c.course_id
)
select student_id, name, age, course_name, 
row_number() over (partition by course_name order by age) as ranked_by_age 
from cte_table;




/*Q. Using a CTE, find the courses with more than 3 students enrolled and list the course names along with the number of enrolled students....................*/
with cte_table as (
select c.course_name, count(s.student_id) as student_count
from sqltutorials.courses as c left join sqltutorials.students as s 
on c.course_id = s.course_id
group by c.course_name
)
select course_name, student_count from cte_table 
where student_count > 3;

/*Q. Pivot the data to show the number of students enrolled in each course, with age ranges (e.g., 10-20, 21-30, etc.) as columns.......*/
select course_name, 
	sum(case when age between 11 and 20 then 1 else 0 end) as "11-20",
    sum(case when age between 21 and 30 then 1 else 0 end) as "21-30"
from (
	select s.student_id, s.name, s.age, s.course_id, c.course_name 
    from sqltutorials.students as s left join sqltutorials.courses as c
	on s.course_id = c.course_id
) as subquery
group by course_name;

/*Q. Indexing............*/
desc sqltutorials.students;

create index idx_composite on sqltutorials.students(student_id, course_id);

create index idx_course_id on sqltutorials.courses(course_id);


