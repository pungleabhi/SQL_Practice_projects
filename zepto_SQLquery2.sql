-- Find the top 10 best-value products based on the discount percentage.

select distinct name,
	mrp,
	discountpercent
from zepto
order by discountpercent desc
limit 10;

--What are the products with high mrp but out of stock

select distinct name,
	mrp,
	outofstock
from zepto
where outofstock = true and mrp > 250
order by 2 desc;

--Calculate the estimated revenue for each category

select category,
	sum(discountedsellingprice * availablequantity) as total_revenue
from zepto
group by category
order by 2;

-- Find all products where mrp is greater than Rs.500 and discount is less than 10%.

select distinct name,
mrp,
discountpercent
from zepto
where mrp > 500 and discountpercent < 10
order by 2 desc , 3 desc;

-- Identify the top 5 categories offering the highest average discount percentage.

select category,
	round(avg(discountpercent),2) as avg_discount
from zepto
group by 1
order by 2 desc
limit 5;

-- Find the price per gram for products above 100g and sort by best value.

select name,
	weightingms,
	discountedsellingprice,
	round((discountedsellingprice / weightingms),2) as price_per_gram
from zepto
where weightingms >= 100
order by 4,2;

-- Group the products into categories like , low , medium, bulk

select distinct name,
	weightingms,
	case when weightingms < 250 then 'Low'
	when weightingms < 1000 then 'Medium'
	else 'Bulk'
	end as weight_category
from zepto
order by 3, 2;

-- What is the total inventory weight per category

select category,
	sum(weightingms * availablequantity) as total_weight
from zepto
group by 1
order by 2;
