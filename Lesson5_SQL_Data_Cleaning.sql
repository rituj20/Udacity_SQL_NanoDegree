
"
"/* In the accounts table, there is a column holding the website for each company. The last three digits 
specify what type of web address they are using. A list of extensions (and pricing) is provided here.
Pull these extensions and provide how many of each website type exist in the accounts table.*/

SELECT  RIGHT(website,3) as extension,
	COUNT(*)
	FROM accounts
	GROUP BY 1;
	
	
/* There is much debate about how much the name (or even the first letter of a company name) matters. 
Use the accounts table to pull the first letter of each company name to see the distribution of company names 
that begin with each letter (or number). */

SELECT UPPER(LEFT(name,1)),
	COUNT(*)
	FROM accounts
	GROUP BY 1
	ORDER BY 1 DESC;
	
/* Use the accounts table and a CASE statement to create two groups: one group of company names that start 
with a number and a second group of those company names that start with a letter. What proportion of company 
names start with a letter?*/


SELECT
	CASE WHEN UPPER(LEFT(name,1))= '3' THEN 'number' 
	ELSE 'letter' END AS num_let,
	COUNT(*)
	FROM accounts
	GROUP BY 1
	;

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;
/* Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent 
start with anything else? */

	
SELECT 
	CASE WHEN LOWER(LEFT(name,1)) in ('a','e','i','o','u') THEN 'vowel'
	ELSE 'consonant' END AS vo_co,
	COUNT(*) as counts
	FROM accounts
	GROUP BY 1;


/* Quiz: CONCAT, LEFT, RIGHT, and SUBSTR
Suppose the company wants to assess the performance of all the sales representatives. Each sales representative 
is 
assigned to work in a particular region. To make it easier to understand for the HR team, display the 
concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative.*/ 

SELECT CONCAT(sr.id,'_',reg.name) as EMP_ID_REGION
	FROM sales_reps sr
	JOIN region reg
	ON sr.region_id = reg.id;
	
/* From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), 
email id of the primary point of contact as <first letter of the primary_poc>
<last letter of the primary_poc>@<extracted name and domain from the website> */

SELECT name,
	CONCAT('(',lat,',',long,')') as lat_long,
	CONCAT(LEFT(primary_poc,1),RIGHT(primary_poc,1),'@',SUBSTR(website,5,90))
	FROM accounts;


/* From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of 
web events of the particular channel */

SELECT CONCAT(t1.account_id,'_',t1.channel,'_', t1.EVENTS)
FROM 
	(SELECT account_id,
		channel,
		COUNT(*) AS EVENTS
		FROM web_events
		GROUP BY 1,2) t1
ORDER BY 1;



CREATE TABLE sf_crime_data (
incidnt_num bpchar,
category bpchar,
descript bpchar,
day_of_week bpchar,
date bpchar,
time bpchar,
pd_district bpchar,
resolution bpchar,
address bpchar,
lon bpchar,
lat bpchar,
location bpchar,
id integer
);

COPY sf_crime_data
FROM '/Users/ritujain/Downloads/sf_crime.csv'
DELIMITER ','
CSV HEADER;


--DROP TABLE sf_crime_data;


SELECT DATE_PART ('day',t1.NEW_DT)
FROM
	(SELECT  date,
	LEFT(date,2),
	SUBSTR(date,4,2),
	SUBSTR(date,7,4),
	CONCAT(SUBSTR(date,7,4),'-',LEFT(date,2),'-',SUBSTR(date,4,2)) as NEW_DT

	FROM sf_crime_data)t1;
	
SELECT DATE_PART ('day',t1.new_date)
FROM	
	(SELECT date orig_date, 
	(SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
	FROM sf_crime_data)t1;
	
	
-- ADVANCED CLEANING FUNCTIONS

/* Quizzes POSITION & STRPOS
You will need to use what you have learned about LEFT & RIGHT, as well as what you know about 
POSITION or STRPOS to do the following quizzes. */

/* Use the accounts table to create first and last name columns that hold the first and last names for the 
primary_poc. */

SELECT LEFT(primary_poc,STRPOS(primary_poc,' ')-1) AS FIRST_NAME,
	RIGHT(primary_poc,(LENGTH(primary_poc)-STRPOS(primary_poc,' '))) AS LAST_NAME
	FROM accounts;

/* Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and 
last name columns.*/


/* Quizzes CONCAT */
/* Each company in the accounts table wants to create an email address for each primary_poc. The email address 
should be the first name of the primary_poc . last name primary_poc @ company name .com.*/

SELECT CONCAT(LEFT(primary_poc,STRPOS(primary_poc,' ')-1),'.',
			 RIGHT(primary_poc,(LENGTH(primary_poc)-STRPOS(primary_poc,' '))),'@',name,'.com')
	FROM accounts
	ORDER BY 1;

/*You may have noticed that in the previous solution some of the company names include spaces, which will
certainly not work in an email address. See if you can create an email address that will work by removing all 
of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful 
documentation is here.*/

SELECT CONCAT(LEFT(primary_poc,STRPOS(primary_poc,' ')-1),'.',
			 RIGHT(primary_poc,(LENGTH(primary_poc)-STRPOS(primary_poc,' '))),'@',
			  REPLACE(name, ' ',''),
			  '.com')
	FROM accounts;

/*We would also like to create an initial password, which they will change after their first log in. The first 
password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their 
first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name 
(lowercase), the number of letters in their first name, the number of letters in their last name, and then the 
name of the company they are working with, all capitalized with no spaces.*/

SELECT t1.FIRST_NAME,t1.LAST_NAME,t1.COMPANY,
LEFT(LOWER(t1.FIRST_NAME),1)||RIGHT(LOWER(t1.FIRST_NAME),1)||
LEFT(LOWER(t1.LAST_NAME),1)||RIGHT(LOWER(t1.LAST_NAME),1)||
LENGTH(t1.FIRST_NAME) || LENGTH(t1.LAST_NAME)||
UPPER(REPLACE(t1.COMPANY,' ',''))
FROM 
	(SELECT LEFT(primary_poc,STRPOS(primary_poc,' ')-1) AS FIRST_NAME,
		RIGHT(primary_poc,(LENGTH(primary_poc)-STRPOS(primary_poc,' '))) AS LAST_NAME,
		name as COMPANY
		FROM accounts)t1
ORDER BY 1;


WITH t1 AS (
SELECT LEFT(primary_poc,STRPOS(primary_poc,' ')-1) AS FIRST_NAME,
		RIGHT(primary_poc,(LENGTH(primary_poc)-STRPOS(primary_poc,' '))) AS LAST_NAME,
		name as COMPANY
		FROM accounts)
		
SELECT t1.FIRST_NAME,t1.LAST_NAME,t1.COMPANY,
	LEFT(LOWER(t1.FIRST_NAME),1)||RIGHT(LOWER(t1.FIRST_NAME),1)||
	LEFT(LOWER(t1.LAST_NAME),1)||RIGHT(LOWER(t1.LAST_NAME),1)||
	LENGTH(t1.FIRST_NAME) || LENGTH(t1.LAST_NAME)||
	UPPER(REPLACE(t1.COMPANY,' ','')) AS PASSWORDS
	FROM t1;


-- COALESCE 

SELECT a.*,o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, 
o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, 
COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
