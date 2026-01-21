-- Create database 'DataWarehouse'
SELECT @@VERSION;
USE master;
	Create database DataWarehouse;

	USE DataWarehouse;
	GO
	CREATE SCHEMA bronze;
	GO
	CREATE SCHEMA silver;
	Go
	CREATE SCHEMA gold;
	GO
	-- Go is just like seperate command which tells SQL server to execute the first first query fully then go to 2nd query.



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






IF OBJECT_ID('bronze.crm_cust_info','U') is NOT NULL
	DROP TABLE bronze.crm_cust_info;
Go
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
Go

IF OBJECT_ID('bronze.crm_prd_info','U') is NOT NULL
	DROP TABLE bronze.crm_prd_info;
Go
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
Go


IF OBJECT_ID('bronze.crm_sales_details','U') is NOT NULL
	DROP TABLE bronze.crm_sales_details;
Go
CREATE TABLE bronze.crm_sales_details(
	Sls_ord_num NVARCHAR(50),
	Sls_prd_key NVARCHAR(50),
	Sls_cust_id INT,
	Sls_order_dt INT,
	Sls_ship_dt INT,
	Sls_due_dt INT,
	Sls_sales INT,
	Sla_quantity INT,
	Sls_price INT
);
Go

IF OBJECT_ID('bronze.erp_loc_a101','U') is NOT NULL
	DROP TABLE bronze.erp_loc_a101;
Go

CREATE TABLE bronze.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
Go



IF OBJECT_ID('bronze.erp_cust_az12','U') is NOT NULL
	DROP TABLE bronze.erp_cust_az12;
Go

CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
Go



IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') is NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
Go

CREATE TABLE bronze.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
Go



