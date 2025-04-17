# =============================================================================================================================
# =============================================================================================================================
# Data preprocessing 
# =============================================================================================================================
# =============================================================================================================================


# _____________________________________________________________________________________________________________________________
# Creating a new table `location lookup` to normalize table `superstore`

create table `location lookup` as 
select 
	`country`, `state`, `city`, `postal code`
from `superstore`
group by `country`, `state`, `city`, `postal code`
order by `country`, `state`, `city`, `postal code`;

-- Adding a new index column in table `location lookup` 
alter table `location lookup`
add column `Location Id` varchar(10);


update `location lookup` as `loc lookup`
set `location id` = (
	select 
		concat("L", rn)
    from (
		select 
			`country`, `state`, `city`, `postal code`, 
            row_number() over () as rn
		from `location lookup`
        group by `country`, `state`, `city`, `postal code`
        order by `country`, `state`, `city`, `postal code`
	) as derived
    where
	`loc lookup`.`country` = `derived`.`country` and 
        `loc lookup`.`state` = `derived`.`state` and 
        `loc lookup`.`city` = `derived`.`city` and 
        `loc lookup`.`postal code` = `derived`.`postal code`
);

-- Method 2: soon to be depricated!
-- set @row_number = 0;

-- update `location lookup`
-- set `location id` = 
-- concat("L", (@row_number := @row_number + 1))
-- order by `country`, `state`, `city`;

-- Setting `location id` as primary key
alter table `location lookup`
add primary key (`location id`);

-- ----------------------------------------------------------------------------------------------------------------------------
-- Adding a new column in table `location lookup`

-- below queries shows that the columns `region` and `location id` are corelated 
select distinct `location id`
from `superstore`
where `region` = "south"
intersect 
select distinct `location id`
from `superstore`
where `region` = "west";

-- here we are trying to find if there are multiple regions associated against each location id
select 
	`location id`, 
    count(distinct `region`) as `distinct regions`
from `superstore`
group by `location id`
having `distinct regions` > 1;

-- column `region` needs to be moved to table `location lookup`
-- created a new column in table `location lookup`
alter table `location lookup`
add column `region` text;

-- updated the new column with appropriate value
update `location lookup` as `loc`
set `region` = (
	select distinct `region`
    from `superstore` as `super`
    where `loc`.`location id` = `super`.`location id`
);

-- -----------------------------------------------------------------------------------------------------------------------------
-- Rearranging the position of columns in table `location lookup`

alter table `location lookup`
	modify column `location id` varchar(10) first;

alter table `location lookup`
	modify column `region` text after `country`;

# _____________________________________________________________________________________________________________________________
# Creating a new table `order lookup` to normalize table `superstore`

-- Below query suggests that there is only one unique `order date` against each `order id`
-- Similarly there exists only one `ship date` and `ship mode` against each `order id`
select 
	`order id`, 
    count(distinct `ship mode`) as `distinct values` 
from `superstore`
group by `order id`
having `distinct values` > 1;

-- Creating a new table called `order lookup`
create table `order lookup` as 
select 
	`order id`, `order date`, `ship date`, `ship mode`
from `superstore`
group by `order id`, `order date`, `ship date`, `ship mode`
order by `order id`, `order date`, `ship date`, `ship mode`;


# _____________________________________________________________________________________________________________________________
# Preprocessing table `order lookup`

-- changing data type of `order id` column
alter table `order lookup`
modify column `order id` varchar(20);

-- updating new date values over old date values
update `order lookup`
	set `order date` = str_to_date(`order date`, '%d-%m-%Y');

update `order lookup`
	set `ship date` = str_to_date(`ship date`, '%d-%m-%Y');

-- making `order id` as the primary key
alter table `order lookup`
add primary key (`order id`); 


# _____________________________________________________________________________________________________________________________
# Preprocessing table `customer lookup`

-- Changing the data type of column `customer id` as we have the make it a Primary Key. 

-- ! Note: text column cannot be marked as Primary Key. 

alter table `customer lookup`
modify column `customer id` varchar(10);

-- Creating primary key
alter table `customer lookup` 
add primary key (`customer id`); 

# _____________________________________________________________________________________________________________________________
# Preprocessing table `product lookup`

-- Table `product lookup` contains duplicate records for `product id` column. There are multiple `product name` values associated to the same `product id`. 
select 
	`product id`, 
    `category`,
    `sub-category`, 
    count(*)
from `product lookup`
group by `product id`, `category`, `sub-category`
having count(*) > 1
order by `product id`;

-- To resolve this I concatenated the different `product name` values as a single record. 
-- Creating a temp table to store the final data
create table `product lookup clone` as 
select
	`product id` as `Product Id`, 
    `category` as `Category`, 
    `sub-category` as `Sub-Category`, 
    group_concat(`product name` separator ", ") as `Product Name`
from `product lookup`
group by `product id`, `category`, `sub-category`;

-- Dropping the original table with duplicate records
drop table `product lookup`;

-- Transfering the desired data from the clone table to the newly created `product lookup` table
create table `product lookup` as 
select * from `product lookup clone`;

-- Changing the data type of column `product id` as we have to make it a Primary Key. 
-- ! Note: text column cannot be marked as Primary Key. 
alter table `product lookup`
modify column `product id` varchar(20);

-- setting `product id` as primary key
alter table `product lookup`
add primary key (`product id`);

drop table `product lookup clone`;


# _____________________________________________________________________________________________________________________________
# Preprocessing table `superstore`

-- ----------------------------------------------------------------------------------------------------------------------------
-- Changing data types of columns

-- Changing the data type of column `customer id` in table `superstore`. 
alter table superstore
modify column `customer id` varchar(10);

-- Changing the data type of column `product id` in table `superstore`. 
alter table `superstore`
modify column `product id` varchar(20);

-- Changing the data type of column `order id` in table `superstore`
alter table `superstore`
modify column `order id` varchar(20);

-- -----------------------------------------------------------------------------------------------------------------------------
-- Adding a new column `Profit or Loss` in table `superstore`

alter table `superstore`
add column `Profit or Loss` varchar(10); 

-- Populate the new column
update `superstore`
set `Profit or Loss` =
	case
		when profit < 0 then "Loss"
        when profit > 0 then "Profit"
        else "None"
    end;

-- -----------------------------------------------------------------------------------------------------------------------------
-- Adding a new column `Location Id` to replace location specific columns from table `superstore`

alter table `superstore`
add column `Location Id` varchar(10);

update `superstore` `super`
set `location id` = (
	select 
		`location id`
    from `location lookup` as `loc`
    where
		`super`.`country` = `loc`.`country` and 
        `super`.`state` = `loc`.`state` and 
        `super`.`city` = `loc`.`city` and 
        `super`.`postal code` = `loc`.`postal code`
);

-- Dropping unnecessary columns from table `superstore`
alter table `superstore`
	drop column `country`, 
	drop column `state`, 
	drop column `city`, 
    drop column `postal code`;
    
alter table `superstore`
	drop column `region`;
    
alter table `superstore`
	drop column `order date`, 
	drop column `ship date`, 
	drop column `ship mode`;

-- -----------------------------------------------------------------------------------------------------------------------------
-- Changing the position of columns in table `superstore`

alter table `superstore`
modify column `location id` varchar(10) after `segment`;

# _____________________________________________________________________________________________________________________________
# Creating relationships between tables

-- Creating relationship between tables `superstore` and `customer lookup`
alter table `superstore`
add constraint fk_superstore_customer
foreign key (`customer id`)
references `customer lookup`(`customer id`) on delete cascade;

-- ! Note: before setting a field as a foreign key in host table that field needs to be a primary key in it's parent table. 

-- Creating relationship between table `superstore` and `customer lookup`
alter table `superstore`
add constraint fk_superstore_product
foreign key (`product id`)
references `product lookup`(`product id`) on delete cascade;

-- creating relationship between table `superstore` and `location lookup`
alter table `superstore`
add constraint fk_superstore_location
foreign key (`location id`)
references `location lookup`(`location id`) on delete cascade;

-- creating relationship between table `superstore` and `order lookup`
alter table `superstore`
add constraint fk_superstore_order
foreign key (`order id`)
references `order lookup`(`order id`) on delete cascade;

# =============================================================================================================================
# =============================================================================================================================
# Key Performance indicators
# =============================================================================================================================
# =============================================================================================================================

# _____________________________________________________________________________________________________________________________
# Total Sales
select round(sum(`sales`), 2) as `Total Sales`
from `superstore`;

# _____________________________________________________________________________________________________________________________
# Total Orders
select count(distinct `order id`) from `superstore`;

# _____________________________________________________________________________________________________________________________
# Total Profit
select round(sum(`profit`), 2)
from `superstore`
where `profit or loss` = "Profit";

# _____________________________________________________________________________________________________________________________
# Total Loss
select abs(round(sum(`profit`), 2))
from `superstore`
where `profit or loss` = "Loss";

# =============================================================================================================================
# =============================================================================================================================
# Sales analysis
# =============================================================================================================================
# =============================================================================================================================

# _____________________________________________________________________________________________________________________________
# Categorization of Order Ids as per Profit, Loss and None
select 
	`profit or loss` as `Category`,
	count(distinct `order id`) as `Distinct Order ids`, 
    concat(round(count(distinct `order id`)*100/(select count(distinct `order id`) from `superstore`), 2), "%") as `Percentage proportion`
from `superstore` 
group by `Category`;
-- +----------+--------------------+-----------------------+
-- | Category | Distinct Order ids | Percentage proportion |
-- +----------+--------------------+-----------------------+
-- | Loss     |               1318 | 26.31%                |
-- | None     |                 64 | 1.28%                 |
-- | Profit   |               4407 | 87.98%                |
-- +----------+--------------------+-----------------------+

-- as we can see the percentage proportions exceeds 100 suggesting that there are few order ids with one product incurring profit and other incurring loss or none.
select distinct `order id` from `superstore` where `profit or loss` = "Profit" intersect
select distinct `order id` from `superstore` where `profit or loss` = "Loss" intersect 
select distinct `order id` from `superstore` where `profit or loss` = "None"


# _____________________________________________________________________________________________________________________________
# Total Sales each year

select 
	year(`ol`.`order date`) as `Year`, 
    round(sum(`s`.`sales`), 2) as `Total Sales`
from `superstore` `s`
join `order lookup` `ol` on `s`.`order id` = `ol`.`order id`
group by `Year`
order by `Year`;
-- +------+-------------+
-- | Year | Total Sales |
-- +------+-------------+
-- | 2014 |    484247.5 |
-- | 2015 |   470532.51 |
-- | 2016 |    609205.6 |
-- | 2017 |   733215.26 |
-- +------+-------------+

# _____________________________________________________________________________________________________________________________
# Year Over Year sales growth

with cte as (
	select 
		year(`ol`.`order date`) as `Year`, 
		round(sum(`s`.`sales`), 2) as `Total Sales`
	from `superstore` `s`
	join `order lookup` `ol` on `s`.`order id` = `ol`.`order id`
	group by `Year`
	order by `Year`
)
select 
	`c2`.`year` as `Current Year`, 
    `c1`.`year` as `Previous Year`, 
    concat(round((`c2`.`total sales` - `c1`.`total sales`)/`c1`.`total sales` * 100, 2), "%") as `YOY Sales Growth`
from `cte` `c1`
join `cte` `c2`on `c1`.`year` = `c2`.`year`-1; 
-- +--------------+---------------+------------------+
-- | Current Year | Previous Year | YOY Sales Growth |
-- +--------------+---------------+------------------+
-- |         2015 |          2014 | -2.83%           |
-- |         2016 |          2015 | 29.47%           |
-- |         2017 |          2016 | 20.36%           |
-- +--------------+---------------+------------------+

# =============================================================================================================================
# =============================================================================================================================
# Customer Analysis
# =============================================================================================================================
# =============================================================================================================================

# _____________________________________________________________________________________________________________________________
# Top customers contributing to sales
select 
	t2.`customer id` as `Customer id`,
	t2.`customer name` as `Customer Name`, 
    round(sum(`sales`), 2) as `Total Purchase Amount`
from `superstore` as t1
left join `customer lookup` as t2 on t1.`customer id` = t2.`customer id`
group by `Customer id`, `Customer Name`
order by `Total Purchase Amount` desc 
limit 5;
-- +-------------+---------------+-----------------------+
-- | Customer id | Customer Name | Total Purchase Amount |
-- +-------------+---------------+-----------------------+
-- | SM-20320    | Sean Miller   |              25043.05 |
-- | TC-20980    | Tamara Chand  |              19052.22 |
-- | RB-19360    | Raymond Buch  |              15117.34 |
-- | TA-21385    | Tom Ashbrook  |              14595.62 |
-- | AB-10105    | Adrian Barton |              14473.57 |
-- +-------------+---------------+-----------------------+

# _____________________________________________________________________________________________________________________________
# Top customers contributing to sales from each region

with cte as (
	select 
		`ll`.`region` as `Region`, 
		`cl`.`customer id` as `Customer Id`, 
		`cl`.`customer name` as `Customer Name`,
		`s`.`sales` as `Total Sales`, 
		row_number() over (partition by `ll`.`Region` order by `s`.`sales` desc) as `Rank`
	from `superstore` as `s`
	join `location lookup` as `ll` on `s`.`location id` = `ll`.`location id`
	join `customer lookup` as `cl` on `s`.`customer id` = `cl`.`customer id`
)
select `Region`, `Customer Id`, `Customer Name`, `Total Sales`, `Rank`
from cte
where `Rank` = 1;
-- +---------+-------------+---------------+-------------+------+
-- | Region  | Customer Id | Customer Name | Total Sales | Rank |
-- +---------+-------------+---------------+-------------+------+
-- | Central | TC-20980    | Tamara Chand  |    17499.95 |    1 |
-- | East    | TA-21385    | Tom Ashbrook  |   11199.968 |    1 |
-- | South   | SM-20320    | Sean Miller   |    22638.48 |    1 |
-- | West    | RB-19360    | Raymond Buch  |    13999.96 |    1 |
-- +---------+-------------+---------------+-------------+------+

# _____________________________________________________________________________________________________________________________
# Regional contributions to total orders 

select 
	`ll`.`region` as `Region`, 
    count(distinct `ol`.`order id`) as `Order count`, 
    concat(round((count(distinct `ol`.`order id`) * 100)/(select count(*) from `order lookup`), 2), "%") as `Percentage  of regions contributing to orders`
from `superstore` as `ss`
join `location lookup` as `ll` on `ss`.`location id` = `ll`.`location id`
join `order lookup` as `ol` on `ss`.`order id` = `ol`.`order id`
group by `region`;
-- +---------+-------------+-----------------------------------------------+
-- | Region  | Order count | Percentage  of regions contributing to orders |
-- +---------+-------------+-----------------------------------------------+
-- | Central |        1175 | 23.46%                                        |
-- | East    |        1401 | 27.97%                                        |
-- | South   |         822 | 16.41%                                        |
-- | West    |        1611 | 32.16%                                        |
-- +---------+-------------+-----------------------------------------------+

# _____________________________________________________________________________________________________________________________
# Customers who buy the same category of products

select 
	`ss`.`customer id` as `Customer Id`, 
    `cl`.`customer name` as `Customer Name`,
    `pl`.`category` as `Product Category`, 
    count(*) as `Order Quantity`
from `superstore` as `ss`
join `product lookup` as `pl` on `ss`.`product id` = `pl`.`product id`
join `customer lookup` as `cl` on `ss`.`customer id` = `cl`.`customer id`
group by `Customer Id`, `Product Category`
having `Order Quantity` > 18
order by `Order Quantity` desc;
-- +-------------+---------------------+------------------+----------------+
-- | Customer Id | Customer Name       | Product Category | Order Quantity |
-- +-------------+---------------------+------------------+----------------+
-- | EH-13765    | Edward Hooks        | Office Supplies  |             26 |
-- | WB-21850    | William Brown       | Office Supplies  |             23 |
-- | JD-15895    | Jonathan Doherty    | Office Supplies  |             22 |
-- | AP-10915    | Arthur Prichep      | Office Supplies  |             21 |
-- | MA-17560    | Matt Abelman        | Office Supplies  |             21 |
-- | GT-14710    | Greg Tran           | Office Supplies  |             21 |
-- | XP-21865    | Xylona Preis        | Office Supplies  |             21 |
-- | CK-12205    | Chloris Kastensmidt | Office Supplies  |             21 |
-- | CS-12250    | Chris Selesnick     | Office Supplies  |             21 |
-- | CB-12025    | Cassandra Brandow   | Office Supplies  |             20 |
-- | JL-15835    | John Lee            | Office Supplies  |             20 |
-- | DK-12835    | Damala Kotsonis     | Office Supplies  |             20 |
-- | SH-19975    | Sally Hughsby       | Office Supplies  |             19 |
-- | BM-11650    | Brian Moss          | Office Supplies  |             19 |
-- | PP-18955    | Paul Prost          | Office Supplies  |             19 |
-- | RP-19390    | Resi Pölking        | Office Supplies  |             19 |
-- | EP-13915    | Emily Phan          | Office Supplies  |             19 |
-- +-------------+---------------------+------------------+----------------+

select 
	`cl`.`customer id` as `Customer Id`,
	`cl`.`customer name` as `Customer Name`, 
    count(distinct `order id`) as `Total Orders`
from `superstore` `ss`
join `customer lookup` `cl` on `ss`.`customer id` = `cl`.`customer id`
group by `customer id`
order by `total orders` desc
limit 5;
-- +-------------+---------------------+--------------+
-- | Customer Id | Customer Name       | Total Orders |
-- +-------------+---------------------+--------------+
-- | EP-13915    | Emily Phan          |           17 |
-- | ZC-21910    | Zuschuss Carroll    |           13 |
-- | PG-18820    | Patrick Gardner     |           13 |
-- | CK-12205    | Chloris Kastensmidt |           13 |
-- | JE-15745    | Joel Eaton          |           13 |
-- +-------------+---------------------+--------------+

# =============================================================================================================================
# =============================================================================================================================
# Product Analysis
# =============================================================================================================================
# =============================================================================================================================

# _____________________________________________________________________________________________________________________________
# Top selling products by order quantity
select 
	t2.`product name` as `Product Name`,
    t2.`Category` as `Product Category`,
    sum(quantity) as `Quantity`
from `superstore` as t1
left join `product lookup` as t2 on t1.`product id` = t2.`product id`
group by `Product Name`, `Product Category`
order by `Quantity` desc
limit 10;
-- +---------------------------------------------------------------------------------------+------------------+----------+
-- | Product Name                                                                          | Product Category | Quantity |
-- +---------------------------------------------------------------------------------------+------------------+----------+
-- | Staples                                                                               | Office Supplies  |      215 |
-- | Staple envelope                                                                       | Office Supplies  |      170 |
-- | Easy-staple paper                                                                     | Office Supplies  |      150 |
-- | Acco Pressboard Covers with Storage Hooks, 14 7/8" x 11""                             | Office Supplies  |      106 |
-- | Staples in misc. colors                                                               | Office Supplies  |       86 |
-- | Logitech P710e Mobile Speakerphone, Imation 16GB Mini TravelDrive USB 2.0 Flash Drive | Technology       |       75 |
-- | KI Adjustable-Height Table                                                            | Furniture        |       74 |
-- | Avery Non-Stick Binders                                                               | Office Supplies  |       71 |
-- | Storex Dura Pro Binders                                                               | Office Supplies  |       71 |
-- | Xerox 1881, Xerox 1908                                                                | Office Supplies  |       70 |
-- +---------------------------------------------------------------------------------------+------------------+----------+

# _____________________________________________________________________________________________________________________________
# Top selling products by profit
select 
	t2.`product name` as `Product Name`,
    t2.`category` as `Product Category`,
    round(sum(`Profit`), 2) as `Total Profit`
from `superstore` as t1
left join `product lookup` as t2 on t1.`product id` = t2.`product id`
where t1.`profit or loss` = "Profit"
group by `Product Name`, `Product Category`
order by `Total Profit` desc
limit 10;
-- +-------------------------------------------------------------------------------------------------------+------------------+--------------+
-- | Product Name                                                                                          | Product Category | Total Profit |
-- +-------------------------------------------------------------------------------------------------------+------------------+--------------+
-- | Canon imageCLASS 2200 Advanced Copier                                                                 | Technology       |     25199.93 |
-- | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind                           | Office Supplies  |     11184.71 |
-- | Hewlett Packard LaserJet 3310 Copier                                                                  | Technology       |      6983.88 |
-- | GBC DocuBind TL300 Electric Binding System                                                            | Office Supplies  |      6395.54 |
-- | Ibico EPK-21 Electric Binding System                                                                  | Office Supplies  |      6274.77 |
-- | GBC Ibimaster 500 Manual ProClick Binding System                                                      | Office Supplies  |      5859.55 |
-- | HP Designjet T520 Inkjet Large Format Printer - 24" Color"                                            | Technology       |      5039.97 |
-- | GBC DocuBind P400 Electric Binding System                                                             | Office Supplies  |      4981.22 |
-- | Canon PC1060 Personal Laser Copier                                                                    | Technology       |      4570.93 |
-- | Logitech G19 Programmable Gaming Keyboard, Plantronics Savi W720 Multi-Device Wireless Headset System | Technology       |      4432.78 |
-- +-------------------------------------------------------------------------------------------------------+------------------+--------------+

# _____________________________________________________________________________________________________________________________
# Total quantity of products sold from each category
select 
	`pl`.`category` as `Category`,
	sum(`quantity`) as `Total Quantity`
from `superstore` `ss`
join `product lookup` `pl` on `ss`.`product id` = `pl`.`product id` 
group by `Category`
order by `total quantity` desc;
-- +-----------------+----------------+
-- | Category        | Total Quantity |
-- +-----------------+----------------+
-- | Office Supplies |          22906 |
-- | Furniture       |           8028 |
-- | Technology      |           6939 |
-- +-----------------+----------------+

# _____________________________________________________________________________________________________________________________
# Top selling products by order quantity in each category
with cte as (
	select 
		`t2`.`category` as `Category`, 
		`t2`.`product name` as `Product Name`, 
		`t1`.`quantity` as `Quantity`, 
		row_number() over (partition by `Category` order by `Quantity` desc) as `Rank`
	from `superstore` as `t1` 
	left join `product lookup` as `t2` on `t1`.`product id` = `t2`.`product id`
)
select `Category`, `Product Name`, `Quantity`
from cte 
where `Rank` < 4; 
-- +-----------------+----------------------------------------------------------------------+----------+
-- | Category        | Product Name                                                         | Quantity |
-- +-----------------+----------------------------------------------------------------------+----------+
-- | Furniture       | Metal Folding Chairs, Beige, 4/Carton                                |       14 |
-- | Furniture       | Electrix Architect's Clamp-On Swing Arm Lamp, Black                  |       14 |
-- | Furniture       | Ultra Door Push Plate                                                |       14 |
-- | Office Supplies | Pressboard Covers with Storage Hooks, 9 1/2" x 11""                  |       14 |
-- | Office Supplies | Xerox 1964                                                           |       14 |
-- | Office Supplies | Wilson Jones Clip & Carry Folder Binder Tool for Ring Binders, Clear |       14 |
-- | Technology      | Plantronics Voyager Pro HD - Bluetooth Headset                       |       14 |
-- | Technology      | PureGear Roll-On Screen Protector                                    |       14 |
-- | Technology      | Anker Ultra-Slim Mini Bluetooth 3.0 Wireless Keyboard                |       14 |
-- +-----------------+----------------------------------------------------------------------+----------+


# _____________________________________________________________________________________________________________________________
# Caculating profit margin for each product

with cte as (
	select 
		`product id` as `Product Id`, 
		sum(`profit`) as `Profit`, 
		sum(`sales`) as `Sales`, 
		round((sum(`profit`)/sum(`sales`)*100), 2) as `Profit Margin in %`
	from `superstore`
	where `profit or loss` = "Profit"
	group by `Product Id`
	order by `Profit Margin in %` desc
)
select 
	`ct`.`Product Id`, 
    `pl`.`product name` as `Product Name`, 
	`ct`.`profit margin in %` as `Profit Margin in %`
from `cte` as `ct`
join `product lookup` as `pl` on `ct`.`product id` = `pl`.`product id`
limit 12;
-- +-----------------+---------------------------------------------------------------------------------------+--------------------+
-- | Product Id      | Product Name                                                                          | Profit Margin in % |
-- +-----------------+---------------------------------------------------------------------------------------+--------------------+
-- | OFF-BI-10000201 | Avery Triangle Shaped Sheet Lifters, Black, 2/Pack                                    |                 50 |
-- | OFF-BI-10000756 | Storex DuraTech Recycled Plastic Frosted Binders                                      |                 50 |
-- | OFF-BI-10004099 | GBC VeloBinder Strips                                                                 |                 50 |
-- | OFF-BI-10004352 | Wilson Jones DublLock D-Ring Binders                                                  |                 50 |
-- | OFF-BI-10004738 | Flexible Leather- Look Classic Collection Ring Binder                                 |                 50 |
-- | OFF-LA-10003498 | Avery 475                                                                             |                 50 |
-- | OFF-PA-10002499 | Xerox 1890                                                                            |                 50 |
-- | OFF-PA-10004082 | Adams Telephone Message Book w/Frequently-Called Numbers Space, 400 Messages per Book |                 50 |
-- | OFF-PA-10004092 | Tops Green Bar Computer Printout Paper                                                |                 50 |
-- | OFF-PA-10004734 | Southworth Structures Collection                                                      |                 50 |
-- | TEC-MA-10002927 | Canon imageCLASS MF7460 Monochrome Digital Laser Multifunction Copier                 |                 50 |
-- | FUR-FU-10004587 | GE General Use Halogen Bulbs, 100 Watts, 1 Bulb per Pack                              |                 49 |
-- +-----------------+---------------------------------------------------------------------------------------+--------------------+

# _____________________________________________________________________________________________________________________________
# Pivoting the data to find the order ids as profit/Loss/None for each category

with cte as (
	select 
		distinct `ss`.`order id` as `Order Id`, 
		`pl`.`category` as `Product Category`, 
		`ss`.`product id` as `Product Id`, 
		`ss`.`profit or loss` as `Profit or Loss or None`
	from `superstore` `ss`
	join `product lookup` `pl` on `ss`.`product id` = `pl`.`product id`
)
select 
	`Product Category`,
    sum(case when `Profit or Loss or None` = "Profit" then 1 end) as `Profit`,
    sum(case when `Profit or Loss or None` = "Loss" then 1 end) as `Loss`,
    sum(case when `Profit or Loss or None` = "None" then 1 end) as `None`
from cte
group by `Product Category`;
-- +------------------+--------+------+------+
-- | Product Category | Profit | Loss | None |
-- +------------------+--------+------+------+
-- | Furniture        |   1373 |  713 |   33 |
-- | Office Supplies  |   5107 |  886 |   29 |
-- | Technology       |   1571 |  271 |    3 |
-- +------------------+--------+------+------+

-- select 
-- 	`pl`.`category` as `Category`, 
--     sum(case when `ss`.`profit or loss` = "Profit" then 1 end) as `Profit`,
--     sum(case when `ss`.`profit or loss` = "Loss" then 1 end) as `Loss`, 
--     sum(case when `ss`.`profit or loss` = "None" then 1 end) as `None`
-- from `superstore` as `ss`
-- join `product lookup` as `pl` on `ss`.`product id` = `pl`.`product id`
-- group by `Category`;
    

# =============================================================================================================================
# =============================================================================================================================
# Order Shipment Analysis
# =============================================================================================================================
# =============================================================================================================================

# _____________________________________________________________________________________________________________________________
# Shipping days requried for different shipping modes
select 
	`ship mode` as `Ship Mode`, 
    min(datediff(`ship date`, `order date`)) as `Min days required`, 
    max(datediff(`ship date`, `order date`)) as `Max days required`, 
    floor(avg(datediff(`ship date`, `order date`))) as `Avg shipping days`
from `order lookup`
group by `Ship Mode`;
-- +----------------+-------------------+-------------------+-------------------+
-- | Ship Mode      | Min days required | Max days required | Avg shipping days |
-- +----------------+-------------------+-------------------+-------------------+
-- | Standard Class |                 3 |                 7 |                 5 |
-- | Second Class   |                 1 |                 5 |                 3 |
-- | First Class    |                 1 |                 4 |                 2 |
-- | Same Day       |                 0 |                 1 |                 0 |
-- +----------------+-------------------+-------------------+-------------------+


