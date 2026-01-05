create table customers(
customer_id	text,
customer_name	text,
email	text,
phone	text,
city	text,
state	text,
signup_date	text
)

select * from customers;

create table products(product_id	text,
product_name	text,
category	text,
price	text,
seller_city	text
)

select * from products;

create table orders(
order_id	text,
order_date	text,
customer_id	text,
product_id	text,
quantity	text,
order_status	text,
payment_mode	text)

select * from orders;


--- Data cleaning of customers table

select * from customers;


create view customer_clean as
select customer_id_clean,
	   customer_name_clean,
	   email_clean,
	   phone_clean,
	   city_clean,
	   state_clean,
	   signup_date_clean
from 
(select case
		when customer_id is null then null
		else trim(customer_id)
end as customer_id_clean,
		case
		when customer_name is null then null
		else initcap(trim(customer_name))
end as customer_name_clean,
		case 
		when email is null then null
		else email :: text
end as email_clean,
		case
		when phone is null then null
    when trim(phone) = '' then null
    when phone !~ '^\d{10}$' then null
    else trim(phone)
end as phone_clean,
		case
		when city is null then null
		else initcap(trim(city))
end as city_clean,
		case
		when state = 'TS' then 'Telangana'
		when state = 'DL' then 'Delhi'
		when state = 'MH' then 'Maharashtra'
		when state = 'TN' then 'Tamil Nadu'
		else null
end as state_clean,
		case
		when signup_date ~ '^\d{4}-\d{2}-\d{2}$'
		then signup_date :: date
		when signup_date ~ '^\d{2}-\d{2}-\d{4}'
		then signup_date :: date
		when replace(signup_date,'/','-') ~ '^\d{4}-\d{2}-\d{2}'
		then signup_date :: date
		when replace(signup_date,'/','-') ~ '^\d{2}-\d{2}-\d{4}'
		then signup_date :: date
		else null
end as signup_date_clean,
		row_number() over(partition by customer_id order by customer_id desc) as rnk
from customers)
where rnk = 1
order by customer_id_clean asc;

select * from customer_clean;

--- Data cleaning of products table

create or replace view product_clean as
select product_id_clean,
	   product_name_clean,
	   category_clean,
	   price_clean,
	   seller_city_clean,
	   valid_price
from (select
	  case
	  when product_id is null then null
	  else trim(product_id)
end as product_id_clean,
	  case
	  when product_name is null then null
	  else initcap(trim(product_name))
end as product_name_clean,
	 case
	 when category is null then null
	 else initcap(trim(category))
end as category_clean,
	case
    when price is null or trim(price) = '' then null
    when price !~ '^\d+(\.\d+)?$' then null
    when price::numeric <= 0 then null
    else price::numeric
end as price_clean,
	case 
	when price is null or trim(price) = '' then 0
        when price !~ '^\d+(\.\d+)?$' then 0
        when price::numeric <= 0 then 0
        else 1
end as valid_price,
	case
	when seller_city is null then null
	else initcap(trim(seller_city))
end as seller_city_clean,
	row_number() over(partition by product_id order by product_id desc) as rnk
from products)
where rnk = 1
order by product_id_clean;

select * from product_clean;

--- Data cleaning of orders table

create view orders_clean as
select order_id_clean,
	   order_date_clean,
	   customer_id_clean,
	   product_id_clean,
	   quantity_clean,
	   order_status_clean,
	   payment_mode_clean,
	   quantity_clean_flag,
	   order_date_clean_flag,
	   valid_data
	   from (select
	case
	when order_id is null then null
	else trim(order_id)
end as order_id_clean,
	case
    when order_date ~ '^\d{4}-\d{2}-\d{2}\s'
    then order_date::timestamp::date
    when order_date ~ '^\d{4}/\d{2}/\d{2}$'
    then to_date(order_date, 'yyyy/mm/dd')
    when order_date ~ '^\d{2}-\d{2}-\d{4}$'
    then to_date(order_date, 'dd-mm-yyyy')
	else null
end as order_date_clean,
	case
	when customer_id is null then null
	else trim(customer_id)
end as customer_id_clean,
	case
	when product_id is null then null
	else trim(product_id)
end as product_id_clean,
	case
	when quantity :: numeric > 0
	then quantity :: numeric
	else null
end as quantity_clean,
	case
	when order_status is null then null
	else initcap(trim(order_status))
end as  order_status_clean,
	case
	when payment_mode is null then null
	else trim(payment_mode)
end as payment_mode_clean,
	case
	when quantity :: numeric >0
	then 1
	else 0
end quantity_clean_flag,
	case
	when  order_date ~ '^\d{4}-\d{2}-\d{2}\s'
    then 1
    when order_date ~ '^\d{4}/\d{2}/\d{2}$'
    then 1
    when order_date ~ '^\d{2}-\d{2}-\d{4}$'
    then 1
	else 0
end as order_date_clean_flag,
	case
	when order_date ~ '^\d{4}-\d{2}-\d{2}\s' and quantity :: numeric >0
    then 1
    when order_date ~ '^\d{4}/\d{2}/\d{2}$' and quantity :: numeric >0
    then 1
    when order_date ~ '^\d{2}-\d{2}-\d{4}$' and quantity :: numeric >0
    then 1
	else 0
end as valid_data,
	row_number() over(partition by order_id order by order_id desc ) as rnk
from orders)
where rnk =1
order by order_id_clean asc;


select * from customer_clean;

select * from product_clean;

select * from orders_clean;


--- Q1. How many total orders and completed orders are there?

select 
	count(*) as total_orders,
	count(case when order_status_clean = 'Completed' then 1 end) as Completed_orders,
	count(case when order_status_clean = 'Cancelled' then 1 end) as Cancelled_orders,
	count(case when order_status_clean = 'Returned' then 1 end) as Returned_orders
from orders_clean;

--- Q2. How many orders have invalid quantity?

select count(quantity_clean_flag) as invalid_quantity
from orders_clean
where quantity_clean_flag = 0
group by quantity_clean_flag;

--- Q4. How many orders were placed per payment method?

select payment_mode_clean, count(payment_mode_clean) as no_of_orders
from orders_clean
group by payment_mode_clean;

--- Q5. How many unique customers have placed at least one order?

select count(distinct(customer_id_clean)) as no_of_orders
from orders_clean;

--- Q6. How many orders are there per city?

select c.city_clean as city,count(o.order_id_clean) as Total_orders
from customer_clean c
left join orders_clean o
on c.customer_id_clean = o.customer_id_clean
group by c.city_clean;

--- Q7. Which city has the highest number of completed orders?

select c.city_clean as city,count(o.order_id_clean) as Total_orders
from customer_clean c
left join orders_clean o
on c.customer_id_clean = o.customer_id_clean
where order_status_clean = 'Completed'
group by c.city_clean;

--- Q8. How many products have never been ordered?

select count(*) as never_ordered
from product_clean p
left join orders_clean o
on p.product_id_clean = o.product_id_clean
where o.product_id_clean is null;

--- Q9. How many orders have missing or invalid order dates?

select count(*) as invalid_order_dates
from orders_clean
where order_date_clean_flag = 0;

--- Q10. What percentage of orders are cancelled?

with cancelled as(
select count(*) as cancelled_count from orders_clean
where order_status_clean= 'Cancelled'
),
total as (
select count(*) as total_count
from orders_clean)
select cancelled.cancelled_count,
total.total_count,
round(cancelled.cancelled_count*100/total.total_count,2) as cancelled_percentage
from cancelled cross join total;
	
SELECT 
    round(100.0 * SUM(CASE WHEN order_status_clean = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*),2) AS cancelled_percentage
FROM orders_clean;

--- Q11. What is the total revenue by city?

with revenue as
(select o.order_id_clean,o.customer_id_clean,(o.quantity_clean*p.price_clean) as revenue
from orders_clean o
left join product_clean p
on p.product_id_clean = o.product_id_clean
where order_status_clean = 'Completed')

select c.city_clean as city,sum(r.revenue) as total_revenue,
rank() over(order by  sum(r.revenue) desc) as rnk
from customer_clean c
left join revenue r
on c.customer_id_clean = r.customer_id_clean
group by c.city_clean
order by total_revenue desc;



---- Q12. What is the total revenue by product category?

select p.product_name_clean as product_name,sum(p.price_clean*o.quantity_clean) as Revenue
from product_clean p
left join orders_clean o
on p.product_id_clean = o.product_id_clean
where order_status_clean = 'Completed'
group by p.product_name_clean;

--- Q13. What is the average order value (AOV) by city?

with base as (select o.order_id_clean,o.customer_id_clean,(p.price_clean*o.quantity_clean) as value
from product_clean p
left join orders_clean o
on o.product_id_clean = p.product_id_clean
where o.quantity_clean is not null and p.price_clean is not null)

select c.city_clean as City,round(avg(b.value),2) as aov
from customer_clean c
join base b
on c.customer_id_clean = b.customer_id_clean
group by c.city_clean;


--- Q14 How many completed orders cannot generate revenue due to bad data?

select *,
		round((Revenue_blockage_orders*100.0/total_completed_orders),2) as  blockage_percent 
		from(select 
		count(*) as total_completed_orders,
		count(case when p.price_clean is null or o.quantity_clean is null then 1 end) as Revenue_blockage_orders
from orders_clean o
join product_clean p
on o.product_id_clean = p.product_id_clean
where order_status_clean = 'Completed');


--- Which cities have the highest number of broken completed orders?


select *,
		round((Revenue_blockage_orders*100.0/total_completed_orders),2) as  blockage_percent 
from (select c.city_clean as City,
		count(*) as total_completed_orders,
		count(case when p.price_clean is null or o.quantity_clean is null then 1 end) as Revenue_blockage_orders
from customer_clean c 
join orders_clean o on c.customer_id_clean = o.customer_id_clean 
left join product_clean p
on o.product_id_clean = p.product_id_clean
where order_status_clean = 'Completed'
group by  c.city_clean)
order by blockage_percent desc;


--- Which products appear most frequently in orders with missing critical data?

select *,rank() over(order by missing_data desc)as rnk
	from (select p.product_name_clean as products,
	count(case when p.price_clean is null or o.quantity_clean is null then 1 end) as missing_data
	from product_clean p
	left join orders_clean o
	on p.product_id_clean = o.product_id_clean
	group by p.product_name_clean);

--- Are data issues concentrated in specific cities or evenly distributed?

select c.city_clean as city,
		count(case when p.price_clean is null or p.price_clean < 0 then 1 end )as invalid_price,
		count(case when o.quantity_clean is null or o.quantity_clean <0 then 1  end) as invalid_quantity
from customer_clean c 
join orders_clean o on c.customer_id_clean = o.customer_id_clean 
left join product_clean p
on o.product_id_clean = p.product_id_clean
group by c.city_clean;

--- What % of orders data becomes usable after applying cleaning rules?


select total_data,valid_data,
(total_data - valid_data) as invalid_data,
round((valid_data*100.0/total_data),2) as valid_data_percent,
total_revenue 
from 
(select count(o.*) as total_data,
count(case when (p.price_clean is not null or p.price_clean >0)
and (o.order_date_clean is not null) 
and (o.quantity_clean is not null or o.quantity_clean > 0) then 1 end ) as Valid_data,
sum (case
when (p.price_clean is not null or p.price_clean >0)
and (o.order_date_clean is not null) 
and (o.quantity_clean is not null or o.quantity_clean > 0) then (p.price_clean*o.quantity_clean) end)  as total_Revenue
from orders_clean o
left join product_clean p
on p.product_id_clean = o.product_id_clean);







