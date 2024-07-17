/* ---------------------------------- Arithmetic Functions ---------------------------------- */

select abs(-10) as result;

-- CEIL(x) or CEILING(x) returns the smallest integer, greater than or equal to 'x'
select ceiling(4.3) as result;

select ceil(4.3) as result;

-- FLOOR(x) returns the largest integer less than or equal to 'x'
select floor(4.3) as result;

-- ROUND(x, d) returns 'x' rounded to 'd' decimal places
select round(123.456, 2) as result;

-- TRUNCATE(x, d) returns 'x' truncated to 'd' decimal places
select truncate(123.456, 2) as result; 

-- SIGN(x) returns the sign of x
select sign(-10) as result;
select sign(0) as result;
select sign(10) as result;

/* ---------------------------------- Aggregate Functions ---------------------------------- */

-- SUM(x) returns the sum of x
select sum(age) as Total_Age from sqltutorials.students;

-- AVG(x) returns the average value of x
select avg(age) as Average_Age from sqltutorials.students;

-- MIN(x) returns the minimum value of x
select min(age) as Minimum_Age from sqltutorials.students;

-- MAX(x) returns the maximum value of x
select max(age) as Maximum_Age from sqltutorials.students;

-- COUNT(x) returns the number of rows with non-NULL values for x
select count(student_id) as Total_Students from sqltutorials.students; 

/* ---------------------------------- Logarithmic and Exponential Functions ---------------------------------- */

-- EXP(x) returns 'e' raised to the power of x
select exp(1) as result;

-- LOG(x) or LN(x) returns the natural logarithm of x
select log(10) as result;
select ln(10) as result;

-- LOG10(x) returns the base-10 logarithm of x
select log10(100) as result;

-- POW(x, y) or POWER(x, y) returns x to the power of y
select pow(10, 2) as result;
select power(10, 2) as result;

-- SQRT(x) returns the square root of x
select sqrt(100) as result;

/* ---------------------------------- Other Functions ---------------------------------- */

-- PI() returns the value of π.
select pi() as pi_value;

-- RADIANS(x) converts degrees to radians
select radians(180) as radians_value;

-- DEGREES(x) converts radians to degrees
select degrees(pi()) as degrees_value;

-- MOD(x, y) returns the remainder of x divided by y
select mod(10, 3) as result;

-- RAND() returns a random floating point value between 0 and 1
select rand() as random_value;

-- GREATEST(x1, x2, x3, ...) returns the greatest value among the provided arguments
select greatest(1, 2, 3, 5, 6) as greatest_value;

-- LEAST(x1, x2, x3, ...) returns the least value among the provided arguments
select least(1, 2, 3, 4, 5) as least_value;

