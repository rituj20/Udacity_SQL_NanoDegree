-- CORE WINDOWS FUNCTIONS

/* Creating a Running Total Using Window Functions
Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: one with the amount being added for each new row, and a second 
with the running total. */

SELECT standard_amt_usd,
	SUM(standard_amt_usd) OVER
	(ORDER BY occurred_at) AS running_total
	FROM orders;
	

/* Creating a Partitioned Running Total Using Window Functions
Now, modify your query from the previous quiz to include partitions. Still create a running total of 
standard_amt_usd (in the orders table) over order time, but this time, date truncate occurred_at by year 
and partition by that same year-truncated occurred_at variable. Your final table should have three columns: 
One with the amount being added for each row, one for the truncated date, and a final column with the running 
total within each year. */

SELECT standard_amt_usd,
	DATE_TRUNC('year',occurred_at) AS year,
	SUM(standard_amt_usd) OVER
	(PARTITION BY DATE_TRUNC('year',occurred_at) ORDER BY occurred_at) AS Running
	FROM orders;
	
	
/*Aggregates in Window Functions with and without ORDER BY */

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
	   DENSE_RANK() OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at) ) AS dense_rank,
	   SUM(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_std_qty,
	   COUNT(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS cnt_std_qty,
	   AVG(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_std_qty,
	   MIN(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS min_std_qty,
	   MAX(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS max_std_qty
	   
FROM orders;	  

-- Now remove ORDER BY DATE_TRUNC('month',occurred_at) and compare the results with above
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
	   DENSE_RANK() OVER(PARTITION BY account_id ) AS dense_rank,
	   SUM(standard_qty) OVER(PARTITION BY account_id ) AS sum_std_qty,
	   COUNT(standard_qty) OVER(PARTITION BY account_id ) AS cnt_std_qty,
	   AVG(standard_qty) OVER(PARTITION BY account_id ) AS avg_std_qty,
	   MIN(standard_qty) OVER(PARTITION BY account_id ) AS min_std_qty,
	   MAX(standard_qty) OVER(PARTITION BY account_id ) AS max_std_qty
	   
FROM orders;

-- RANKING - Row_number(), Rank(), Dense_rank()

/* Row_number(): Ranking is distinct amongst records even with ties in what the table is ranked against.
Rank(): Ranking is the same amongst tied values and ranks skip for subsequent values.
Dense_rank(): Ranking is the same amongst tied values and ranks do not skip for subsequent values. */

/*Select the id, account_id, and total variable from the orders table, 
then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) 
for each account using a partition. Your final table should have these four columns.*/


SELECT id, account_id, total,
	RANK() OVER(PARTITION BY account_id ORDER BY total DESC ) AS total_rank
	FROM orders;
	
	
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders;


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER tempr AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER tempr AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER tempr AS count_total_amt_usd,
       AVG(total_amt_usd) OVER tempr AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER tempr AS min_total_amt_usd,
       MAX(total_amt_usd) OVER tempr AS max_total_amt_usd
FROM orders
WINDOW tempr AS 
(PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));


-- Comparing a Row to Previous Row

/*Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue 
("total" meaning from sales of all types of paper) compares to the next order's total revenue.
You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so. 
In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference. */

SELECT occurred_at,
	total_amt,
	LEAD(total_amt) OVER(ORDER BY occurred_at ASC) AS lead_sum,
	LEAD(total_amt) OVER(ORDER BY occurred_at ASC) - total_amt AS lead_diff
FROM
	(SELECT occurred_at,
	SUM(total_amt_usd) as total_amt
	FROM orders
	GROUP BY 1) sub;

/* Percentiles with Partitions
You can use partitions with percentiles to determine the percentile of a specific subset of all rows. 
Imagine you're an analyst at Parch & Posey and you want to determine the largest orders (in terms of quantity) 
a specific customer has made to encourage them to order more similarly sized large orders. You only want to 
consider the NTILE for that customer's account_id. */

/*Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for 
their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total 
amount of standard_qty paper purchased, and one of four levels in a standard_quartile column. */

SELECT account_id,
	occurred_at,
	standard_qty,
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) as quartile
	FROM orders
	ORDER BY 1;

/* Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for 
their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total 
amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.*/

SELECT account_id,
	occurred_at,
	gloss_qty,
	NTILE(2) OVER(PARTITION BY account_id ORDER BY gloss_qty) as bitile
	FROM orders
	ORDER BY 1;

/* Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of
total_amt_usd for their orders. Your resulting table should have the account_id, the occurred_at time for each 
order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile 
column.*/

SELECT account_id,
	occurred_at,
	total_amt_usd,
	NTILE(100) OVER(PARTITION BY account_id ORDER BY total_amt_usd) as percentile
	FROM orders
	ORDER BY 1;