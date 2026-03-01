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





/*
===============================================================================
						CREATE DIMENSION CUSTOMER
===============================================================================
*/



SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_material_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

--(i). After joining table, check if any duplicates were introduced by the join logic.
-- For that we again group by the above query to check the duplicate records.

SELECT cst_id, count(*) FROM
	(SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_material_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry
	from silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1 -- No duplicate records found.


--(ii). Now we have data integration issue like we have to gender columns so we need to check which column to keep.

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2
-- Here, we can see that there two diff. values in both columns.
-- In original scenario we need to ask which source is the master for these values?
-- In our case, The master source of the customer data is CRM! 

-- Solution:-

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender info.
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen --Use the master info first, if not found then use gndr info of ca table and again not foud then 'n/a'
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2


-- Final query after the above steps:-
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_material_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender info.
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen, --Use the master info first, if not found then use gndr info of ca table and again not foud then 'n/a'
	ci.cst_create_date,
	ca.bdate,
	la.cntry
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid






---(iii). Rename columns to friendly, meaningful names
SELECT
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	ci.cst_material_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender info.
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender, --Use the master info first, if not found then use gndr info of ca table and again not foud then 'n/a'
	ci.cst_create_date AS create_date,
	ca.bdate AS birthdate,
	la.cntry AS country
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid



---(iv). Sorting the columns into the logical groups to improve readability.
SELECT
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_material_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender info.
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender, --Use the master info first, if not found then use gndr info of ca table and again not foud then 'n/a'
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


--- We will call it dimension over fact. Why is it called dimension table?
-- Because it described the information about the customer over the measures which is called the facts.
-- So, we will call it "Dimension Customer."



---(v). Generating surrogate keys:-
-- System-generated unique identifier assigned to each rcord in a table.
-- It is crucial for the data model so we don't need to relay of source system(Customer_id) every time during joining.

CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_material_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid








/*
===============================================================================
							CREATE DIMENSION PRODUCTS
===============================================================================
*/

-- If end date is null then it is the current info of the product.
select prd_key, count(*) from (
select
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL--Filter out all historical data
)t group by prd_key
having count(*) > 1 --No duplicate prd key.



CREATE VIEW gold.dim_products AS
select
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id As category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line As product_line,
	pn.prd_start_dt AS start_date
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL



















/*
===============================================================================
							CREATE FACT SALES
===============================================================================
*/
SELECT
	sd.Sls_ord_num,
	sd.Sls_prd_key,
	sd.Sls_cust_id,
	sd.Sls_order_dt,
	sd.Sls_ship_dt,
	sd.Sls_due_dt,
	sd.Sls_sales,
	sd.Sla_quantity,
	sd.Sls_price
FROM silver.crm_sales_details sd

-- Here, we can see transctions, quantity, price(Measures) and lot of ids.
-- Which is connecting multiple dimensions. Which is facts.
-- Here, the surrogate keys comes from the dimension.
-- Building fact :- Use the dimension's surrogate keys insted of IDs to easily facts with dimensions.
-- Here, we will replace sls_prd_key and sls_cust_id with the surrogate keys we have already generated. This process is called the data lookup.
-- So we will use the dimension's surrogate keys insted of IDs to easily connect facts with dimensions.

CREATE VIEW gold.fact_sales AS
SELECT
	sd.Sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.Sls_order_dt As order_date,
	sd.Sls_ship_dt AS shipping_date,
	sd.Sls_due_dt AS due_date,
	sd.Sls_sales AS sales_amount,
	sd.Sla_quantity AS quantity,
	sd.Sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON Sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.Sls_cust_id = cu.customer_id
-- Now we have two dimensions key in our table :- product_key, customer_id



-- Fact check:-
-- Check if all dimension tables can successfully join to the fact table.
select*
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
left join gold.dim_products p
ON p.product_key = f.product_key
Where c.customer_id IS NULL --we are not getting anything means everything is working well.

-- Relationship:-
-- In a star schema, the relationship between fact and dimensions is 1-to-many(1:N)




