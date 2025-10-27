 /*This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend */

CREATE VIEW report_customers AS
WITH base_quary AS(
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(YEAR, birthdate, GETDATE())AS age
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c
ON f.customer_key = c.customer_key
)
, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT product_key) AS total_products,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_quary
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 30 and 39 THEN '30-39'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
	END AS 'age_group',
	total_products,
	total_orders,
	total_sales,
	total_quantity,
	lifespan,
	CASE 
		 WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS 'customer_segment',
		last_order_date,
		DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
		-- Compuate average order value (AOV)
		CASE WHEN total_orders = 0 THEN 0
			 ELSE total_sales / total_orders
		END AS avg_order_value,

		-- Compuate average monthly spend
		CASE WHEN lifespan = 0 THEN total_sales
			 ELSE total_sales / lifespan
		END AS avg_monthly_spend
FROM customer_aggregation
------------------------------------------------------------
CREATE VIEW report_products AS 
WITH base_query AS (
SELECT
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	COUNT(DISTINCT f.customer_key) AS total_customers,
	COUNT(DISTINCT f.order_number) AS total_orders,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	SUM(f.sales_amount) AS total_sales,
	SUM(f.quantity) AS total_quantity
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
ON f.product_key = p.product_key
GROUP BY 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_customers,
	total_orders,
	last_order_date,
	lifespan,
	total_sales,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	total_quantity,
	DATEDIFF(MONTH , last_order_date, GETDATE()) AS recency_in_months,
	-- Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM base_query
