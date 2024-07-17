select * from sqltutorials.students; 

/*Q. Retrieve the names of students along with the names of the courses they are enrolled in.......................*/
select s.student_id, s.name, s.age, (select c.course_name from sqltutorials.courses as c where c.course_id = s.course_id) as course_name
from sqltutorials.students as s; 

/*Q. Find the students who have the highest age in their respective courses..................*/
select s1.name, s1.course_id, s1.age 
from sqltutorials.students as s1 
where s1.age = (
	select max(s2.age) 
    from sqltutorials.students as s2 
    where s2.course_id = s1.course_id
    );
    
/*Q. Find the average age of students enrolled in each course............................*/
select c.course_name as Course_Name, avg(subquery.age) as Average_age
from (select course_id, age from sqltutorials.students) as subquery
join sqltutorials.courses as c on c.course_id = subquery.course_id
group by c.course_name;


/*Q. Fetch alternate records - even reccords*/
select student_id 
from (select rowno, student_id from sqltutorials.students) as subquery
where mod(rowno, 2)=0;