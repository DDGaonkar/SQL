Create table If Not Exists sqltutorials.Person (id int, email varchar(255)); 

Truncate table sqltutorials.Person;

insert into sqltutorials.Person (id, email) values ('1', 'a@b.com');
insert into sqltutorials.Person (id, email) values ('2', 'c@d.com');
insert into sqltutorials.Person (id, email) values ('3', 'a@b.com');

/*write a query to report all duplicate emailids*/

select distinct a.email email
from sqltutorials.person a, sqltutorials.person b 
where a.email = b.email and a.id != b.id;