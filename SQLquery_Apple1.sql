-- Apple Retail sales

select * from category;
select * from products;
select * from sales;
select * from stores;
select * from warranty;

-- EDA
select distinct repair_status from warranty;
select distinct category_name from category;
select distinct store_name from stores;
select count(*) from sales;

--
explain Analyze select * from sales where product_id ='P-40';
-- pt:0.207 ms
-- et:199.064 ms
-- after et:17.617 ms
create index sales_product_id on sales(product_id);
create index sales_store_id on sales(store_id);
create index sales_sale_date on sales(sale_date);

-- 1.How many stores exist in each country?
select count(store_id) as num_of_stores,
	country
from stores
group by 2;

-- 2.Which store sold the highest number of units in the past year?
select s.store_id,
	st.store_name,
	sum(s.quantity) as totalf_units_sold
from sales as s
join stores as st
on st.store_id = s.store_id
where sale_date >= current_date - interval '1 year'
group by 1,2
order by 3 desc
limit 1;

-- 3.What is the average price of products in each category?
select * from category;
select * from products;

select category_id,
	avg(price) as avg_price
from products
group by 1
order by 2 desc;


-- 4.Calculate the total number of units sold by each store.
select store_id,
	sum(quantity) as units_sold
from sales
group by 1
order by 2;

-- 5.Determine how many stores have never had a warranty claim filed.
select * from stores
where store_id not in
(
select distinct store_id
from sales as s
right join warranty as w
on s.sale_id = w.sale_id
)

-- 6.Count the number of unique products sold in the last year.
select count(distinct(product_id))
from sales
where sale_date >= current_date - interval '1 year'

-- 7.For each store, identify the best-selling day based on highest quantity sold.

select *
from(
	select 
		store_id,
		to_char(sale_date, 'Day') as Day,
		sum(quantity) as total_unit_sold,
		rank() over(partition by store_id order by sum(quantity) desc) as rank
	from sales
	group by 1,2
) as t1
where rank = 1;



-- 8.Identify the least selling product in each country for each year based on total units sold.
with product_sale
as
(
	select st.country,
		p.product_name,
		sum(s.quantity) as total_units_sold,
		extract(year from s.sale_date) as sale_year
	from sales as s
	join
	stores as st
	on s.store_id = st.store_id
	join
	products as p
	on s.product_id = p.product_id
	group by 1,2,4
),
sales_rank
as
(
	select
		country,
		product_name,
		sale_year,
		total_units_sold,
		rank() over(partition by country , sale_year order by total_units_sold)
		as rank
	from product_sale
)
select
	country,
	product_name,
	sale_year,
	total_units_sold
from sales_rank
where rank = 1
order by country , sale_year;


-- 9.Calculate how many warranty claims were filed within 180 days of a product sale.

select count(*) 
from warranty as w
left join
sales as s
on w.sale_id = s.sale_id
where w.claim_date - s.sale_date <=180
and w.claim_date > s.sale_date
;

SELECT 
    COUNT(*) AS claims_within_180_days
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
WHERE w.claim_date <= s.sale_date + INTERVAL '180 days'
and w.claim_date > s.sale_date;


-- 10.Determine how many warranty claims were filed for products launched in the last two years.
select count(*) -- p.product_id,
	-- p.product_name,
	-- p.launch_date,
	-- w.claim_date
from products as p
join
sales as s
on s.product_id = p.product_id
join
warranty as w
on w.sale_id = s.sale_id
where p.launch_date > current_date - interval '2 years'
;

-- 11.List the months in the last three years where sales exceeded 5,000 units in the USA.
select st.country,
	to_char(s.sale_date , 'Month') as month,
	extract(year from s.sale_date) as year,
	sum(s.quantity) as total_units_sold
from sales as s
join stores as st
on st.store_id = s.store_id
where country ilike 'United states'
and s.sale_date >= current_date - interval '3 years'
group by 1,2,3
having sum(s.quantity) > 5000
order by 3, min(s.sale_date);


-- 12.Identify the product category with the most warranty claims filed in the last two years.
select p.category_id,
	count(*) as total_claims
from warranty as w
join sales as s
on s.sale_id = w.sale_id
join products as p
on p.product_id = s.product_id
where w.claim_date >= current_date - interval '2 years'
group by 1
order by 2 desc
;

--13. Determine the percentage chance of receiving warranty claims after each purchase for each country.
SELECT 
    st.country,
    COUNT(DISTINCT s.sale_id) AS total_sales,
    COUNT(w.sale_id) AS total_claims,
    ROUND( (COUNT(w.sale_id)::decimal / COUNT(DISTINCT s.sale_id)) * 100, 2 ) AS claim_percentage
FROM sales s
JOIN stores st ON s.store_id = st.store_id
LEFT JOIN warranty w ON s.sale_id = w.sale_id
GROUP BY st.country
ORDER BY claim_percentage DESC;

select st.country,
	count(distinct s.sale_id) as total_sales,
	count(w.sale_id) as total_claims,
	round(count(w.sale_id)::decimal / count(distinct s.sale_id)*100,2) as claim_percentage
from sales as s
join stores as st
on st.store_id = s.store_id
left join warranty as w
on s.sale_id = w.sale_id
group by 1
order by 4 desc;


-- 14.Analyze the year-by-year growth ratio for each store.

with yearly_sale
as
(
	select s.store_id,
		st.store_name,
		extract(year from s.sale_date) as year,
		sum(s.quantity * p.price) as total_sale
	from sales as s
	join products as p
	on s.product_id = p.product_id
	join stores as st
	on st.store_id = s.store_id
	group by 1,2,3
	order by 1,3
),
growth_ratio as
(
	select store_name, 
		year,
		lag(total_sale,1) over(partition by store_name order by year) as last_year_sale,
		total_sale as curr_year_sale
	from yearly_sale
)
select
	store_name,
	year,
	last_year_sale,
	curr_year_sale,
	round((curr_year_sale - last_year_sale)::numeric/last_year_sale::numeric * 100, 3)as ratio
from growth_ratio
where last_year_sale is not null
;


-- 15.Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

select
	case
		when p.price < 500 then 'Less expensive'
		when p.price between 500 and 1500 then 'mid range'
		else 'expensive'
	end as price_segment,
	count(w.claim_id) as total_claim
from warranty as w
left join
sales as s
on w.sale_id = s.sale_id
join
products as p
on p.product_id = s.product_id
where w.claim_date >= current_date - interval '5 years'
group by 1
order by total_claim




