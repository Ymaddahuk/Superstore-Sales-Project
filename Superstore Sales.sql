-- SQL Superstore Sales Analysis
create database superstores_data;

use superstores_data;


-- Create table

create table superstores_sales (
	Row_ID int,
	Order_ID varchar(50),
	Order_Date date,
	Ship_Date date,
	Ship_Mode varchar(50),
	Customer_ID varchar(50),
	Customer_Name varchar(50),
	Segment varchar(50),
	Country varchar(50),
	City varchar(50),
	State varchar(50),
	Postal_Code int,
	Region varchar(50),
	Product_ID varchar(50),
	Category varchar(50),
	Sub_Category varchar(50),
	Product_Name varchar(150),
	Sales DECIMAL(10, 2)
);

select * from superstores_sales;

-- Data Cleaning
delete from retail_sales
where 
	Row_ID is null
    or
    Order_ID is null
    or
    Order_Date is null
    or 
    Ship_Date is null
    or
    Ship_Mode is null
    or 
    Customer_ID is null
    or
    Customer_Name is null
    or
    Segment is null
    or
    Country is null
    or
    City is null
    or
    State is null
    or
    Posta_Code is null
    or
    Region is null
    or
    Product_ID is null
    or
    Category is null
    or
    Sub_Category is null
    or
    Product_Name is null
    or
    Sales is null
    ;

-- Data Exploration

-- How many records do we have?
select count(*) 
from superstores_sales;
-- 9800

-- How many customers do we have?
select count(distinct customer_name) 
from superstores_sales;
-- 793

-- How many regions do we have?
select count(distinct region) 
from superstores_sales;
-- 4

-- How many states do we have?
select count(distinct state) 
from superstores_sales;
-- 49

-- How many categories do we have?
select count(distinct category) 
from superstores_sales;
-- 3

-- How many sub-category do we have?
select  category, count(distinct sub_category) 
from superstores_sales
group by category;
-- Total of 17, each has 4, 9 and 4 respectively

-- How many products do we have?
select count(distinct product_name) 
from superstores_sales;
-- 1846




-- DATA ANALYSIS AND BUSINESS KEY PROBLEMS WITH ANSWERS


-- 1. Product and Category Analysis

-- 	•	What are the top 10 products by total sales?
-- 	•	Which products or categories generate the highest and lowest profits?
-- 	•	How many units of each product were sold, and what is the average selling price?
-- 	•	Are there products with high sales volume but low profitability, or vice versa?

-- 2. Sales and Profit Trends 


-- 	•	What are the total sales by month and year?
-- 	•	How do sales vary across different seasons of the year?
-- 	•	What are the average sales per order over time?
-- 	•	Are there any seasonal patterns in sales for specific categories or sub-categories?
-- 	•	How do sales trends differ by region throughout the year?

-- 3. Regional Performance 


-- 	•	Which regions have the highest and lowest total sales?
-- 	•	How do sales differ by state within each region?
-- 	•	What is the average sales amount per order in each region?
-- 	•	Are there particular regions with significant sales fluctuations over time?
-- 	•	Which categories generate the most sales in each region?





-- 1. Product and Category Analysis

-- 	•	What are the top 10 products by total sales?
select * from superstores_sales;

select Product_ID, Product_Name, sum(sales) as total_sales
from superstores_sales
group by Product_Name
order by total_sales desc
limit 10;

-- 	•	Which products or categories generate the highest and lowest sales?

-- i) Products with the highest, lowest sales
select * from superstores_sales;

-- highest 
select Product_ID, Product_Name, sum(sales) as highest 
from superstores_sales
group by Product_Name
order by highest desc
limit 1;
-- lowest
select Product_ID, Product_Name, sum(sales) as lowest 
from superstores_sales
group by Product_Name
order by lowest 
limit 1;


-- ii) categories with the highest, lowest sales
select * from superstores_sales;

-- highest 
select category, sum(sales) as highest 
from superstores_sales
group by category
order by highest desc
limit 1;
-- lowest
select category, sum(sales) as lowest 
from superstores_sales
group by category
order by lowest asc
limit 1;


-- 	•	How many units of each product were sold, and what is the average selling price?
select * from superstores_sales;

select Product_ID, Product_Name, count(Product_ID) as units_sold, avg(sales) as avg_selling_price
from superstores_sales
group by Product_ID, Product_Name
order by units_sold desc;


-- 	•	Are there products with high product sales but low revenue, or vice versa?
select * from superstores_sales;

with averages as(
	select avg(units_sold) as avg_units_sold, 
			avg(sales) as avg_sales
    from(
		select
			count(Product_ID) as units_sold,
			sum(sales) as sales
		from superstores_sales
		group by Product_ID, Product_Name
    ) product_summary
)

select Product_ID, Product_Name, units_sold, sum_sales,
		case
			when is_high_sales = 1 and is_low_revenue = 1 then "high sales, low revenue"
            when is_high_sales = 0 and is_low_revenue = 0 then "low sales, high revenue"
            else "Other"
		end as sales_profit_category
from(
	select Product_ID, Product_Name, 
		count(Product_ID) as units_sold, 
		sum(sales) as sum_sales,
        (count(Product_ID) > (select avg_units_sold from averages)) as is_high_sales,
        (sum(sales) > (select avg_sales from averages)) as is_low_revenue
	from superstores_sales
	group by Product_ID, Product_Name
) productanalysis
where (is_high_sales = 1 and is_low_revenue = 1)
or
(is_high_sales = 0 and is_low_revenue = 0)
order by sales_profit_category
;



-- 2. Sales and Profit Trends

-- 	•	What are the total sales by month and year?
select * from superstores_sales;

select year(order_date) as year, sum(sales) yearly_sales
from superstores_sales
group by year
order by year, yearly_sales desc;

select year(order_date) as year, date_format(order_date, "%M") as month, sum(sales) monthly_sales
from superstores_sales
group by year, field(month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
order by monthly_sales desc;



-- 	•	How do sales fluctuate across seasons?
select * from superstores_sales;

select year(order_date) as year,  
    case
		when month(order_date) in (3, 4, 5) then "Spring"
        when month(order_date) in (6, 7, 8) then "Summer"
        when month(order_date) in (9, 10, 11) then "fall"
        when month(order_date) in (12, 1, 2) then "winter"
        else "unknown"
	end as seasons,
	sum(sales) seasonal_sales
from superstores_sales
group by year,  seasons
order by year, seasonal_sales desc;



-- 	•	What is the average sales amount per order in each region?
select * from superstores_sales;

select region, avg(order_sales) as avg_order_sales
from(
	select region, Order_ID, sum(Sales) as order_sales
	from superstores_sales
	group by region, Order_ID
) orders
group by region
;


-- 	•	Are there any seasonal patterns in sales for specific categories or sub-categories?
select * from superstores_sales;

-- i) Catgeory
with seasonal_sales as(
	select 
		year(order_date) as year,
		case
			when month(order_date) in (3, 4, 5) then "Spring"
			when month(order_date) in (6, 7, 8) then "Summer"
			when month(order_date) in (9, 10, 11) then "fall"
			when month(order_date) in (12, 1, 2) then "winter"
			else "unknown"
		end as seasons,
		category,
		sum(sales) as catsales_by_season
	from superstores_sales
	group by year, seasons, category
),
ranked_seasons as (
	select 
		year,
		seasons,
		category,
		catsales_by_season,
        row_number() over(partition by year order by catsales_by_season desc) as ranking
	from 
		seasonal_sales
	group by year, seasons, category
)
select 
		year,
		seasons,
		category,
		catsales_by_season
	from 
		ranked_seasons
	where ranking = 1
order by year, field(seasons, "Spring", "summer", "fall", "winter"), category,  catsales_by_season desc;

-- ii) sub-category
with seasonal_sales as(
	select 
		year(order_date) as year,
		case
			when month(order_date) in (3, 4, 5) then "Spring"
			when month(order_date) in (6, 7, 8) then "Summer"
			when month(order_date) in (9, 10, 11) then "fall"
			when month(order_date) in (12, 1, 2) then "winter"
			else "unknown"
		end as seasons,
		sub_category,
		sum(sales) as catsales_by_season
	from superstores_sales
	group by year, seasons, sub_category
),
ranked_seasons as (
	select 
		year,
		seasons,
		sub_category,
		catsales_by_season,
        row_number() over(partition by year order by catsales_by_season desc) as ranking
	from 
		seasonal_sales
	group by year, seasons, sub_category
)
select 
		year,
		seasons,
		sub_category,
		catsales_by_season
	from 
		ranked_seasons
	where ranking = 1
order by year, field(seasons, "Spring", "summer", "fall", "winter"), sub_category,  catsales_by_season desc;

-- 	•	How do sales trends differ by region throughout the year?
select * from superstores_sales;

select year, month, region, total_sales,
		lag(total_sales) over(partition by region order by month) as previous_month_sales,
        round(
			((total_sales - lag(total_sales) over(partition by region order by month))/
            lag(total_sales) over(partition by region order by month)) * 100, 2
        ) as sales_change_percent
from(
	select 
		year(order_date) as year, 
		date_format(order_date, "%M") as month, 
		region, 
		sum(sales) as total_sales
	from superstores_sales
	group by year, month, region
) as monthly_sales
order by year, month, region;



-- 3. Regional Performance 


-- 	•	Which regions have the highest and lowest total sales?
select * from superstores_sales;

-- highest by region
select region, sum(sales) as total_sales
from superstores_sales
group by region
order by total_sales desc
limit 1;
-- lowest by region
select region, sum(sales) as total_sales
from superstores_sales
group by region
order by total_sales 
limit 1;



-- 	•	How do sales differ by state within each region?
select * from superstores_sales;

select region, state, sum(sales) total_state_sales
from superstores_sales
group by region, state
order by total_state_sales desc
;

-- 	•	What is the average sales amount per order in each region?
select * from superstores_sales;

select region, avg(total_sales) avg_total_sales 
from(
select order_id, region, sum(sales) as total_sales
from superstores_sales
group by order_id, region
order by order_id, region
) order_totals
group by region
order by region;

-- 	•	Are there particular regions with significant sales fluctuations over time?
select * from superstores_sales;

select year, region, total_sales,
		lag(total_sales) over(partition by region order by year) as previous_year_sales,
        round(
			((total_sales - lag(total_sales) over(partition by region order by year))/
            lag(total_sales) over(partition by region order by year)) * 100, 2
        ) as sales_change_percent
from(
	select  
		year(order_date) as year, 
		region, 
		sum(sales) as total_sales
	from superstores_sales
	group by year(order_date), region	
) as yearly_sales
order by region, year
;

-- 	•	Which categories generate the most sales in each region?
select * from superstores_sales;

with category_sales as
(
	select region, category, 
		sum(sales) total_sales,
		row_number() over(partition by region order by sum(sales)) as ranking
	from superstores_sales
	group by region, category
)
select region, category, total_sales
from category_sales
where ranking = 1
;


-- End of project




