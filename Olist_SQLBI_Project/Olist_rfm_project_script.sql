CREATE DATABASE olist_rfm_project;
USE olist_rfm_project;

CREATE TABLE olist_customers_dataset (
customer_id VARCHAR(50),
customer_unique_id VARCHAR(50),
customer_zip_code_prefix INT,
customer_city VARCHAR(50),
customer_state VARCHAR(10)
);
SELECT COUNT(*) FROM olist_customers_dataset;
-- SELECT * FROM customers LIMIT 10;
-- SHOW TABLES;

CREATE TABLE olist_orders_dataset (
order_id VARCHAR(50),
customer_id VARCHAR(50),
order_status VARCHAR(30),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME
);
SELECT COUNT(*) FROM olist_orders_dataset;
SHOW TABLES;
-- DROP TABLE olist_order_dataset;

CREATE TABLE olist_order_items_dataset (
order_id VARCHAR(100),
order_item_id VARCHAR(100),
product_id VARCHAR(100),
seller_id VARCHAR(100),
shipping_limit_date VARCHAR(100),
price VARCHAR(100),
freight_value VARCHAR(100)
);
SELECT COUNT(*) FROM olist_order_items_dataset;
-- drop table olist_order_items_dataset;

CREATE TABLE olist_order_payments_dataset (
order_id VARCHAR(50),
payment_sequential INT,
payment_type VARCHAR(50),
payment_installments INT,
payment_value DECIMAL(10,2)
);
SELECT COUNT(*) FROM olist_order_payments_dataset;
-- DROP TABLE IF EXISTS olist_order_payments_dataset;

-- NOT WORKING-- FAILURE OF IMPORTING REVIEWS TABLE
-- CREATE TABLE olist_order_reviews_dataset (
-- review_id VARCHAR(100),
-- order_id VARCHAR(100),
-- review_score INT,
-- review_comment_title LONGTEXT,
-- review_comment_message LONGTEXT,
-- review_creation_date VARCHAR(50),
-- review_answer_timestamp VARCHAR(50)
-- );
-- SELECT COUNT(*) FROM olist_order_reviews_dataset;
-- DROP TABLE IF EXISTS olist_order_reviews_dataset;

-- Validation
SELECT COUNT(*) FROM olist_customers_dataset;
SELECT COUNT(*) FROM olist_orders_dataset;
SELECT COUNT(*) FROM olist_order_items_dataset;
SELECT COUNT(*) FROM olist_order_payments_dataset;

-- Null Check
SELECT *
FROM olist_orders_dataset
WHERE order_id IS NULL;

-- Duplicate check
SELECT order_id, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Join test
SELECT o.order_id, o.customer_id, c.customer_city
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
LIMIT 10;

-- Total Orders
SELECT COUNT(DISTINCT order_id) FROM olist_orders_dataset;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) FROM olist_customers_dataset;

-- Revenue Analysis
SELECT SUM(price) AS total_revenue
FROM olist_order_items_dataset;

-- Customers-level analysis
-- Top Customers
SELECT o.customer_id, SUM(i.price) AS total_spent
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- City-wise performance
SELECT c.customer_city, SUM(i.price) AS revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
GROUP BY c.customer_city
ORDER BY revenue DESC;

-- RFM analysis
-- Recency
SELECT customer_id,
MAX(order_purchase_timestamp) AS last_order
FROM olist_orders_dataset
GROUP BY customer_id;
-- Frequency
SELECT customer_id,
COUNT(order_id) AS frequency
FROM olist_orders_dataset
GROUP BY customer_id
ORDER BY frequency DESC;
-- Monetary
SELECT o.customer_id,
SUM(i.price) AS monetary
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
GROUP BY o.customer_id
ORDER BY monetary DESC;


-- Combine RFM query
SELECT o.customer_id,
MAX(o.order_purchase_timestamp) AS last_order,
COUNT(DISTINCT o.order_id) AS frequency,
SUM(i.price) AS monetary
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
GROUP BY o.customer_id;

--  Customer Segmentation  
SELECT o.customer_id,
COUNT(DISTINCT o.order_id) AS frequency,
SUM(i.price) AS monetary,
CASE
    WHEN COUNT(DISTINCT o.order_id) >= 10 
         AND SUM(i.price) >= 5000
    THEN 'High Value'
    WHEN COUNT(DISTINCT o.order_id) >= 5
    THEN 'Loyal'
    WHEN SUM(i.price) < 500
    THEN 'Low Value'
    ELSE 'At Risk'
END AS customer_segment
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
GROUP BY o.customer_id;

-- Monthly Sales Trend
SELECT 
DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS order_month,
COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY order_month
ORDER BY order_month;

-- Monthly Revenue Trend
SELECT 
DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS order_month,
ROUND(SUM(p.payment_value),2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month; 

-- Top States by Revenue
SELECT 
c.customer_state,
ROUND(SUM(p.payment_value),2) AS revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- Delivery Delays Analysis
SELECT 
COUNT(order_id) AS delayed_orders
FROM olist_orders_dataset
WHERE order_delivered_customer_date >
order_estimated_delivery_date;  

-- Avg Delivery Time
SELECT 
ROUND(AVG(DATEDIFF(order_delivered_customer_date,
order_purchase_timestamp)),2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

-- Payment Method Analysis
SELECT 
payment_type,
COUNT(*) AS total_payments
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payments DESC;

-- Review Score Analysis
-- SELECT 
-- review_score,
-- COUNT(*) AS total_reviews
-- FROM olist_order_reviews_dataset
-- GROUP BY review_score
-- ORDER BY review_score DESC;

-- Advanced SQL (Window Functions)
SELECT 
customer_id,
SUM(payment_value) AS total_spent,
RANK() OVER(ORDER BY SUM(payment_value) DESC) AS customer_rank
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY customer_id;    


-- RFM Project
SELECT
c.customer_unique_id,

MAX(o.order_purchase_timestamp) AS last_purchase_date,

DATEDIFF(
(SELECT MAX(order_purchase_timestamp)
FROM olist_orders_dataset),
MAX(o.order_purchase_timestamp)
) AS recency,

COUNT(DISTINCT o.order_id) AS frequency,

ROUND(SUM(CAST(oi.price AS DECIMAL(10,2))),2) AS monetary

FROM olist_customers_dataset c

JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id

JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id

GROUP BY c.customer_unique_id; 

-- RFM Scores
SELECT
customer_unique_id,
recency,
frequency,
monetary,

-- Recency Score
CASE
    WHEN recency <= 30 THEN 5
    WHEN recency <= 60 THEN 4
    WHEN recency <= 90 THEN 3
    WHEN recency <= 180 THEN 2
    ELSE 1
END AS recency_score,

-- Frequency Score
CASE
    WHEN frequency >= 10 THEN 5
    WHEN frequency >= 7 THEN 4
    WHEN frequency >= 5 THEN 3
    WHEN frequency >= 3 THEN 2
    ELSE 1
END AS frequency_score,

-- Monetary Score
CASE
    WHEN monetary >= 1000 THEN 5
    WHEN monetary >= 500 THEN 4
    WHEN monetary >= 250 THEN 3
    WHEN monetary >= 100 THEN 2
    ELSE 1
END AS monetary_score

FROM (

SELECT
c.customer_unique_id,

DATEDIFF(
(SELECT MAX(order_purchase_timestamp)
FROM olist_orders_dataset),
MAX(o.order_purchase_timestamp)
) AS recency,

COUNT(DISTINCT o.order_id) AS frequency,

ROUND(SUM(CAST(oi.price AS DECIMAL(10,2))),2) AS monetary

FROM olist_customers_dataset c

JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id

JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id

GROUP BY c.customer_unique_id

) AS rfm_data;


-- Customer Segment
SELECT
customer_unique_id,
recency,
frequency,
monetary,
recency_score,
frequency_score,
monetary_score,

CASE

WHEN recency_score >= 4
AND frequency_score >= 4
AND monetary_score >= 4
THEN 'Champions'

WHEN frequency_score >= 4
AND monetary_score >= 3
THEN 'Loyal Customers'

WHEN recency_score >= 4
AND frequency_score <= 2
THEN 'Potential Loyalists'

WHEN recency_score <= 2
AND frequency_score >= 3
THEN 'At Risk Customers'

WHEN recency_score <= 2
AND frequency_score <= 2
THEN 'Lost Customers'

ELSE 'Regular Customers'

END AS customer_segment

FROM (

SELECT
customer_unique_id,
recency,
frequency,
monetary,

CASE
    WHEN recency <= 30 THEN 5
    WHEN recency <= 60 THEN 4
    WHEN recency <= 90 THEN 3
    WHEN recency <= 180 THEN 2
    ELSE 1
END AS recency_score,

CASE
    WHEN frequency >= 10 THEN 5
    WHEN frequency >= 7 THEN 4
    WHEN frequency >= 5 THEN 3
    WHEN frequency >= 3 THEN 2
    ELSE 1
END AS frequency_score,

CASE
    WHEN monetary >= 1000 THEN 5
    WHEN monetary >= 500 THEN 4
    WHEN monetary >= 250 THEN 3
    WHEN monetary >= 100 THEN 2
    ELSE 1
END AS monetary_score

FROM (

SELECT
c.customer_unique_id,

DATEDIFF(
(SELECT MAX(order_purchase_timestamp)
FROM olist_orders_dataset),
MAX(o.order_purchase_timestamp)
) AS recency,

COUNT(DISTINCT o.order_id) AS frequency,

ROUND(SUM(CAST(oi.price AS DECIMAL(10,2))),2) AS monetary

FROM olist_customers_dataset c

JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id

JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id

GROUP BY c.customer_unique_id

) AS rfm_data

) AS scored_rfm;