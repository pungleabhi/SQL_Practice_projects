-- Basic:

-- Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;


-- Calculate the total revenue generated from pizza sales.
select * from pizzas
select * from order_details


select 
	round(sum(od.quantity * pz.price)::numeric,2) as total_price
from order_details as od
join pizzas as pz
on pz.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
select pt.name,
	pz.price
from pizza_types as pt
join pizzas as pz
on pz.pizza_type_id = pt.pizza_type_id
order by pz.price desc limit 1;

-- Identify the most common pizza size ordered.
select pz.size,
	count(od.order_details_id) as order_count
from pizzas as pz
join order_details as od
on pz.pizza_id = od.pizza_id
group by pz.size
order by 2 desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name,
	sum(od.quantity) as quantity
from order_details as od
join pizzas as pz
on pz.pizza_id = od.pizza_id
join pizza_types as pt
on pt.pizza_type_id = pz.pizza_type_id
group by pt.name
order by 2 desc
limit 5;


-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select * from pizza_types

select pt.category,
	sum(od.quantity) as quantity
from order_details as od
join pizzas as pz
on pz.pizza_id = od.pizza_id
join pizza_types as pt
on pt.pizza_type_id = pz.pizza_type_id
group by 1
order by 2;


-- Determine the distribution of orders by hour of the day.
select extract(hour from time) as hours,
	count(order_id) as orders
from orders
group by 1
order by 1;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,
	count(name)
from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity)) as average_no_pizza
from
(select o.date,
	sum(od.quantity) as quantity
from orders as o
join order_details as od
on o.order_id = od.order_id
group by 1
order by 1) as order_quantity
;

-- Determine the top 3 most ordered pizza types based on revenue.

select pt.name,
	round(sum(od.quantity * pz.price)::numeric,2) as revenue
from pizza_types as pt
join pizzas as pz
on pz.pizza_type_id = pt.pizza_type_id
join order_details as od
on od.pizza_id = pz.pizza_id
group by 1
order by 2 desc
limit 3;


-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

select pt.name,
	round(sum(od.quantity * pz.price)::numeric,2) as revenue,
	round(((sum(od.quantity * pz.price) / (select 
		round(sum(od.quantity * pz.price)::numeric,2)
	from order_details as od
	join pizzas as pz
	on pz.pizza_id = od.pizza_id)) * 100)::numeric,2) as pct_of_total
from pizza_types as pt
join pizzas as pz
on pz.pizza_type_id = pt.pizza_type_id
join order_details as od
on od.pizza_id = pz.pizza_id
group by 1
order by 2 desc;


-- Analyze the cumulative revenue generated over time.

select date,
	revenue,
	sum(revenue) over(order by date) as cum_revenue
from
	(select o.date,
		round(sum(od.quantity * pz.price)::numeric,2) as revenue
	from order_details as od
	join pizzas as pz
	on pz.pizza_id = od.pizza_id
	join orders as o
	on o.order_id = od.order_id
	group by 1 )as sales 


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with pizza_revenue as
	(select pt.category,
		pt.name,
		sum(od.quantity * p.price) as revenue,
		rank() over(partition by pt.category order by sum(od.quantity * p.price) desc) as rnk
	from order_details as od
	join pizzas as p
	on od.pizza_id = p.pizza_id
	join pizza_types as pt
	on pt.pizza_type_id = p.pizza_type_id
	group by 1,2)
select category,
	name,
	revenue,
	rnk
from pizza_revenue
where rnk <= 3
order by 1,3 desc;



