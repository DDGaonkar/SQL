drop table sqltutorials.students;

create table sqltutorials.students (
student_id int primary key,
student_name varchar(50),
student_age int,
course_name varchar(100)
);

insert into sqltutorials.students(student_id, student_name, student_age, course_name) values 
(1, 'Ben', 21, 'Arts'),
(2, 'Siddhi', 22, 'BioTechnology'),
(3, 'Claudia', 23, 'Singing'),
(4, 'Nehul', 31, 'Business Analytics'),
(5, 'Alexa', 20, 'Political Science'),
(6, 'Royce', 22, 'Data Analytics'),
(7, 'Ajinkya', 27, 'Business Analytics'), 
(8, 'Aakanksha', 25, 'Cyber Security'), 
(9, 'Parvathi', 28, 'Data Analytics'),
(10, 'Renuka', 29, 'Business Analytics');
	
select * from sqltutorials.students;

drop table sqltutorials.courses;

create table sqltutorials.courses (
course_id int primary key,
course_name varchar(100)
);

insert into sqltutorials.courses(course_id, course_name) values
(101, 'BioTechnology'),
(102, 'Business Analytics'),
(103, 'Data Analytics'),
(104, 'Cyber Security'),
(105, 'Artifical Intelligence');

select * from sqltutorials.courses;


/* UNION */
/*Combine name of courses from students and courses tables enruring no duplicates*/

select course_name as Course_Name from sqltutorials.courses 
UNION
select course_name as Course_Name from sqltutorials.students; 

/*UNION ALL*/
/*Combine name of courses from students and courses table including duplicates*/
select course_name as Course_Names from sqltutorials.courses
UNION ALL
select course_name as Course_Names from sqltutorials.students;

/*INTERSECT*/
/*Find the courses that exists in both students and courses tables*/
select course_name from sqltutorials.students 
INTERSECT
select course_name from sqltutorials.courses;

/*EXCEPT*/
/*Find courses that are in students table but not in courses table*/
select course_name from sqltutorials.students 
EXCEPT 
select course_name from sqltutorials.courses;

/*Find courses that are in courses table but not in students table*/
select course_name from sqltutorials.courses 
EXCEPT 
select course_name from sqltutorials.students;

/*==============================================================================================================================*/
														/*Stored Procedures*/
delimiter $$
create procedure sqltutorials.All_Courses()
begin
	select course_name from sqltutorials.courses;
end $$
delimiter ;

call sqltutorials.All_Courses();

drop procedure sqltutorials.Fetch_Students;

delimiter $$
create procedure sqltutorials.Fetch_Students(in courseName varchar(100))
begin
	select student_id, student_name from sqltutorials.students
    where course_name = courseName;
end $$
delimiter ;

call sqltutorials.Fetch_Students('Data Analytics');

