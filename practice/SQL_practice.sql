								/* Customer Intelligence */

--(1). The marketing team wants a quick contact list. Pull the full name and country of every customer in the database.
select trim(concat(first_name,' ',last_name)) as full_name, country from gold.dim_customers;

	-- Alternative Solution Using string concatenation:-
	-- SELECT first_name + ' ' + last_name AS full_name, country FROM gold.dim_customers;


--(2). HR wants to analyze workforce diversity data shared by a client. Retrieve each customer's gender and marital status.
select gender, marital_status from gold.dim_customers;


--(3). A stakeholder wants to know how long customers have been in the system. Select the customer number and the date they were created.
select
customer_number, create_date
from gold.dim_customers;

		-- If the question required "how long customers have been in the system"
			--select
			--customer_number, create_date,
			--datediff(DAY/MONTH/YEAR, create_date, getdate()) AS Day_Diff
			--from gold.dim_customers;


--(4). The CRM team needs a reference sheet. Pull customer key, customer number, first name, last name, and country — in that exact order.
select
customer_key, customer_number, first_name, last_name, country
from gold.dim_customers;


--(5). Management wants to identify customers by their age profile. Retrieve customer number and birthdate for all customers.
select
customer_number, birthdate
from gold.dim_customers;




												/* Product Intelligence */

--(6). The procurement team wants a cost overview. Pull product name and cost for all products.
select
product_name,cost
from gold.dim_products;


--(7). A product manager asks — "which product lines do we operate in?" Write a query to retrieve just the product line and category columns.
select
product_line,category
from gold.dim_products;

--(8). The maintenance team needs a checklist. Retrieve product name, subcategory, and maintenance status for all products.
select
product_name, subcategory, maintenance
from gold.dim_products;

--(9). Finance wants to model a price increase scenario. Select product name and cost, and show a second column with cost increased by 15%, aliased as projected_cost.
select
product_name, cost * 1.15 AS projected_cost
from gold.dim_products;

--(10). The catalog team wants to audit product identifiers. Retrieve product number, product name, and category in a clean readable format.
select
product_number, product_name, category
from gold.dim_products;






/* Core skill: retrieving and shaping data for business consumption */


-- (1). The finance team needs a clean sales summary report. 
-- Each row should show the order reference, who the customer is as a single field, the product they bought, and the revenue generated
--  — with all column names readable by a non-technical stakeholder.

select 
	fs.order_number As Order_Reference,
	concat(dc.first_name,' ',dc.last_name) as Customer_Name,
	dp.product_name as Product_Name,
	fs.sales_amount
from gold.fact_sales as fs
join gold.dim_customers as dc
	on fs.customer_key = dc.customer_key
join gold.dim_products as dp
	on fs.product_key = dp.product_key


--(2). Leadership wants a product profitability snapshot. 
-- For every product, show the product name, its current cost, and what the revenue would look like at both a 20% and 40% margin — as separate columns.

select
	dp.product_name,
	dp.cost,
	Round(dp.cost / 0.8,2) as Revenue_At_20_Margin,
	Round(dp.cost / 0.6,2 ) as Revenue_At_40_Margin
from gold.dim_products as dp



-- (3). The operations team wants to flag orders where the shipped amount does not match the expected price. 
-- Show order number, the stored price, the stored quantity, and what the revenue should have been if price × quantity were used.


-- (i). Flag indicator whether they match or not?
select
	order_number,
	price AS Stored_Price,
	quantity AS Stored_Quantity,
	(price * quantity) AS Expected_revenue,
	sales_amount AS stored_revenue,
	CASE
		when sales_amount = price * quantity then 'Match'
		else 'Mismatch'
	END AS Revenue_Status
from gold.fact_sales;


--(ii). Or, if the goal is to show only problematic orders, add a filter:
SELECT
    order_number,
    price,
    quantity,
    sales_amount,
    price * quantity AS Expected_Revenue
FROM gold.fact_sales
WHERE sales_amount <> price * quantity;
