drop table if exists zepto;

create table zepto(
sku_id serial primary key,
category varchar(120),
name varchar(150) not null,
mrp numeric(8,2),
discountPercent numeric(5,2),
availableQuantity integer,
discountedSellingPrice numeric(8,2),
weightInGms integer,
outOfStock boolean,
quantity integer
);

select * from zepto
where
Category is null or
name is null or
mrp is null or
discountPercent is null or
availableQuantity is null or
discountedSellingPrice is null or
weightInGms is null or
outOfStock is null or
quantity is null;

select distinct category from zepto
order by 1;

-- products in stock vs out of stock
select outofstock,
	count(sku_id)
from zepto 
group by 1;

-- products names present multiple times
select name,
count(sku_id) as "number of sku's"
from zepto
group by name
having count(sku_id) > 1
order by 2;

-- data cleaning

-- products with price = 0
select * from zepto
where mrp = 0 or discountedsellingprice = 0;

delete from zepto
where mrp = 0;

-- convert paise into Rs
update zepto
set mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0;

select * from zepto;