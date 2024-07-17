drop table sqltutorials.students;

create table sqltutorials.students (
student_id int primary key,
student_name varchar(20),
score int
);

select * from sqltutorials.students;

insert into sqltutorials.students(student_id, student_name, score) values 
(1, 'Jake', 50),
(2, 'Sasha', 45),
(3, 'Claudia', 60),
(4, 'Sorcha', 66),
(5, 'Alexa', 78);

drop procedure sqltutorials.fetchScore;

delimiter //
create procedure sqltutorials.fetchScore (in stu_name varchar(20), out score int)
begin
	select score 
    into score 		
    from sqltutorials.students 
    where student_name = stu_name;
end //
delimiter ;
						
																																
call sqltutorials.fetchScore('Claudia', score);
select score;