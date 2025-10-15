/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    If they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_cust_info;
CREATE TABLE Bronze.crm_cust_info(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE
);

CREATE TABLE Bronze.crm_prd_info(
pro_id INT,
pro_key VARCHAR(50),
pro_nm VARCHAR(50),
pro_cost INT,
pro_line VARCHAR(50),
pro_start_dt DATETIME,
pro_end_dt DATETIME,
);

CREATE TABLE Bronze.crm_sales_details(
sls_ord_num VARCHAR(50),
sls_pro_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

CREATE TABLE Bronze.erp_cust_az12(
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50)
);

CREATE TABLE Bronze.erp_loc_a101(
cid NVARCHAR(50),
cntry NVARCHAR(50)
);

CREATE TABLE Bronze.erp_px_cat_g1v2(
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50)
);
