# Superstore Sales Analysis

## Project Overview

**Project Title**: Superstore Sales Analysis 
**Database**: `superstores_data`

This project is a practice project to improve and learn more SQL skills and techniques typically used by data analysts to explore, clean, and analyze Superstore Sales Analysis. The project involves setting up a superstore sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a superstore sales database**: Create and populate a superstore sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `superstores_data`.
- **Table Creation**: A table named `superstores_sales` is created to store the sales data. The table structure includes columns for Row ID, Order ID, Order Date, Shipping Date, Shipping Mode, Customer ID, Customer Name, Segment, Country, City, State, Postal Code, Region, Product_ID, Category, Sub_Category, Product_Name, Sales amount.

```sql
create database superstores_data;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Region Count**: Find out how many unique regions are in the dataset.
- **State Count**: Find out how many unique states are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Sub_category Count**: Find out how many unique sub_categories are in the dataset.
- **Product Count**: Find out how many unique product are in the dataset.

```sql

select 
        count(*) 
from 
        superstores_sales;

select 
        count(distinct customer_name) 
from 
        superstores_sales;

select 
        count(distinct region) 
from 
        superstores_sales;

select 
        count(distinct state) 
from 
        superstores_sales;

select 
        count(distinct category) 
from 
        superstores_sales;

select  
        category, 
        count(distinct sub_category) 
from 
        superstores_sales
group by 
        category;

select 
        count(distinct product_name) 
from 
        superstores_sales;

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Product and Category Analysis**
 **What are the top 10 products by total sales?**:
```sql

select 
        Product_ID, 
        Product_Name, 
        sum(sales) as total_sales
from 
        superstores_sales
group by 
        Product_Name
order by 
        total_sales desc
limit 10;
```


**Which products or categories generate the highest and lowest sales?**:
```sql
-- i) Products with the highest, lowest profits
-- highest 
select 
        Product_ID, 
        Product_Name, 
        sum(sales) as highest 
from 
        superstores_sales
group by
        Product_Name
order by 
        highest desc
limit 1;

-- lowest
select 
        Product_ID, 
        Product_Name, 
        sum(sales) as lowest 
from 
        superstores_sales
group by 
        Product_Name
order by 
        lowest 
limit 1;

-- ii) categories with the highest, lowest profits
-- highest 
select 
        category, 
        sum(sales) as highest 
from 
        superstores_sales
group by 
        category
order by 
        highest desc
limit 1;

-- lowest
select 
        category, 
        sum(sales) as lowest 
from 
        superstores_sales
group by 
        category
order by 
        lowest asc
limit 1;

```


 **How many units of each product were sold, and what is the average selling price?**:
```sql
select 
        Product_ID,
        Product_Name, 
        count(Product_ID) as units_sold, 
        avg(sales) as avg_selling_price
from 
        superstores_sales
group by 
        Product_ID, Product_Name
order by 
        units_sold desc;
```


**Are there products with high sales volume but low profitability, or vice versa?**:
```sql
with 
    averages 
as(
	select 
	        avg(units_sold) as avg_units_sold, 
			avg(sales) as avg_sales
    from(
		select
			count(Product_ID) as units_sold,
			sum(sales) as sales
		from 
		    superstores_sales
		group by 
		    Product_ID, 
		    Product_Name
    ) product_summary
)

select 
        Product_ID, 
        Product_Name, 
        units_sold, 
        sum_sales,
		case
			when is_high_sales = 1 and is_low_revenue = 1 then "high sales, low revenue"
            when is_high_sales = 0 and is_low_revenue = 0 then "low sales, high revenue"
            else "Other"
		end as sales_profit_category
from(
	select 
	        Product_ID, 
	        Product_Name, 
		    count(Product_ID) as units_sold, 
		    sum(sales) as sum_sales,
            (count(Product_ID) > (select avg_units_sold from averages)) as is_high_sales,
            (sum(sales) > (select avg_sales from averages)) as is_low_revenue
	from 
	        superstores_sales
	group by 
	        Product_ID, Product_Name
) productanalysis
where (is_high_sales = 1 and is_low_revenue = 1)
or
(is_high_sales = 0 and is_low_revenue = 0)
order by sales_profit_category
;
```


2. **Sales Trends**
**What are the total sales by month and year?**:
```sql
select 
        year(order_date) as year, 
        sum(sales) yearly_sales
from 
        superstores_sales
group by 
        year
order by 
        yearly_sales desc;

select
        year(order_date) as year, 
        date_format(order_date, "%M") as month, 
        sum(sales) monthly_sales
from superstores_sales
group by 
        year, field(month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
order by 
        monthly_sales desc;
```


**How do sales fluctuate across seasons?**:
```sql
select 
    year(order_date) as year,  
    case
		when month(order_date) in (3, 4, 5) then "Spring"
        when month(order_date) in (6, 7, 8) then "Summer"
        when month(order_date) in (9, 10, 11) then "fall"
        when month(order_date) in (12, 1, 2) then "winter"
        else "unknown"
	end as seasons,
	sum(sales) seasonal_sales
from 
    superstores_sales
group by 
    year,  seasons
order by 
    year, seasonal_sales desc;
```


**What is the average sales amount per order in each region?**:
```sql
select 
    region, 
    avg(order_sales) as avg_order_sales
from(
	select 
	    region, 
	    Order_ID, 
	    sum(Sales) as order_sales
	from 
	    superstores_sales
	group by 
	region, Order_ID
) orders
group 
    by region
;
```


**Are there any seasonal patterns in sales for specific categories or sub-categories?**:
```sql
-- i) Catgeory
with 
    seasonal_sales 
as(
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
	group by 
	    year, seasons, category
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
	group by 
	    year, seasons, category
)
select 
		year,
		seasons,
		category,
		catsales_by_season
	from 
		ranked_seasons
	where 
	    ranking = 1
order by
     year, field(seasons, "Spring", "summer", "fall", "winter"), category,  catsales_by_season desc;


-- ii) sub-category
with 
    seasonal_sales 
as(
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
ranked_seasons 
as (
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
```



**How do sales trends differ by region throughout the year?**:
```sql
select 
    year, 
    month, 
    region, 
    total_sales,
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
	from 
	    superstores_sales
	group by 
	    year, month, region
) as monthly_sales
order by 
    year, month, region;
```


3. **3. Regional Performance**
**Which regions have the highest and lowest total sales?**:
```sql
-- highest by region
select 
    region, 
    sum(sales) as total_sales
from 
    superstores_sales
group by 
    region
order by 
    total_sales desc
limit 1;

-- lowest by region
select 
    region, 
    sum(sales) as total_sales
from 
    superstores_sales
group by 
    region
order by 
    total_sales 
limit 1;
```


**How do sales differ by state within each region?**:
```sql
select 
    region, 
    state, 
    sum(sales) total_state_sales
from 
    superstores_sales
group by 
    region, state
order by 
    total_state_sales desc
;
```


**What is the average sales amount per order in each region?**:
```sql
select 
    region, 
    avg(total_sales) avg_total_sales 
from(
select 
    order_id, 
    region, 
    sum(sales) as total_sales
from 
    superstores_sales
group by 
    order_id, region
order by 
    order_id, region
) order_totals
group by
     region
order by 
    region;
```


**Are there particular regions with significant sales fluctuations over time?**:
```sql
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
```


**Which categories generate the most sales in each region?**:
```sql
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
```


# Findings

## 1. Product and Category Analysis

- **Top 10 Products by Total Sales**:
  - The analysis identified the top 10 products contributing to the highest sales, which included "Canon imageCLASS 2200 Advanced Copier", "Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind", "Cisco TelePresence System EX90 Videoconferencing Unit" etc. This highlights key revenue drivers and informs inventory and marketing strategies.

- **Revenue of Products and Categories**:
  - The products with the highest sales were "Canon imageCLASS 2200 Advanced Copier", while the lowest sales was observed for "Eureka Disposable Bags for Sanitaire Vibra Groomer I Upright Vac. Similarly", the category with the highest sales was Technology, indicating a focus area for maximizing sale margins.

- **Units Sold and Average Selling Price**:
  - The average selling price of products varied, with a significant number of units sold for products like Logitech 910-002974 M325 Wireless Mouse for Web Scrolling. This suggests a balance between pricing strategy and sales volume, indicating opportunities for pricing adjustments.

- **Product sales vs. revenue**:
  - The analysis revealed products like "Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back" had high sales volume but low profitability, suggesting a need to reassess pricing or costs. Conversely, 'LG Electronics Tone+ HBS-730 Bluetooth Headset' showed low sales volume but high profitability, indicating potential for targeted promotions.

## 2. Sales Trends

- **Total Sales by Month and Year**:
  - The overall sales trends revealed an upward trajectory in total sales over the years, particularly peaking in November 2018. This data can guide future sales forecasts and promotional timing.

- **Seasonal Fluctuations**:
  - Seasonal analysis indicated that sales peaked during the fall and winter (2017) across the years, while summer months typically saw lower sales. This insight can inform inventory management and promotional strategies to leverage high sales seasons.

- **Average Sales Amount per Order by Region**:
  - The average sales amount per order varied significantly across regions, with the South region exhibiting the highest average order value. This highlights the importance of regional marketing and sales strategies.

- **Category and Sub-category Sales Patterns**:
  - The seasonal sales patterns for categories showed that Technology performs best in Fall, while Phoneshad consistent performance year-round. This insight can guide product stocking and promotional efforts.

## 3. Regional Performance

- **Total Sales by Region**:
  - The analysis found that West region generated the highest sales, while South region had the lowest. Understanding these disparities helps tailor regional strategies and resource allocation.

- **State Sales Performance**:
  - Sales performance varied by state within each region, with California leading in sales. This can inform targeted marketing campaigns and regional resource distribution.

- **Sales Fluctuations Over Time**:
  - Significant fluctuations were observed in sales over time for regions like the Central region, suggesting a need for further investigation into factors driving these changes. The findings may warrant closer monitoring and adaptive strategies.

- **Top-Performing Categories by Region**:
  - The analysis identified that Furniture generated the most sales in central and south regions, while Office supplies generated the most sales in the East and West regions. This insight can help guide inventory decisions and regional promotions to maximize sales.
  
  
## Visualization

[Product and Category Analysis](https://public.tableau.com/views/SuperstoresDataDash1ProductandCategoryAnalysis/Dash1ProductandCategoryAnalysis?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

[Sales Trends](https://public.tableau.com/views/Dash1ProductandCategoryAnalysis/Dash2SalesTrends?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

[Regional Performance](https://public.tableau.com/views/SuperstoresDataDash3RegionalPerformance/SuperStoreDataDash3RegionalPerformance?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)


## Conclusion

In conclusion, the findings from this analysis provide valuable insights into product performance, sales trends, and regional dynamics. By leveraging this data, the company can make informed decisions to optimize inventory, enhance marketing strategies, and ultimately drive sales growth.


## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Yahaya Muhammed Ad-dahuk

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

# Contact

For questions, feel free to contact me:

- **Email**: yahayamuhammedaddahuk@gmail.com
- **LinkedIn**: [Yahaya Muhammed Ad-dahuk](www.linkedin.com/in/yahaya-muhammed-ad-dahuk)

Thank you for your support, and I look forward to connecting with you!
