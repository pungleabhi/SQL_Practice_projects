-- sql retail sales analysis

create database sql_project_p2;
use sql_project_p2;
CREATE TABLE retail_sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transactions_id INT,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

CREATE TABLE staging_sales (
    transactions_id TEXT,
    sale_date TEXT,
    sale_time TEXT,
    customer_id TEXT,
    gender TEXT,
    age TEXT,
    category TEXT,
    quantity TEXT,
    price_per_unit TEXT,
    cogs TEXT,
    total_sale TEXT
);

SELECT DISTINCT total_sale
FROM staging_sales
WHERE transactions_id REGEXP '[^0-9]';

SELECT *
FROM retail_sales
WHERE cogs IS NULL ;

-- age has null values of 10 , quantiy , price_per_unit , cogs & total_sale has 3 null values at transaction_ids 679 ,746,1225
INSERT INTO retail_sales (
    transactions_id,
    sale_date,
    sale_time,
    customer_id,
    gender,
    age,
    category,
    quantity,
    price_per_unit,
    cogs,
    total_sale
)SELECT COUNT(*) 
FROM staging_sales;
SELECT
    NULLIF(transactions_id, ''),   -- replace '' with NULL
    STR_TO_DATE(sale_date, '%Y-%m-%d'),
    STR_TO_DATE(sale_time, '%H:%i:%s'),
    NULLIF(customer_id, ''),
    gender,
    NULLIF(age, ''),
    category,
    NULLIF(quantity, ''),
    CAST(NULLIF(price_per_unit, '') AS DECIMAL(10,2)),
    CAST(NULLIF(cogs, '') AS DECIMAL(10,2)),
    CAST(NULLIF(total_sale, '') AS DECIMAL(10,2))
FROM staging_sales;

SELECT COUNT(*) AS staging_count 
FROM staging_sales;

SELECT COUNT(*) AS retail_count 
FROM retail_sales;

select * from retail_sales;
select count(*) from retail_sales;

alter table retail_sales
drop column id;

SELECT transactions_id, COUNT(*) 
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;

select count(*)
from staging_sales
where age is null or age = '';

delete FROM retail_sales
WHERE transactions_id IS NULL
or sale_date IS NULL
or sale_time IS NULL
or customer_id IS NULL
or gender IS NULL
or category IS NULL
or quantity IS NULL
or price_per_unit IS NULL
or cogs IS NULL
or total_sale IS NULL;

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

-- Data exploration

-- how many sales we have?
select count(*) as total_sale from retail_sales;

-- how many unique customers we have?
select count(distinct customer_id) as total_sale 
from retail_sales;

select distinct categoryfrom retail_sales;

-- data analysis  & business key problems :
select * from retail_sales;

-- Q.1 write a sql query to retrieve all columns for sales made on '2022-11-05'
select * 
from retail_sales
where sale_date='2022-11-05';

-- Q.2 write a sql query to retrieve all transactions where the category is 'clothing' and the quantiy sold is more than 4 in the month of nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';

-- SELECT * FROM retail_sales
-- WHERE category = 'Clothing'
--   -- AND quantity > 10
--   AND YEAR(sale_date) = 2022
--   AND MONTH(sale_date) = 11;


-- Q.3 write a sql query to calculate the total sales for each catogory
select * 
from retail_sales;

select category, sum(total_sale) 
from retail_sales
group by category;

-- Q.4 write a sql query to find the average age of customers who purchased items from the 'Beauty' category
select avg(age) , category 
from retail_sales
where category='beauty';

-- Q.5 write a sql query to find all transactions where the total sale is greater than 1000
select * 
from retail_sales;

select *
from retail_sales
where total_sale > 1000;

-- Q.6 write a sql query to find the total num of transactions made by each gender in each category
select category,gender,count(*) as total_trans 
from retail_sales
group by category, gender 
order by category;

-- Q.7 write a sql query to calculate the avg sale for each month. find out best selling month in each year
select year(sale_date)as year,monthname(sale_date)as month,avg(total_sale) from retail_sales
group by year(sale_date),month(sale_date) order by year,month ;

select year, month, avg_sale,rnk 
from (
	select year(sale_date)as year,
	monthname(sale_date) as month,
	avg(total_sale)as avg_sale,
	rank() over(partition by year(sale_date) order by avg(total_sale)desc
	)as rnk
	from retail_sales
	group by year(sale_date),monthname(sale_date)
)t
where rnk=1;

-- Q.8 write a sql query to find the top 5 customers based on the highest total sales
select customer_id,sum(total_sale) as total_sale
from retail_sales
group by customer_id 
order by sum(total_sale) desc limit 5;

-- Q.9 write a sql query to find the num of unique customers who purchased items from each category
select category, count(distinct customer_id) as count_unique_cust 
from retail_sales
group by category;

-- Q.10 wite a sql query to creaye each shift and num of orders (ex. morning <=12 , afternoon betweeen 12 & 17 , evening >17)

with hourly_sales
as (
select *,
	case 
		when extract(hour from sale_time)<12 then 'morning'
        when extract(hour from sale_time) between 12 and 17 then 'afternoon'
        else 'evening'
	end as shift
from retail_sales
)
select count(transactions_id)as total_orders, shift from hourly_sales
group by shift;