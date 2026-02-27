/*
===============================================================================
METADATA COLUMNS
===============================================================================
Extra columns added by the data engineers that do not originate from the source data.

create_date		: The record's load timestamp.
update_date		: The records's last update timestamp.
source-system	: The origin system of the record.
file_location	: The file source of the record.

Here, we have added one more extra column :- dwh_create_date DATETIME2 DEFAULT GETDATE()
Which when the data enters from the system, it created the logs accordingly for the
current datetime. It helps to keep track of the how and where the data comes from.
Which can be crucial when debugging in the later part if we encounter any error.

*/
SELECT @@VERSION;


IF OBJECT_ID('silver.crm_cust_info','U') is NOT NULL
	DROP TABLE silver.crm_cust_info;
Go
CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go

IF OBJECT_ID('silver.crm_prd_info','U') is NOT NULL
	DROP TABLE silver.crm_prd_info;
Go
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go


IF OBJECT_ID('silver.crm_sales_details','U') is NOT NULL
	DROP TABLE silver.crm_sales_details;
Go
CREATE TABLE silver.crm_sales_details(
	Sls_ord_num NVARCHAR(50),
	Sls_prd_key NVARCHAR(50),
	Sls_cust_id INT,
	Sls_order_dt Date,
	Sls_ship_dt Date,
	Sls_due_dt Date,
	Sls_sales INT,
	Sla_quantity INT,
	Sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go

IF OBJECT_ID('silver.erp_loc_a101','U') is NOT NULL
	DROP TABLE silver.erp_loc_a101;
Go

CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go



IF OBJECT_ID('silver.erp_cust_az12','U') is NOT NULL
	DROP TABLE silver.erp_cust_az12;
Go

CREATE TABLE silver.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go



IF OBJECT_ID('silver.erp_px_cat_g1v2','U') is NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
Go

CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go
