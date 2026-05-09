CREATE DATABASE superstore_project;
USE superstore_project;

CREATE TABLE orders (
  order_id VARCHAR(20),
  order_date VARCHAR(20),
  ship_date VARCHAR(20),
  ship_mode VARCHAR(50),
  customer_name VARCHAR(100),
  segment VARCHAR(50),
  country VARCHAR(50),
  city VARCHAR(50),
  state VARCHAR(50),
  region VARCHAR(50),
  product_name VARCHAR(150),
  category VARCHAR(50),
  sub_category VARCHAR(50),
  sales FLOAT,
  quantity INT,
  discount FLOAT,
  profit FLOAT
);
SELECT * FROM orders;
-- DROP TABLE orders;
SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 10;

SELECT order_date FROM orders LIMIT 10;
UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y');
SELECT COUNT(*) FROM orders;

-- Data cleaning check 
-- Null check 
SELECT * FROM orders 
WHERE sales IS NULL OR order_date IS NULL;

-- Duplicate check
SELECT order_id, COUNT(*) 
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Real duplicate check
SELECT order_id, product_name, COUNT(*)
FROM orders
GROUP BY order_id, product_name
HAVING COUNT(*) > 1;

-- Date format check
SELECT order_date FROM orders LIMIT 10;

-- Customer Segmentation Analysis
SELECT customer_name,
SUM(sales) AS total_spent,
CASE 
  WHEN SUM(sales) > 5000 THEN 'High Value'
  WHEN SUM(sales) BETWEEN 2000 AND 5000 THEN 'Medium Value'
  ELSE 'Low Value'
END AS segment
FROM orders
GROUP BY customer_name
ORDER BY total_spent DESC;

-- Top 10 Customers
SELECT customer_name, SUM(sales) AS total_spent
FROM orders
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- Category Revenue
SELECT category, SUM(sales) AS revenue
FROM orders
GROUP BY category
ORDER BY revenue DESC;

-- Monthly Trend
SELECT MONTH(order_date) AS month, SUM(sales) AS sales
FROM orders
GROUP BY MONTH(order_date)
ORDER BY month;

