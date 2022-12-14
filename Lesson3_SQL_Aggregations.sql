/* Find the total amount of poster_qty paper ordered in the orders table.

Find the total amount of standard_qty paper ordered in the orders table.

Find the total dollar amount of sales using the total_amt_usd in the orders table.

Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order 
in the orders table. This should give a dollar amount for each order in the table.

Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an 
aggregation and a mathematical operator. */

SELECT sum(poster_qty) as poster_qty_total,
	sum(standard_qty) as standard_qty_total,
	sum(total_amt_usd) as total_sales,
	sum(standard_amt_usd) + sum(gloss_amt_usd) as standard_gloss_sales,

	(sum(standard_amt_usd) / sum(standard_qty)) as std_per_unit
	
	FROM orders;
	
/* When was the earliest order ever placed? You only need to return the date.*/

SELECT min(occurred_at)
	FROM orders;

/*Try performing the same query as in question 1 without using an aggregation function. */
SELECT occurred_at
	FROM orders
	ORDER BY occurred_at
	LIMIT 1;

/*When did the most recent (latest) web_event occur?*/
SELECT max(occurred_at)
	FROM web_events;

/*Try to perform the result of the previous query without using an aggregation function.*/
SELECT (occurred_at)
	FROM web_events
	ORDER BY occurred_at
	LIMIT 1;

/* Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean 
amount of each paper type purchased per order. Your final answer should have 6 values - 
one for each paper type for the average number of sales, as well as the average amount.*/

SELECT AVG(standard_qty) as std_qty_avg,AVG(gloss_qty) as gloss_qty_avg,
	AVG(poster_qty) as poster_qty_avg,
	AVG(standard_amt_usd),AVG(gloss_amt_usd),AVG(poster_amt_usd)
	FROM orders;


/*Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced 
than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders? */

SELECT 	A.total_amt_usd
	FROM
	(SELECT total_amt_usd
		FROM orders
	 	ORDER BY total_amt_usd
		LIMIT 3457) A
		ORDER BY A.total_amt_usd DESC
		LIMIT 2;
		
/* Which account (by name) placed the earliest order? 
Your solution should have the account name and the date of the order.*/

SELECT ord.id,acc.name, ord.occurred_at
	FROM orders ord
	LEFT JOIN accounts acc
	ON ord.account_id = acc.id
	ORDER BY ord.occurred_at 
	LIMIT 1;

/*Find the total sales in usd for each account. You should include two columns - 
the total sales for each company's orders in usd and the company name.*/

SELECT acc.name, sum(ord.total_amt_usd) as total_sales
 	FROM orders ord
	LEFT JOIN accounts acc
	ON ord.account_id = acc.id
	GROUP BY acc.name;

/*Via what channel did the most recent (latest) web_event occur, 
which account was associated with this web_event? Your query should return only three values - 
the date, channel, and account name.*/

SELECT acc.name as account_name, we.occurred_at as date, we.channel as channel
	FROM web_events we
	JOIN accounts acc
	ON we.account_id = acc.id
	ORDER BY we.occurred_at DESC
	LIMIT 1;
	


/*Find the total number of times each type of channel from the web_events was used. 
Your final table should have two columns - the channel and the number of times the channel was used.*/

SELECT channel, count(channel)
	FROM web_events
	GROUP BY channel;

/*Who was the primary contact associated with the earliest web_event? */
SELECT acc.name account_name, we.occurred_at  date, we.channel  channel, acc.primary_poc
	FROM web_events we
	JOIN accounts acc
	ON we.account_id = acc.id
	ORDER BY we.occurred_at 
	LIMIT 1;


/*What was the smallest order placed by each account in terms of total usd. 
Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.*/

SELECT acc.name, min(ord.total_amt_usd) smallest_order
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	GROUP BY acc.name
	ORDER BY smallest_order;

/*Find the number of sales reps in each region. Your final table should have two columns - 
the region and the number of sales_reps. Order from fewest reps to most reps.*/

SELECT reg.name , count(sr.id) as count_reps
	FROM sales_reps sr
	JOIN region reg
	ON sr.region_id = reg.id
	GROUP BY reg.name
	ORDER BY count_reps;
	
/*For each account, determine the average amount of each type of paper they purchased across 
their orders. Your result should have four columns - one for the account name and one for the 
average quantity purchased for each of the paper types for each account. */

/*For each account, determine the average amount spent per order on each paper type. 
Your result should have four columns - one for the account name and one for the average 
amount spent on each paper type.*/

/*Determine the number of times a particular channel was used in the web_events table for each sales rep. 
Your final table should have three columns - the name of the sales rep, the channel, and the number of 
occurrences. Order your table with the highest number of occurrences first.*/

/*Determine the number of times a particular channel was used in the web_events table for each region. 
Your final table should have three columns - the region name, the channel, and the number of occurrences. 
Order your table with the highest number of occurrences first.*/



/* Use DISTINCT to test if there are any accounts associated with more than one region.*/

SELECT DISTINCT acc.id as account
	FROM accounts acc
	LEFT JOIN sales_reps sr
	ON acc.sales_rep_id = sr.id
	LEFT JOIN region reg
	ON sr.region_id = reg.id
	GROUP BY acc.id
	HAVING count(acc.id ) > 1
	ORDER BY account;

/* Have any sales reps worked on more than one account?*/

SELECT sr.name , count(acc.id)
	FROM sales_reps sr
	LEFT JOIN accounts acc
	ON sr.id = acc.sales_rep_id
	GROUP BY sr.name
	HAVING count(acc.id)>1;
	
	
-- DATE TIME

SELECT occurred_at, DATE_TRUNC('day',occurred_at) as day,
	DATE_TRUNC('minute',occurred_at) as minutes,
	DATE_PART('day',occurred_at) as day_part, -- date_part will ignore the year and month
	DATE_PART('dow',occurred_at) as day_of_week,
	DATE_PART('year',occurred_at) as year_part
	FROM orders;
	
	
/* Questions: Working With DATEs
Use the SQL environment below to assist with answering the following questions. Whether you get stuck or 
you just want to double check your solutions, my answers can be found at the top of the next concept.*/

/*Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
Do you notice any trends in the yearly sales totals? */

SELECT DATE_PART('year',occurred_at),
	sum(total) as total_sales
	FROM orders
	GROUP BY 1
	ORDER BY 2 DESC;

/* Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly 
represented by the dataset? */

SELECT DATE_PART('month',occurred_at) as months,
	sum(total) as total_sales
	FROM orders
	WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
	GROUP BY 1
	ORDER BY 2 DESC;

/* Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years 
evenly represented by the dataset? */

SELECT DATE_PART('year',occurred_at),
	count(*) as total_orders
	FROM orders
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1 ;

/*Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months 
evenly represented by the dataset? */

SELECT DATE_PART('month',occurred_at) as months,
	sum(total) as total_sales
	FROM orders
	WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1;

/*In which month of which year did Walmart spend the most on gloss paper in terms of dollars? */

SELECT DATE_PART('year',ord.occurred_at) as years,
	DATE_PART('month',ord.occurred_at) as months,
	sum(ord.gloss_amt_usd) as gloss_spent
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	WHERE acc.name = 'Walmart'
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1;
	
/*Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for 
standard paper for each order. Limit the results to the first 10 orders, and include the id and account_id 
fields. NOTE - you will be thrown an error with the correct solution to this question. This is for a division 
by zero. You will learn how to get a solution without an error to this query when you learn about CASE 
statements in a later section. */

SELECT ord.id,acc.name,
	(standard_amt_usd/standard_qty) as unit_price_per_order
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id;
	--LIMIT 10;
	
SELECT ord.id,acc.name,
	CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
	ELSE (standard_amt_usd/standard_qty) END AS   unit_price_per_order
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id;
	
	
/* Questions: CASE
Use the SQL environment below to assist with answering the following questions. Whether you get 
stuck or you just want to double check your solutions, my answers can be found at the top of the next concept.*/

/*Write a query to display for each order, the account ID, total amount of the order, and the level of the 
order - ???Large??? or ???Small??? - depending on if the order is $3000 or more, or smaller than $3000.*/

SELECT id, account_id,
		total,
		CASE WHEN total >= 3000 THEN 'Large'
		ELSE 'Small' END AS level_order
		FROM orders
		ORDER BY 3 DESC;

/*Write a query to display the number of orders in each of three categories, based on the total number of items
in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.*/

SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
			WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
			WHEN total < 1000 THEN 'Less than 1000' END AS order_categories,
			count(*)
			FROM orders
			GROUP BY 1
			ORDER BY 1;
		

/* We would like to understand 3 different levels of customers based on the amount associated with their 
purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 
200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. You should provide the account name, 
the total sales of all orders for the customer, and the level. Order with the top spending customers listed 
first. */

SELECT acc.name,SUM(ord.total_amt_usd) AS total_sales,
	CASE WHEN SUM(ord.total_amt_usd) > 200000 THEN 'top_level'
		WHEN SUM(ord.total_amt_usd) > 100000 AND SUM(ord.total_amt_usd) <= 200000  THEN 'second_level'
		ELSE 'lowest_level' END AS levels
		FROM orders ord
		JOIN accounts acc
		ON ord.account_id = acc.id
		GROUP BY 1
		ORDER BY 2 DESC;

/*We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent 
by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top 
spending customers listed first. */

SELECT acc.name,SUM(ord.total_amt_usd) AS total_sales,
	CASE WHEN SUM(ord.total_amt_usd) > 200000 THEN 'top_level'
		WHEN SUM(ord.total_amt_usd) > 100000 AND SUM(ord.total_amt_usd) <= 200000  THEN 'second_level'
		ELSE 'lowest_level' END AS levels
		FROM orders ord
		JOIN accounts acc
		ON ord.account_id = acc.id
		WHERE ord.occurred_at BETWEEN '2016-01-01' AND '2018-01-01'
		GROUP BY 1
		ORDER BY 2 DESC;

/* We would like to identify top performing sales reps, which are sales reps associated with more than 200 
orders. Create a table with the sales rep name, the total number of orders, and a column with top or not 
depending on if they have more than 200 orders. Place the top sales people first in your final table. */

SELECT sr."name" AS sales_rep_name,
	count(ord.id) AS num_of_orders,
	CASE WHEN count(ord.id) > 200 THEN 'TOP'
	ELSE 'NO' END AS More_than_200_or_not
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON acc.sales_rep_id = sr.id
	GROUP BY 1
	ORDER BY 2 DESC;
	
	
/*The previous didn't account for the middle, nor the dollar amount associated with the sales. 
Management decides they want to see these characteristics represented as well. We would like to identify top 
performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total 
sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales 
rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low 
depending on this criteria. Place the top sales people based on dollar amount of sales first in your final
table. You might see a few upset sales people by this criteria! */

SELECT sr."name" AS sales_rep_name,
	count(ord.id) AS num_of_orders,
	SUM(ord.total_amt_usd) AS total_sales,
	CASE WHEN count(ord.id) > 200 OR SUM(ord.total_amt_usd)> 750000 THEN 'TOP'
	WHEN (count(ord.id) > 150 AND count(ord.id) <= 200) OR 
	(SUM(ord.total_amt_usd)> 500000 AND SUM(ord.total_amt_usd)<= 750000) THEN 'MID'
	ELSE 'LOW' END AS top_mid_low
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON acc.sales_rep_id = sr.id
	GROUP BY 1
	ORDER BY 3 DESC;
	