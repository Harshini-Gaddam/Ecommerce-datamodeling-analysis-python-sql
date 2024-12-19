select * from aisles limit 10;
select * from departments limit 10;
select * from products limit 10;
select * from orders limit 10;
select * from order_products limit 10;

-- Question 1
-- Create a temporary table that joins the orders, order_products, and products 
-- tables to get information about each order, including the products that were purchased and 
-- their department and aisle information.
drop table order_info;

create temporary table order_info as 
select op.order_id, op.add_to_cart_order, op.reordered,
	o.user_id, o.order_number, o.order_dow, o.order_hour_of_day, o.days_since_prior_order,
	p.product_id, p.product_name,
	d.department_id, d.department,
	a.aisle_id, a.aisle
from orders o join order_products op on o.order_id = op.order_id
join products p on op.product_id = p.product_id
join departments d on p.department_id = d.department_id
join aisles a on p.aisle_id = a.aisle_id

select * from order_info limit 10;

-- Question 2
-- Create a temporary table that groups the orders by product and 
-- finds the total number of times each product was purchased, 
-- the total number of times each product was reordered, 
-- and the average number of times each product was added to a cart.

create temporary table product_order_summary as	
select product_id, count(*) as total_orders, 
	count(reordered) as reordered, 
	avg(add_to_cart_order) as avg_added_to_cart
from order_info
group by product_id;

select * from product_order_summary;

-- Question 3
-- Create a temporary table that groups the orders by department and 
-- finds the total number of products purchased, the total number of unique products purchased, 
-- the total number of products purchased on weekdays vs weekends,
-- and the average time of day that products in each department are ordered.

create temporary table department_order_summary as 
select department_id, count(product_id) as total_products,
	count (distinct product_id) as distinct_products, 
	count(case when order_dow <6 then 1 else null end) as weekday_purchases,
	count(case when order_dow >=6 then 1 else null end) as weekened_purchases,
	avg(order_hour_of_day) as average_time

from order_info
group by department_id;

select * from department_order_summary;

-- Question 4
-- Create a temporary table that groups the orders by aisle 
-- and finds the top 10 most popular aisles, 
-- including the total number of products purchased 
-- and the total number of unique products purchased from each aisle.

drop table order_aisle_summary;

create temporary table order_aisle_summary as 
	select aisle_id, count(*) as products_purchased,
	count(distinct product_id) as unique_products

from order_info
group by aisle_id;

select * from order_aisle_summary;

-- Question 5
-- Combine the information from the previous temporary tables into a final table that shows 
-- the product ID, product name, department ID, department name, aisle ID, aisle name, 
-- total number of times purchased, total number of times reordered, average number of times added to cart, 
-- total number of products purchased, total number of unique products purchased, 
-- total number of products purchased on weekdays, total number of products purchased on weekends, 
-- and average time of day products are ordered in each department.


CREATE TEMPORARY TABLE product_behavior_analysis AS
    SELECT pi.product_id, pi.product_name, pi.department_id, d.department, pi.aisle_id, a.aisle,
           pos.total_orders, pos.reordered, pos.avg_added_to_cart,
           dos.total_products, dos.distinct_products,
           dos.weekday_purchases, dos.weekened_purchases, dos.average_time
    FROM product_order_summary AS pos
    JOIN products AS pi ON pos.product_id = pi.product_id
    JOIN departments AS d ON pi.department_id = d.department_id
    JOIN aisles AS a ON pi.aisle_id = a.aisle_id
    JOIN department_order_summary AS dos ON pi.department_id = dos.department_id

select * from product_behavior_analysis;









