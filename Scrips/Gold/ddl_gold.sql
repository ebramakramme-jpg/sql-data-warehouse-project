/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
		la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON		ci.cst_key = la.cid;

CREATE VIEW gold.dim_Products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.pro_start_dt, pn.pro_key) AS product_key,
	pn.pro_id AS product_id,
	pn.pro_key AS product_number,
	pn.pro_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.pro_cost AS cost,
	pn.pro_line AS product_line,
	pn.pro_start_dt AS start_date
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON		pn.cat_id = pc.id
WHERE pro_end_dt IS NULL -- Current data only

CREATE VIEW gold.fact_sales AS
SELECT
	sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price AS price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_Products pr
ON sd.sls_pro_key = pr.product_number
LEFT JOIN Gold.dim_customers cu
ON	sd.sls_cust_id = cu.customer_id
