create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null
)
select * from order_details

create table orders(
order_id int,
date date,
time time
)
select * from orders

create table pizzas(
pizza_id varchar(30),
pizza_type_id varchar(20),
size text,
price float
)
select * from pizzas

create table pizza_types(
pizza_type_id varchar(20),
name text,
category text,
ingredients text
)
select * from pizza_types

