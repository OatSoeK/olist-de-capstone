--1. Find the top 5 states by customer count.
SELECT customer_state, COUNT(*) AS state
FROM customers AS c
GROUP BY c.customer_state
ORDER BY state desc ;

--2. Count unique customers using customer_unique_id.
select count (distinct customer_unique_id) from customers;

--3. Find the most-used payment type and its total payment value.
select op.payment_type ,count(*) as type ,SUM(op.payment_value ) as total_value
from order_payments op 
group by op.payment_type 
order by total_value desc

--Count reviews for each score (1-5) and find the average score.
select review_score,count (*) as total_review_score,Round(AVG(t.review_score ),3) as avg_score 
from order_reviews t 
group by t.review_score 
order by t.review_score 

-- Find seller states with more than 50 sellers.
select s.seller_state ,count(*) as state  
from sellers s 
group by s.seller_state 
having count(*) > 50
order by state  desc

--6. Calculate the average price and freight per item, rounded to 2 decimals.
select
round(AVG(price),2) as avg_price,
round(AVG(freight_value),2) as avg_freight
from order_items 




