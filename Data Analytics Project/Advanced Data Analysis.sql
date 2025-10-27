-- Change Over time

SELECT
	YEAR(order_date) AS order_year,
	month(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL and YEAR(order_date) = '2010'
GROUP BY YEAR(order_date), month(order_date)
ORDER BY YEAR(order_date), month(order_date)
--------------------------------------------------------------------
-- Cumulative Analysis
-- calculate the total sales per month and the running total of sales over time

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM(
	SELECT
		DATETRUNC(YEAR, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM [gold.fact_sales]
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date))t
-----------------------------------------------------------------------
-- Performance Analysis
 /* Analyze the yearly performance of products by comparing each product's sales to both its average
sales performance and the previous year's sales */

WITH yearly_product_sales AS (
SELECT
	YEAR(s.order_date) AS order_year,
	p.product_name,
	SUM(s.sales_amount) AS current_sales
FROM [gold.fact_sales] s
LEFT JOIN [gold.dim_products] p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(s.order_date),
	p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END AS avg_change,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year
-----------------------------------------------------------------
-- Part to Whole
-- Which categories contribute the most to Overall sales?

WITH category_sales AS(
SELECT
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM [gold.fact_sales] s
LEFT JOIN [gold.dim_products] p
ON s.product_key = p.product_key
GROUP BY p.category
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
-------------------------------------------------------------------------
-- Data Segmentation
-- Segment Products into cost ranges and count how many products fall into each segment
WITH product_segments AS(
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END 'cost_range'
FROM [gold.dim_products]
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC 
---------------------------------------------------------------

WITH customer_spending AS (
SELECT
	c.customer_key,
	MIN(s.order_date) AS first_date,
	MAX(s.order_date) AS last_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	SUM(s.sales_amount) AS total_spending
FROM [gold.fact_sales] s
LEFT JOIN [gold.dim_customers] c
ON s.customer_key = s.customer_key
GROUP BY c.customer_key
)
SELECT
	customer_segments,
	COUNT(customer_key) AS total_customers
FROM(
	SELECT
		customer_key,
		lifespan,
		total_spending,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segments
	FROM customer_spending)t
GROUP BY customer_segments
ORDER BY total_customers DESC;
