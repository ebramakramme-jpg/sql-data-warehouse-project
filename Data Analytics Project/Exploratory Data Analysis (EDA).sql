-- SELECT * FROM INFORMATION_SCHEMA.TABLES
-- SELECT * FROM INFORMATION_SCHEMA.COLUMNS

SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
	-- DATEDIFF function (interval, start date, end date)
FROM [gold.fact_sales]

SELECT
	MIN(birthdate) AS oldest,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age,
	DATEDIFF(YEAR, MIN(birthdate), MAX(birthdate))
FROM [gold.dim_customers]

-- Find the Total Sales
SELECT 
	SUM(sales_amount) AS total_sales	
FROM [gold.fact_sales]

-- Find how many items are sold 
SELECT 
	SUM(quantity) AS items_sold
FROM [gold.fact_sales]

-- Find the average selling price
SELECT
	AVG(price) AS Average_price
FROM [gold.fact_sales]

-- Find the Total number of orders
SELECT
	COUNT(order_number) AS total_no_of_orders
FROM [gold.fact_sales]

-- Find the Total number of Products
SELECT
	COUNT(product_key) AS total_no_of_products
FROM [gold.fact_sales]

-- Find the total number of customers
SELECT
	COUNT(customer_key) AS total_no_of_customers
FROM [gold.dim_customers]

-- Find the Total number of Customers that has placed an order
SELECT
	COUNT(DISTINCT(customer_key)) AS total_no_of_customers
FROM [gold.fact_sales]

-- Find total customers by countries
SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM [gold.dim_customers]
GROUP BY country
ORDER BY total_customers DESC;

-- What is the average costs in each category?
SELECT
	category,
	AVG(cost) AS avg_costs
FROM [gold.dim_products]
GROUP BY category
ORDER BY avg_costs DESC;

-- What is the total revenue generated for each category?
SELECT
	category,
	SUM(sales_amount) AS total_revenue
FROM [gold.dim_products] p
INNER JOIN [gold.fact_sales] s
ON p.product_key = s.product_key
GROUP BY category
ORDER BY total_revenue DESC;

-- Which 5 products generate the hightest revenue
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales ASC;

SELECT *
FROM(
SELECT
	p.product_name,
	SUM(f.sales_amount) AS total_sales,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
ON f.product_key = p.product_key
GROUP BY p.product_name)t
WHERE rank_products <= 5;
