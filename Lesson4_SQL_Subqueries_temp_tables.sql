-- On which day-channel pair did the most events occur.
-- AFter this find out the avearge number of events for each channel

SELECT channel,
	AVG(event_counts) as avg_event_per_day
	FROM 
(SELECT DATE_TRUNC('day',occurred_at),
	channel,
	COUNT(*) as event_counts
	FROM web_events
	GROUP BY 1,2
	--ORDER BY 3 DESC
) sub
	GROUP BY 1
	ORDER BY 2 DESC
	
	
	;
	
-- What was the month/year combo for the first order placed?

SELECT AVG(standard_qty) as std_qty_avg,
	AVG(gloss_qty) as gloss_qty_avg,
	AVG(poster_qty) as poster_qty_avg,
	SUM(total_amt_usd) as total_amt
FROM orders 
WHERE DATE_TRUNC('month', occurred_at) = 
	(SELECT DATE_TRUNC('month',min(occurred_at)) as min_month
	FROM orders);
	
	
	
-- WHat is the top channel used by each account to market products? And how often was the channel used?

SELECT t1.name,t1.channel ,t2.channel_count_max
FROM
	(SELECT acc.name , we.channel,
			count(*) as channel_count
		FROM accounts acc
		JOIN web_events we
		ON acc.id = we.account_id
		GROUP BY 1,2
		ORDER BY 1) t1

JOIN 
	(SELECT name,
		max(channel_count) as channel_count_max
	FROM 
		(SELECT acc.name , we.channel,
			count(*) as channel_count
		FROM accounts acc
		JOIN web_events we
		ON acc.id = we.account_id
		GROUP BY 1,2
		ORDER BY 1) t1
	GROUP BY 1) t2
ON t1.name  = t2.name
AND t1.channel_count = t2.channel_count_max;

/* 1.Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/

SELECT t3.reg_name,t2.sr_name,t3.max_amt
FROM
	(SELECT acc.sales_rep_id,sr.region_id,sr.name as sr_name,sum(ord.total_amt_usd) as total_amt_sum
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON sr.id = acc.sales_rep_id
	GROUP BY 1,2,3) t2
JOIN
	(SELECT sr.region_id,reg.name as reg_name, max(t1.total_amt_sum) as max_amt
	FROM 
		(SELECT acc.sales_rep_id, sum(ord.total_amt_usd) as total_amt_sum
		FROM orders ord
		JOIN accounts acc
		ON ord.account_id = acc.id
		GROUP BY 1) t1
	JOIN sales_reps sr
	ON t1.sales_rep_id = sr.id
	JOIN region reg
	ON sr.region_id = reg.id
	GROUP BY 1,2) t3	
ON t2.region_id = t3.region_id
AND t2.total_amt_sum = t3.max_amt;


--- USING WITH
WITH t1 as (
	SELECT reg."name" as reg_name , sr.name as rep_name,
		SUM(ord.total_amt_usd) as total_amt
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	JOIN sales_reps sr
	ON sr.id = acc.sales_rep_id
	JOIN region reg
	ON sr.region_id = reg.id
	GROUP BY 1,2
	ORDER BY 3 DESC),
	
	t2 as (
		SELECT reg_name, MAX(total_amt) as max_Amt
		FROM t1
		GROUP BY 1)
		
SELECT t2.reg_name, t1.rep_name, t2.max_Amt
FROM t1
JOIN t2
ON t1.reg_name = t2.reg_name
AND t1.total_amt = t2.max_Amt;


/*For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?*/ 

SELECT reg.name as region_name,
	SUM(ord.total_amt_usd) as total_regionwise,
	COUNT(ord.id) as total_orders
FROM orders ord
JOIN accounts acc
ON ord.account_id = acc.id
JOIN sales_reps sr
ON sr.id = acc.sales_rep_id
JOIN region reg
ON reg.id = sr.region_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;




/*How many accounts had more total purchases than the account name which has bought the most standard_qty 
paper throughout their lifetime as a customer? */

SELECT count(*)
FROM
	(SELECT acc."name" as accounts,
		SUM(ord.total) as total1
	FROM accounts acc
	JOIN orders ord
	ON acc.id = ord.account_id
	GROUP BY 1
	ORDER BY 2 DESC)t1
WHERE t1.total1 > 
	(SELECT t2.total2
	FROM
		(SELECT acc."name" as accounts,
			SUM(ord.standard_qty) as total_std_qty,
			SUM(ord.total) as total2
		FROM accounts acc
		JOIN orders ord
		ON acc.id = ord.account_id
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 1) t2);

/*For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
how many web_events did they have for each channel?*/

SELECT t2.customer ,t2.channel, t2.count_events
FROM
	(SELECT acc.name as customer,
		we.channel,
		COUNT(we.id) as count_events
	FROM web_events we
	JOIN accounts acc
	ON we.account_id = acc.id
	GROUP BY 1,2
	ORDER BY 1 ) t2

WHERE t2.customer =

	(SELECT t1.customer
	FROM
		(SELECT acc.name as customer,
			SUM(ord.total_amt_usd) as total
		FROM orders ord
		JOIN accounts acc
		ON ord.account_id = acc.id
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 1) t1);

/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?*/

SELECT AVG(t2.total_amt)
FROM 
	(SELECT acc.name as accounts,
		SUM(ord.total_amt_usd) as total_amt
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	WHERE acc.name in 
			(SELECT t1.accounts
			FROM
				(SELECT acc.name as accounts,
					sum(ord.total) as total_spending
				FROM orders ord
				JOIN accounts acc
				ON ord.account_id = acc.id
				GROUP BY 1
				ORDER BY 2 DESC
				LIMIT 10) t1)
	GROUP BY 1) t2;

/*What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that 
spent more per order, on average, than the average of all orders.*/

SELECT AVG(t1.avg_company)
FROM 
	(SELECT acc.name as company,
		AVG(ord.total_amt_usd) as avg_company
	FROM orders ord
	JOIN accounts acc
	ON ord.account_id = acc.id
	GROUP BY 1) t1
WHERE 
t1.avg_company > 
		(SELECT AVG(total_amt_usd) as avg_all
		FROM orders);


	