/*Provide a table for all web_events associated with account name of Walmart. There should be three columns. 
Be sure to include the primary_poc, time of the event, and the channel for each event. 
Additionally, you might choose to add a fourth column to assure only Walmart events were chosen. */

SELECT acc.primary_poc,we.occurred_at, we.channel, acc."name"		 
	FROM web_events we
	JOIN accounts acc
	ON we.account_id = acc.id
	WHERE acc.name = 'Walmart';
	
/*Provide a table that provides the region for each sales_rep along with their associated accounts. 
Your final table should include three columns: the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name. */

SELECT re."name" region_name,sr."name" sales_rep_name , acc."name" account_name
	FROM accounts acc
	JOIN sales_reps sr
	ON acc.sales_rep_id = sr.id
	JOIN region re
	ON re.id = sr.region_id
	ORDER BY acc."name" ASC;
	
	
/* Provide the name for each region for every order, as well as the account name and the unit price they paid 
(total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name,and unit 
price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero. */

SELECT ord.id, re."name"  region_name, acc."name" account_name,
	(ord.total_amt_usd / (ord.total+0.01)) unit_price
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON sr.id = acc.sales_rep_id
	JOIN region re
	ON re.id = sr.region_id;
	
/* Provide a table that provides the region for each sales_rep along with their associated accounts. This time only 
for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and 
the account name. Sort the accounts alphabetically (A-Z) according to account name. */

SELECT reg."name"  region_name, sr."name"  sales_rep_name, acc."name" account_name
	FROM region reg
	JOIN sales_reps sr
	ON reg.id = sr.region_id
	JOIN accounts acc
	ON sr.id = acc.sales_rep_id
	WHERE reg."name" = 'Midwest'
	ORDER BY acc."name" ;
	
/*Provide a table that provides the region for each sales_rep along with their associated accounts. This time only 
for accounts where the sales rep has a first name starting with S and in the Midwest region. Your final table 
should include three columns: the region name, the sales rep name, and the account name. Sort the accounts 
alphabetically (A-Z) according to account name. */

SELECT reg."name"  region_name, sr."name"  sales_rep_name, acc."name" account_name
	FROM region reg
	JOIN sales_reps sr
	ON reg.id = sr.region_id
	JOIN accounts acc
	ON sr.id = acc.sales_rep_id
	WHERE reg."name" = 'Midwest'
	AND sr."name" LIKE 'S%'
	ORDER BY acc."name" ;

/* Provide a table that provides the region for each sales_rep along with their associated accounts. This time only 
for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table 
should include three columns: the region name, the sales rep name, and the account name. Sort the accounts 
alphabetically (A-Z) according to account name. */

SELECT reg."name"  region_name, sr."name"  sales_rep_name, acc."name" account_name
	FROM region reg
	JOIN sales_reps sr
	ON reg.id = sr.region_id
	JOIN accounts acc
	ON sr.id = acc.sales_rep_id
	WHERE reg."name" = 'Midwest'
	AND sr."name" LIKE '% K%'
	ORDER BY acc."name" ;
	
	
/*Provide the name for each region for every order, as well as the account name and the unit price 
they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard 
order quantity exceeds 100. Your final table should have 3 columns: region name, account name, and unit price.*/
	
SELECT re."name"  region_name, acc."name" account_name,
	(ord.total_amt_usd / (ord.total+0.01)) unit_price
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON sr.id = acc.sales_rep_id
	JOIN region re
	ON re.id = sr.region_id
	WHERE ord.standard_qty >=100;
	
/*Provide the name for each region for every order, as well as the account name and the unit price they paid 
(total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity 
exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, 
account name, and unit price. Sort for the smallest unit price first.	*/

SELECT re."name"  region_name, acc."name" account_name,
	(ord.total_amt_usd / (ord.total+0.01)) unit_price
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON sr.id = acc.sales_rep_id
	JOIN region re
	ON re.id = sr.region_id
	WHERE ord.standard_qty >=100
	AND ord.poster_qty >50
	ORDER BY unit_price;
	


	
	
	
	