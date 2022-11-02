/* Write a query that displays the order ID, account ID, and total dollar amount 
for all the orders, sorted first by the account ID (in ascending order), 
and then by the total dollar amount (in descending order). */

SELECT id,account_id, total_amt_usd
 FROM orders
 ORDER BY account_id, total_amt_usd DESC;
 
/* Now write a query that again displays order ID, account ID, and total dollar amount 
for each order, but this time sorted first by total dollar amount (in descending order), 
and then by account ID (in ascending order). */
 
SELECT id,account_id, total_amt_usd
 FROM orders
 ORDER BY  total_amt_usd DESC,account_id;
 
/* Pulls the first 5 rows and all columns from the orders table that have a dollar amount of gloss_amt_usd 
greater than or equal to 1000.*/


SELECT * 
 FROM orders
 WHERE gloss_amt_usd >= 1000
 LIMIT 5;
 
/* Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc) 
just for the Exxon Mobil company in the accounts table.*/
SELECT name, website, primary_poc
 FROM accounts
 WHERE name = 'Exxon Mobil';
 
/* Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for 
standard paper for each order. 
Limit the results to the first 10 orders, and include the id and account_id fields. */

SELECT id, account_id,
	standard_amt_usd / standard_qty as standard_paper_unit_price
	FROM orders
	LIMIT 10;

/* Write a query that finds the percentage of revenue that comes from poster paper for each order. 
You will need to use only the columns that end with _usd. (Try to do this without using the total column.) 
Display the id and account_id fields also. */

SELECT id, account_id,
		poster_amt_usd / (standard_amt_usd + gloss_amt_usd + poster_amt_usd) as poster_rev_perc
	FROM orders
	LIMIT 10;

/* Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. 
Only include the id field in the resulting table.*/

SELECT id ,gloss_qty, poster_qty
	FROM orders
	WHERE gloss_qty > 4000 OR poster_qty > 4000;
	
/* Write a query that returns a list of orders where the standard_qty is zero and 
either the gloss_qty or poster_qty is over 1000. */

SELECT id ,standard_qty,gloss_qty, poster_qty
	FROM orders
	WHERE (gloss_qty > 1000 OR poster_qty > 1000)
	AND standard_qty = 0 ;
	
/* Find all the company names that start with a 'C' or 'W', and 
the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.*/

SELECT *
	FROM accounts
	WHERE (name LIKE 'C%' OR name LIKE'W%')
	AND (primary_poc LIKE '%ana%' or primary_poc LIKE '%Ana%')
	AND primary_poc NOT LIKE '%eana%'

