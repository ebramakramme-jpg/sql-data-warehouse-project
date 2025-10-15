/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
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

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '========================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '========================================================';
	
		PRINT '--------------------------------------------------------';
		PRINT 'Loading CRM Tables'
		PRINT '--------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_cust_info'
		TRUNCATE TABLE Bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: Bronze.crm_cust_info'
		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_prd_info'
		TRUNCATE TABLE Bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: Bronze.crm_prd_info'
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_sales_details'
		TRUNCATE TABLE Bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: Bronze.crm_sales_dedails'
		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '---------------'

		PRINT '--------------------------------------------------------';
		PRINT 'Loading ERP Tables'
		PRINT '--------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_cust_az12'
		TRUNCATE TABLE Bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: Bronze.erp_cust_az12'
		BULK INSERT Bronze.erp_cust_az12
		FROM 'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_loc_a101'
		TRUNCATE TABLE Bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: Bronze.erp_loc_a101'
		BULK INSERT Bronze.erp_loc_a101
		FROM 'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: Bronze.erp_px_cat_g1v2'
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------';
		
		SET @batch_end_time = GETDATE();
		PRINT '====================================='
		PRINT 'Total Load Duration ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '====================================='
	END TRY
	BEGIN CATCH
		PRINT '================================================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error message ' + ERROR_MESSAGE();
		PRINT 'Error message ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error message ' + ERROR_STATE();
		PRINT '================================================'
	END CATCH
END;
