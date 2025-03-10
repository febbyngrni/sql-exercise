-- Session 1
-- Question 1
-- Show how many different product categories there are
select count(distinct product_category_name) 
from products p 

-- Question 2
-- Show how many total customers and total sellers there are
select 
	'customer' as category,
	count(distinct customer_unique_id) 
from customers c 
union
select 
	'seller' as category,
	count(distinct seller_id) 
from sellers s  

-- Question 3
-- Show top 10 cities that have the most customers
select
	customer_city,
	count(distinct customer_unique_id) as total_customer
from customers c 
group by 1
order by 2 desc
limit 10

-- Question 4
-- Show the percentage of the customer base that the top 10 cities have
select 
	customer_city,
	count(distinct customer_unique_id) as total_customer,
	(count(distinct customer_unique_id) / (select count(*) from customers c)::float) * 100 as percentage
from customers c 
group by 1
order by 2 desc
limit 10

select count(*) from customers c

-- Question 5
-- Show top 10 categories with the most total product variations
select 
	product_category_name,
	count(product_id) as total_unique_product 
from products p 
group by 1
order by 2 desc
limit 10

-- Question 6
-- Display descriptive statistics for weight_g, length_cm, height_cm, and width_cm
select
	'height_cm' as measured_variable,
	min(product_height_cm) as minimum,
	percentile_disc(0.25) within group(order by product_height_cm) as q1,
	percentile_disc(0.5) within group(order by product_height_cm) as q2,
	percentile_disc(0.75) within group(order by product_height_cm) as q3,
	max(product_height_cm) as maximum
from products p 
union
select
	'lenght_cm' as measured_variable,
	min(p.product_length_cm) as minimum,
	percentile_disc(0.25) within group(order by product_length_cm) as q1,
	percentile_disc(0.5) within group(order by product_length_cm) as q2,
	percentile_disc(0.75) within group(order by product_length_cm) as q3,
	max(product_length_cm) as maximum
from products p
union
select
	'weight_g' as measured_variable,
	min(p.product_weight_g) as minimum,
	percentile_disc(0.25) within group(order by product_weight_g) as q1,
	percentile_disc(0.5) within group(order by product_weight_g) as q2,
	percentile_disc(0.75) within group(order by product_weight_g) as q3,
	max(product_weight_g) as maximum
from products p
union
select
	'width_cm' as measured_variable,
	min(p.product_width_cm) as minimum,
	percentile_disc(0.25) within group(order by product_width_cm) as q1,
	percentile_disc(0.5) within group(order by product_width_cm) as q2,
	percentile_disc(0.75) within group(order by product_width_cm) as q3,
	max(product_width_cm) as maximum
from products p

-- Question 7
-- Show total purchases by customers for each day of the week, ignoring order status
select
	case 
		when extract(dow from o.order_purchase_timestamp) = 1 then 'Sunday'
		when extract(dow from o.order_purchase_timestamp) = 2 then 'Monday'
		when extract(dow from o.order_purchase_timestamp) = 3 then 'Tuesday'
		when extract(dow from o.order_purchase_timestamp) = 4 then 'Wednesday'
		when extract(dow from o.order_purchase_timestamp) = 5 then 'Thursday'
		when extract(dow from o.order_purchase_timestamp) = 6 then 'Friday'
		else 'Saturday'
	end as day_of_purchase,
	count(distinct order_id) as total_purchase	
from orders o 
group by 1
order by 2 desc

-- Question 8
-- Show the total number of cancelled orders, as well as the number of orders that are in the following phases: 
-- orders that have been approved, orders that have been received by the courier, 
-- and orders that have been received by the customer with a canceled status
select
	'order_cancaled' as order_stage,
	count(distinct order_id) 
from orders o 
where order_status = 'canceled'
union 
select
	'order_approved' as order_stage,
	count(distinct order_id) 
from orders o 
where order_approved_at is not null and order_status = 'canceled'
union 
select
	'order_delivered_carrier' as order_stage,
	count(distinct order_id) 
from orders o 
where order_delivered_carrier_date is not null and order_status = 'canceled'
union 
select
	'order_delivered_customer' as order_stage,
	count(distinct order_id) 
from orders o 
where order_delivered_customer_date is not null and order_status = 'canceled'

-- Question 9
-- Show a comparison of the proportion of usage of each payment type for orders with a cancelled status
with temp_table as(
	select
		p.payment_type,
		count(distinct p.order_id) as total_order
	from payments p 
	join orders o on p.order_id = o.order_id 
	where o.order_status = 'canceled'
	group by 1
	order by 2 desc
)
select *,
	total_order / sum(total_order) over()::float as prop_canceled_order
from temp_table
group by payment_type, total_order
order by 2 desc

-- Question 10
-- Show all products with the 3rd highest price in each product category
with temp_table as(
	select
		case when p.product_category_name = '' then 'other' else p.product_category_name end as product_category,
		p.product_id,
		oi.price,
		dense_rank() over(partition by case when p.product_category_name = '' then 'other' else p.product_category_name end order by oi.price desc) as rank_price
	from products p 
	join order_items oi on oi.product_id = p.product_id 
)
select distinct *
from temp_table
where rank_price = 3
order by 1 asc

-- Question 11
-- Display the average review score for the category of time to receive orders that are in accordance with the estimated time and the late category
select
	'On Time' as order_delivered_status,
	round(avg(r.review_score)::numeric , 2) as ratarata_score
from orders o 
join reviews r on r.order_id = replace(o.order_id::text, '-', '')
where o.order_delivered_customer_date <= o.order_estimated_delivery_date 
union 
select
	'Late' as order_delivered_status,
	round(avg(r.review_score)::numeric , 2) as ratarata_score
from orders o 
join reviews r on r.order_id = replace(o.order_id::text, '-', '')
where o.order_delivered_customer_date > o.order_estimated_delivery_date 

-- Question 12
-- Show the delivery time in days for orders with delivered status, from the time of purchase until the order is received by the customer
select
	extract (day from (order_delivered_customer_date - order_purchase_timestamp)) as days_of_purchase_delivered,
	count(distinct order_id) as total
from orders o 
where order_status = 'delivered'
group by 1
order by 2 desc

-- Question 13
-- Show 10 customers with the highest average purchase value that exclude orders with status other than delivered
select
	c.customer_unique_id,
	sum(p.payment_value) as total_revenue,
	count(distinct o.order_id) as total_order,
	sum(p.payment_value) / count(distinct o.order_id) as avg_purchase_value
from orders o 
join customers c on c.customer_id = o.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1
order by 4 desc
limit 10

-- Question 14
-- Show 10 customers with the highest average purchase frequency rate that exclude orders with status other than delivered
select
	c.customer_unique_id,
	count(distinct o.order_id) as total_order,
	count(customer_unique_id) over() as total_unique_customer,
	count(distinct o.order_id) / count(customer_unique_id) over()::float as avg_purchase_rate
from orders o 
join customers c on c.customer_id = o.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1
order by 4 desc
limit 10

-- Question 15
-- Show 15 customers with the highest customer value excluding orders with status other than delivered
select
	c.customer_unique_id,
	sum(p.payment_value) / count(distinct o.order_id) as avg_purchase_value,
	count(distinct o.order_id) / count(customer_unique_id) over()::float as avg_purchase_rate,
	sum(p.payment_value) / count(distinct o.order_id) * count(distinct o.order_id) / count(customer_unique_id) over()::float as customer_value
from orders o 
join customers c on c.customer_id = o.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1
order by 4 desc
limit 15


-- Session 2
-- Question 1
-- Show order totals for each order status
select
	order_status,
	count(order_id) as total_order 
from orders o 
group by 1
order by 2 desc

-- Question 2
-- Show the most cancelled product categories
select
	case when p.product_category_name = '' then 'other' else p.product_category_name end as product_category,
	count(distinct o.order_id) as total_order 
from products p 
join order_items oi on oi.product_id = p.product_id 
join orders o on o.order_id = oi.order_id 
where o.order_status = 'canceled'
group by 1
order by 2 desc

-- Question 3
-- Show information on customers who cancelled an order even though they have received it
select
	c.customer_unique_id,
	c.customer_city,
	o.order_status,
	o.order_delivered_customer_date 
from customers c 
join orders o on c.customer_id = o.customer_id 
where o.order_status = 'canceled' and o.order_delivered_customer_date is not null

-- Question 4
-- Show the projected total loss of revenue due to cancelled orders for each seller 
-- by multiplying the payment value and installment payment to obtain the projected revenue value
with temp_table as(
	select distinct 
		s.seller_id,
		s.seller_city,
		sum(p.payment_value) * p.payment_installments as loss_revenue
	from sellers s 
	join order_items oi on oi.seller_id = s.seller_id 
	join orders o on o.order_id = oi.order_id 
	join payments p on p.order_id = o.order_id 
	where o.order_status = 'canceled'
	group by 1,2, p.payment_value, p.payment_installments
)
select seller_id, seller_city, sum(loss_revenue) as total_loss_revenue
from temp_table
group by 1,2

-- Question 5
-- Show information on 10 sellers with the largest revenue with the revenue value 
-- obtained from the total payment value (without multiplying by the installment payment because it is not a projection)
select 
	s.seller_id,
	s.seller_city,
	sum(p.payment_value) as total_revenue
from sellers s 
join order_items oi on oi.seller_id = s.seller_id 
join orders o on o.order_id = oi.order_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1,2
order by 3 desc
limit 10

-- Question 6
-- Show information of 10 sellers who have the highest reviewers and review score
select 
	s.seller_id,
	s.seller_city,
	avg(r.review_score) as review_score_avg,
	count(r.review_id) as review_score_counts
from sellers s 
join order_items oi on oi.seller_id = s.seller_id 
join orders o on o.order_id = oi.order_id 
join reviews r on r.order_id = replace(o.order_id::text, '-', '')
group by 1,2
order by 4 desc
limit 10

-- Question 7
-- Show detailed sentiment towards sellers based on total review score with 
-- (‘negative’: [1, 2], ‘neutral’: [3], ‘positive’: [4, 5]), sort by sellers with larger negative sentiment first
select 
	s.seller_id,
	s.seller_city,
	sum(case when r.review_score in (1,2) then 1 else 0 end) as negative_count,
	sum(case when r.review_score in (3) then 1 else 0 end) as neutral_count,
	sum(case when r.review_score in (4,5) then 1 else 0 end) as positive_count
from sellers s 
join order_items oi on oi.seller_id = s.seller_id 
join orders o on o.order_id = oi.order_id 
join reviews r on r.order_id = replace(o.order_id::text, '-', '')
group by 1,2
order by 3 desc

-- Question 8
-- Show product categories with the highest ratio of total negative reviews to positive reviews based on total review score 
-- with (‘negative’: [1, 2], ‘neutral’: [3], ‘positive’: [4, 5])
select
	case when p.product_category_name = '' then 'other' else p.product_category_name end as product_category,
	sum(case when r.review_score in (1,2) then 1 else 0 end) as negative_count,
	sum(case when r.review_score in (3) then 1 else 0 end) as neutral_count,
	sum(case when r.review_score in (4,5) then 1 else 0 end) as positive_count,
	sum(case when r.review_score in (1,2) then 1 else 0 end) / sum(case when r.review_score in (4,5) then 1 else 0 end)::float as negative_to_positive_ratio
from products p 
join order_items oi on oi.product_id = p.product_id 
join orders o on o.order_id = oi.order_id 
join reviews r on r.order_id = replace(o.order_id::text, '-', '')
group by 1
order by 5 desc 

-- Question 9
-- Show the delivery route with the longest delivery time from when the order is purchased until the order is received by the customer
select
	s.seller_city,
	c.customer_city,
	avg(extract (day from (order_delivered_customer_date - order_purchase_timestamp))) as ratarata_days
from sellers s 
join order_items oi on oi.seller_id = s.seller_id 
join orders o on o.order_id = oi.order_id 
join customers c on c.customer_id = o.customer_id 
where o.order_status = 'delivered'
group by 1,2
having avg(extract (day from (order_delivered_customer_date - order_purchase_timestamp))) is not null
order by 3 desc

-- Question 10
-- Show conversion rate from order purchase, order approved, order received by courier, to order received by customer by ignoring order status
with union_table as(
	select 
		'purchased' as stage,
		count(order_id) as total
	from orders o 
	where o.order_purchase_timestamp is not null
	union 
	select 
		'approved' as stage,
		count(order_id) as total
	from orders o 
	where o.order_approved_at is not null
	union 
	select 
		'delivered_carrier' as stage,
		count(order_id) as total
	from orders o 
	where o.order_delivered_carrier_date is not null
	union 
	select 
		'delivered_customer' as stage,
		count(order_id) as total
	from orders o 
	where o.order_delivered_customer_date is not null
)
select *,
	lead(total) over(order by total) as previous_total,
	round(total / lead(total) over(order by total)::numeric, 3) as conversion_rate
from union_table
order by 2 desc

-- Question 11
-- Show the 10 heaviest-weighted product categories as well as the average shipping cost of these product categories
with temp_table as(
	select distinct 
		case when p.product_category_name = '' then 'other' else p.product_category_name end as product_category,
		max(p.product_weight_g) over(partition by case when p.product_category_name = '' then 'other' else p.product_category_name end) as bobot,
		avg(oi.freight_value) over(partition by case when p.product_category_name = '' then 'other' else p.product_category_name end) as ratarata_ongkir
	from products p 
	join order_items oi on oi.product_id = p.product_id 
	order by 3 desc
	limit 10
)
select product_category, ratarata_ongkir
from temp_table

-- Question 12
-- Show the heaviest weighted products for each product category
with max_weight as(
	select 
		case when p.product_category_name = '' then 'other' else p.product_category_name end as product_category,
		p.product_id,
        p.product_weight_g,
        max(p.product_weight_g) over(partition by case when p.product_category_name = '' then 'other' else p.product_category_name end) as maximum_weight 
	from products p 
	join order_items oi on oi.product_id = p.product_id
)
select distinct 
	product_category,
	product_id,
	product_weight_g
from max_weight
where product_weight_g = maximum_weight

-- Question 13
-- Show 10 routes that have the highest shipping cost without considering the weight or dimensions of the product
select
	p.product_id,
	concat(s.seller_city, ' - ' ,c.customer_city) as rute,
	oi.freight_value 
from products p 
join order_items oi on oi.product_id = p.product_id 
join sellers s on s.seller_id = oi.seller_id 
join orders o on o.order_id = oi.order_id 
join customers c on c.customer_id = o.customer_id 
order by 3 desc
limit 10

-- Question 14
-- Show favourite delivery routes or those with the most total deliveries for that delivery route
select
	concat(s.seller_city, ' - ' ,c.customer_city) as rute,
	count(distinct o.order_id) as total_order 
from sellers s 
join order_items oi on oi.seller_id = s.seller_id 
join orders o on o.order_id = oi.order_id 
join customers c on c.customer_id = o.customer_id 
group by 1
order by 2 desc 

-- Question 15
-- Show 10 products and product categories that have the highest ratio of shipping cost and product price
select distinct 
	p.product_id,
	oi.freight_value,
	oi.price,
	round(oi.freight_value / oi.price::numeric, 2) as ratio
from products p 
join order_items oi on oi.product_id = p.product_id 
order by 4 desc
limit 10