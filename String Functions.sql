CREATE TABLE sqltutorials.products (
  product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(50) NOT NULL
);

INSERT INTO sqltutorials.products (product_name, description, price, category) VALUES
('Laptop', 'High performance laptop', 1200.00, 'Electronics'),
('Smartphone', 'Latest model smartphone', 800.00, 'Electronics'),
('Headphones', 'Noise-cancelling headphones', 150.00, 'Accessories'),
('Coffee Maker', 'Automatic coffee maker', 90.00, 'Home Appliances'),
('Blender', 'High speed blender', 60.00, 'Home Appliances'),
('Desk Chair', 'Ergonomic desk chair', 120.00, 'Furniture'),
('Office Desk', 'Spacious office desk', 300.00, 'Furniture'),
('Monitor', '4K Ultra HD monitor', 400.00, 'Electronics'),
('Keyboard', 'Mechanical keyboard', 70.00, 'Accessories'),
('Mouse', 'Wireless mouse', 30.00, 'Accessories'),
('Electric Kettle', 'Fast boiling electric kettle', 40.00, 'Home Appliances'),
('Microwave', 'Compact microwave oven', 100.00, 'Home Appliances'),
('Toaster', '2-slice toaster', 25.00, 'Home Appliances'),
('Smart Watch', 'Waterproof smart watch', 200.00, 'Wearables'),
('Fitness Tracker', 'Multi-function fitness tracker', 50.00, 'Wearables'),
('Printer', 'All-in-one wireless printer', 150.00, 'Office Supplies'),
('Router', 'High-speed wireless router', 100.00, 'Networking'),
('External Hard Drive', '1TB external hard drive', 80.00, 'Storage'),
('Webcam', 'HD webcam', 60.00, 'Accessories'),
('Tablet', '10-inch tablet', 250.00, 'Electronics'),
('Bluetooth Speaker', 'Portable Bluetooth speaker', 70.00, 'Audio'),
('Smart Home Hub', 'Voice-controlled smart home hub', 180.00, 'Smart Home');

select * from sqltutorials.products;

-- converting product names to lower case
select lcase(product_name) as product_names_lowercase from sqltutorials.products;
select lower(product_name) as product_names_lowercase from sqltutorials.products;

-- converting product names to upper case
select ucase(product_name) as product_names_uppercase from sqltutorials.products;
select upper(product_name) as product_names_uppercase from sqltutorials.products;

-- reverse the product names 
select reverse(product_name) as product_names_reversed from sqltutorials.products;

-- extract substring from the product names starting at position 1 and extracting upto 3 characters
select substring(product_name, 1, 3) as product_names_substring from sqltutorials.products;
select substr(product_name, 1, 3) as product_names_substring from sqltutorials.products;

-- left/right pad the product names 
select lpad(product_name, 20, "-") as product_names_lpad from sqltutorials.products;
select rpad(product_name, 20, "-") as product_names_lpad from sqltutorials.products;

select strcmp((select product_name from sqltutorials.products limit 0, 1), (select product_name from sqltutorials.products limit 1, 1));
/* limit 0, 1 means row no 1 and limit 1, 1 means row no 2 */

select strcmp("Laptop", "Smartphone"); -- output -1
select strcmp("Saptop", "Lmartphone"); -- output 1
select strcmp("Saptop", "Smartphone"); -- output -1
select strcmp("Laptop", "Smartphone"); -- output -1
select strcmp("Laptop", "Laptop"); -- output 0

-- Q. calculate the total value of all products in the inventory..................
select sum(price) as Total_value from sqltutorials.products;

-- Q. find the average price of products in each category..................
-- using group by
select category, avg(price) as average_price from sqltutorials.products group by category;

-- using windows function
select distinct category, avg(price) over (partition by category) as average_price from sqltutorials.products;

-- Q. retrieve the highest and lowest priced products..................
select max(price) as highest_price, min(price) as lowest_price from sqltutorials.products;

select product_name, price 
from sqltutorials.products
where price = (select max(price) from sqltutorials.products) or
price = (select min(price) from sqltutorials.products);


SELECT product_name, price,
  CASE
    WHEN price = (SELECT MAX(price) FROM sqltutorials.products) THEN 'Highest Price'
    WHEN price = (SELECT MIN(price) FROM sqltutorials.products) THEN 'Lowest Price'
    ELSE 'Other'
  END AS price_category
FROM sqltutorials.products
WHERE price = (SELECT MAX(price) FROM sqltutorials.products) OR
      price = (SELECT MIN(price) FROM sqltutorials.products);
      
-- Q. get the absolute difference between the highest and the lowest product prices..................
select abs(max(price) - min(price)) as price_difference from sqltutorials.products;

-- Q. find the products where the price of the products is greater than the average price..................
select product_name, price 
from sqltutorials.products 
where price > (select avg(price) from sqltutorials.products);


-- Q. find the length of each product length..................
select product_name, length(product_name) as length_of_pname from sqltutorials.products; 

-- Q. find the products where the description contains the word 'high'..................
select product_name, description from sqltutorials.products where description like '%high%';



/* ---------------------------------------- intermediate level questions ---------------------------------------- */

-- Q. Retrieve the names and prices of products in the 'Electronics' category, sorted by price in descending order...................
select product_name, price 
from sqltutorials.products 
where category = 'ELectronics' 
order by price desc;

-- Q. Find the average price of products in each category and display only those categories where the average price is above $100...................
select category, avg(price) as avg_price 
from sqltutorials.products 
group by category 
having avg_price > 100; 

-- Q. List the product names and prices for products whose price is within 10% of the highest price in the table...................
select product_name, price 
from sqltutorials.products 
where price >= (select max(price)*0.9 from sqltutorials.products);

-- Q. Find the second highest priced product..................
select product_name, Price 
from sqltutorials.products 
where price = (select distinct price from sqltutorials.products order by price desc limit 1, 1); 

-- Q. Count the number of products in each category that have a price above the average price of all products...................
select category, count(product_name) as count_of_products 
from sqltutorials.products 
where price > (select avg(price) from sqltutorials.products) 
group by category ;

-- Q. Retrieve the product names and prices of the three most expensive products in each category..................
select product_name, price 
from sqltutorials.products 
where price > (select distinct price from sqltutorials.products order by price desc limit 3, 1);

-- using window function
select product_name, price 
from (
	select product_name, price, row_number() over (order by price desc) as rnk
    from sqltutorials.products
) ranked
where rnk <= 3; 

select category, product_name, price, row_number() over (partition by category order by price desc) as rnk
    from sqltutorials.products;
-- adding partition by would rank the products within each category

-- top 3 prices
select distinct price from sqltutorials.products order by price desc limit 0, 3;

select product_name, price from sqltutorials.products order by price desc limit 3;

-- Q. Find the total price of all products in each category and display the results in descending order of the total price............
select distinct category, sum(price) over (partition by category) as total_price 
from sqltutorials.products 
order by total_price desc;

select category, sum(price) as total_price 
from sqltutorials.products 
group by category 
order by total_price desc;

-- Q. Retrive the names of the products that have word 'smart' in their description ignoring case.............
select product_name, description 
from sqltutorials.products 
where lcase(description) like "%smart%";

-- Q. Display the product names, their categories, and their prices, but replace the category 'Electronics' with 'Gadgets'.............
select 
	product_name, 
	case when category = 'Electronics' then 'Gadgets' else category end as modified_category, 
    price
from sqltutorials.products;

-- Find the products that belong to categories that have more than 3 products listed.
select product_name, category 
from sqltutorials.products 
where category in (
	select category
	from sqltutorials.products 
	group by category
	having count(product_name) > 3
);
-- select * from sqltutorials.products;

-- truncate table sqltutorials.products; 

/* ---------------------------------------- questions on CASE keyword ---------------------------------------- */ 

-- Q. classify products into price ranges: 
-- 'Budget' for price below 100, 'Standard' for price between 100 and 300, 'Premium' for price above 300.....

select 
	*, 
	case 
		when price < 100 then 'Budget' 
        when price between 100 and 300 then 'Standard' 
        else 'Premium'
	end as price_range
from sqltutorials.products;
        
-- Q. Display categories and number of products in each caegory for the price ranges below 100, between 100 and 300, above 300

select 
	category, 
    sum(case when price < 100 then 1 else 0 end) as 'Below 100',
    sum(case when price between 100 and 300 then 1 else 0 end) as 'Between 100 and 300', 
    sum(case when price > 300 then 1 else 0 end) as 'Above 300'
from sqltutorials.products 
group by category;

-- Add a column to categorize products based on their category: 
-- 'Tech' for 'Electronics' and 'Accessories', 'Home' for 'Home Appliances' and 'Furniture', and 'Other' for all other categories.

select 
	product_name, 
    case 
		when category in ('Electronics', 'Accessories', 'Audio') then 'Tech'
		when category in ('Home Appliance', 'Furniture') then 'Home'
	end as category
from sqltutorials.products;

select * from sqltutorials.products;

/* ---------------------------------------- questions on LIMIT and OFFSET keyword ---------------------------------------- */ 

-- Q. Retrieve the first 5 products sorted by price in ascending order.......
select product_name, price 
from sqltutorials.products 
order by price asc 
limit 5;

-- Q. Retrieve the next 5 products (10th to 15th) sorted by price in ascending order...............
select product_name, price 
from sqltutorials.products 
order by price asc 
limit 6 offset 9; -- or limit 9, 6


-- Q. Display every other product (e.g., 1st, 3rd, 5th, etc.) when sorted by product name......................

select 
	product_name, 
    rnk
from 
	(select 
		product_name, 
		row_number() over (order by product_name asc) as rnk
	from sqltutorials.products) ordered
where mod(rnk, 2) = 1;


-- Q. Identify the second lowest priced product in each category.......
select category, product_name, price, rnked 
from (
	select 
		category, 
		product_name, 
		price, 
		row_number() over (partition by category order by price asc) as rnked
	from sqltutorials.products) ordered
where rnked = 2;

with cte_table as (
	select 
		category, 
		product_name, 
		price, 
		row_number() over (partition by category order by price asc) as rnked
	from sqltutorials.products)
select category, product_name, price, rnked 
from cte_table 
where rnked = 2;

-- Q. Find the products that have the same price as any other product 
-- (i.e., list all products that share their price with at least one other product).............. 
SELECT product_name, price
FROM sqltutorials.products p1
WHERE EXISTS (
    SELECT 1
    FROM sqltutorials.products p2
    WHERE p1.price = p2.price AND p1.product_id <> p2.product_id)
order by price; 

select p1.product_name, p1.price, p2.product_name, p2.price
from sqltutorials.products as p1 
left join sqltutorials.products as p2 
on p1.price = p2.price 
where p1.price = p2.price and p1.product_id < p2.product_id; 

select * from sqltutorials.products;