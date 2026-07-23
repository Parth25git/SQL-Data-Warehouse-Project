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

