COPY forest_area
FROM '/tmp/forest_area.csv'
DELIMITER ','
CSV HEADER;

COPY land_area
FROM '/tmp/land_area.csv'
DELIMITER ','
CSV HEADER;

COPY regions
FROM '/tmp/regions.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM forest_area;
SELECT count(*) FROM land_area;
SELECT * FROM regions;

/* Joing all three tables and creating a view 

Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in 
the workspace.
The forest_area and land_area tables join on both country_code AND year.
The regions table joins these based on only country_code.
In the ‘forestation’ View, include the following:

All of the columns of the origin tables
A new column that provides the percent of the land area that is designated as forest.
Keep in mind that the column forest_area_sqkm in the forest_area table and the land_area_sqmi in the land_area 
table are in different units (square kilometers and square miles, respectively), so an adjustment will need to be
made in the calculation you write (1 sq mi = 2.59 sq km). */

CREATE VIEW forestation AS (
	SELECT  DISTINCT 
		COALESCE(fa.country_code,la.country_code) as country_code,
		COALESCE(fa.year, la.year) as year,
		COALESCE(fa.country_name,la.country_name) as country_name,
		fa.forest_area_sqkm as forest_area_sqkm,
		(la.total_area_sq_mi) * 2.59 as total_area_sqkm,
		(fa.forest_area_sqkm / ((la.total_area_sq_mi) * 2.59))*100 as perc_land_forest,
		reg.region ,
		reg.income_group
		FROM forest_area fa
		JOIN land_area la
		ON fa.country_code = la.country_code
		AND fa."year" = la."year"
		JOIN regions reg
		ON reg.country_code = fa.country_code
		);
	
DROP VIEW 	forestation;
SELECT * FROM forestation where region = 'Latin America & Caribbean';

-- 1. GLOBAL SITUATION
/* a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use 
the country record denoted as “World" in the region table. */
SELECT forest_area_sqkm, country_name
	FROM forestation
	WHERE  year = 1990
	AND country_name = 'World';
	
/* b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the 
country record in the table is denoted as “World.” */
SELECT forest_area_sqkm , country_name
	FROM forestation
	WHERE  year = 2016
	AND country_name = 'World';


/* c. What was the change (in sq km) in the forest area of the world from 1990 to 2016? */

WITH YR1990 AS (SELECT forest_area_sqkm, country_name
	FROM forestation
	WHERE  year = 1990
	AND country_name = 'World'),
	
YR2016 AS (SELECT forest_area_sqkm , country_name
	FROM forestation
	WHERE  year = 2016
	AND country_name = 'World')
	
SELECT (YR2016.forest_area_sqkm - YR1990.forest_area_sqkm) change_forest_area
	FROM YR2016
	JOIN YR1990
	ON YR2016.country_name = YR1990.country_name;

/* d. What was the percent change in forest area of the world between 1990 and 2016?z */

WITH YR1990 AS (SELECT forest_area_sqkm, country_name
	FROM forestation
	WHERE  year = 1990
	AND country_name = 'World'),
	
YR2016 AS (SELECT forest_area_sqkm , country_name
	FROM forestation
	WHERE  year = 2016
	AND country_name = 'World')
	
SELECT ROUND(((YR2016.forest_area_sqkm - YR1990.forest_area_sqkm)/YR1990.forest_area_sqkm)::numeric,2)*100 AS Change
	FROM YR2016
	JOIN YR1990
	ON YR2016.country_name = YR1990.country_name;


/*e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 
is it closest to?*/

SELECT *
	FROM forestation
	WHERE total_area_sqkm <= 
			(WITH YR1990 AS (SELECT forest_area_sqkm, country_name
			FROM forestation
			WHERE  year = 1990
			AND country_name = 'World'),

		YR2016 AS (SELECT forest_area_sqkm , country_name
			FROM forestation
			WHERE  year = 2016
			AND country_name = 'World')

		SELECT (YR1990.forest_area_sqkm -YR2016.forest_area_sqkm ) change_forest_area
			FROM YR2016
			JOIN YR1990
			ON YR2016.country_name = YR1990.country_name)
	AND year = 2016
	ORDER BY total_area_sqkm DESC
	LIMIT 1;
	
-- 2. REGIONAL OUTLOOK
/* Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of 
land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
Based on the table you created */
--DROP VIEW REGIONAL_OUTLOOK;

CREATE VIEW REGIONAL_OUTLOOK AS(
	SELECT region,year,
	ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100)::numeric,2) AS perc_forest
	FROM (
		WITH region_distinct AS(
				SELECT DISTINCT region, country_code FROM regions ),

				fa AS(SELECT DISTINCT country_code,forest_area_sqkm ,year
				FROM  forest_area),

				la AS(SELECT DISTINCT country_code,(total_area_sq_mi*2.59) total_area_sqkm ,year
				FROM  land_area)

				SELECT DISTINCT r.region,r.country_code,forest_area_sqkm,total_area_sqkm, fa.year
				FROM region_distinct r
				JOIN fa
				ON r.country_code = fa.country_code
				JOIN la
				ON r.country_code = la.country_code
				)a
WHERE year in (1990,2016)
GROUP BY 1,2
ORDER BY 3,1,2
);



/* a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 
2016, and which had the LOWEST, to 2 decimal places? */

SELECT * 
	FROM REGIONAL_OUTLOOK
	WHERE region = 'World'
	AND year = 2016;
	

	
SELECT *
	FROM REGIONAL_OUTLOOK
	WHERE 
	year = 2016
	ORDER BY perc_forest DESCELECT *
	FROM REGIONAL_OUTLOOK
	WHERE 
	year = 2016
	ORDER BY perc_forest ASC
	LIMIT 1;
	LIMIT 1;
	


/* b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 
1990, and which had the LOWEST, to 2 decimal places? */


SELECT * 
	FROM REGIONAL_OUTLOOK
	WHERE region = 'World'
	AND year = 1990;
	

	
SELECT *
	FROM REGIONAL_OUTLOOK
	WHERE 
	year = 1990
	ORDER BY perc_forest DESC
	LIMIT 1;
	
SELECT *
	FROM REGIONAL_OUTLOOK
	WHERE 
	year = 1990
	ORDER BY perc_forest ASC
	LIMIT 1;

-- Table 2.1: Percent Forest Area by Region, 1990 & 2016:
SELECT A.region,A.perc_forest AS Forest_Percentage_1990,
	B.perc_forest AS Forest_Percentage_2016 
FROM	
	(SELECT * 
		FROM REGIONAL_OUTLOOK
		WHERE year = 1990) A
LEFT JOIN
	(SELECT * 
		FROM REGIONAL_OUTLOOK
		WHERE year = 2016)B
ON A.region = B.region;

/*c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?*/
WITH t90 AS(SELECT * 
	FROM REGIONAL_OUTLOOK
	WHERE year = 1990),
	
	t16 AS(SELECT * 
	FROM REGIONAL_OUTLOOK
	WHERE year = 2016)
	
	SELECT t90.region,
	t90.perc_forest perc_forest_1990,
	t16.perc_forest perc_forest_2016,
	(t90.perc_forest - t16.perc_forest) perc_forest_diff
	FROM t90
	JOIN t16
	ON t90.region = t16.region
	WHERE (t90.perc_forest - t16.perc_forest) >0 ;


-- 3. COUNTRY-LEVEL DETAIL

/* a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the 
difference in forest area for each? */
WITH area_1990 AS (
	SELECT country_name, forest_area_sqkm 
		FROM forestation
		WHERE 
		year = 1990),


 area_2016 AS (
	SELECT country_name, forest_area_sqkm
		FROM forestation
		WHERE 
		year = 2016
		)
		
SELECT t1.country_name,t1.forest_area_sqkm as area90,t2.forest_area_sqkm as area16, 
	(t2.forest_area_sqkm-t1.forest_area_sqkm) as area_diff
	FROM area_1990 t1
	JOIN area_2016 t2
	ON t1.country_name = t2.country_name
	WHERE t1.forest_area_sqkm IS NOT NULL AND t2.forest_area_sqkm IS NOT NULL
	AND t1.country_name <> 'World'
	ORDER BY t2.forest_area_sqkm-t1.forest_area_sqkm ASC
	LIMIT 5;


/*b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent 
change to 2 decimal places for each? */

WITH area_1990 AS (
	SELECT country_name,region, forest_area_sqkm 
		FROM forestation
		WHERE 
		year = 1990),


 area_2016 AS (
	SELECT country_name,region, forest_area_sqkm
		FROM forestation
		WHERE 
		year = 2016)
		
SELECT t1.country_name,t1.region,t1.forest_area_sqkm as area90 ,t2.forest_area_sqkm as area16, 
	ROUND((((t2.forest_area_sqkm-t1.forest_area_sqkm)/t1.forest_area_sqkm )*100)::Numeric,2) as perc_area_diff
	FROM area_1990 t1
	JOIN area_2016 t2
	ON t1.country_name = t2.country_name
	WHERE t1.forest_area_sqkm IS NOT NULL AND t2.forest_area_sqkm IS NOT NULL
	AND t1.country_name <> 'World'
	ORDER BY ROUND(((t2.forest_area_sqkm-t1.forest_area_sqkm)/t1.forest_area_sqkm )::Numeric,2) ASC
	LIMIT 5;

/*c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 
2016? */

SELECT quartiles, count(*)
FROM 
	(SELECT country_name,ROUND(perc_land_forest::numeric,2) AS perc_land_forest,
		CASE WHEN ROUND(perc_land_forest::numeric,2) >= 75 THEN '4'
			 WHEN ROUND(perc_land_forest::numeric,2) >= 50 THEN '3'
			 WHEN ROUND(perc_land_forest::numeric,2) >= 25 THEN '2'
			 ELSE '1' END quartiles
		FROM forestation
		WHERE year = 2016
		AND perc_land_forest IS NOT NULL
		)a
GROUP BY quartiles
ORDER BY quartiles;
	
/*
SELECT quartile, count(*)
FROM 
	(SELECT country_name, ROUND(perc_land_forest::numeric,2) AS perc_land_forest,
		NTILE(4) OVER (ORDER BY perc_land_forest) AS quartile
			FROM forestation
			WHERE 
			year = 2016
			AND perc_land_forest IS NOT NULL) t1
GROUP BY 1; */



/* d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.*/

SELECT quartiles, country_name,region, perc_land_forest
FROM 
	(SELECT country_name,region,ROUND(perc_land_forest::numeric,2) AS perc_land_forest,
		CASE WHEN ROUND(perc_land_forest::numeric,2) >= 75 THEN '4'
			 WHEN ROUND(perc_land_forest::numeric,2) >= 50 THEN '3'
			 WHEN ROUND(perc_land_forest::numeric,2) >= 25 THEN '2'
			 ELSE '1' END quartiles
		FROM forestation
		WHERE year = 2016
		AND perc_land_forest IS NOT NULL) t1
WHERE quartiles = '4'
ORDER BY perc_land_forest DESC;

/* e. How many countries had a percent forestation higher than the United States in 2016?*/

SELECT count(*)
FROM forestation
WHERE year = 2016 AND
perc_land_forest >
		(SELECT perc_land_forest
		FROM forestation
		WHERE country_name = 'United States' AND year = 2016);


SELECT Distinct country_name,total_area_sqkm 
	FROM forestation
	ORDER BY total_area_sqkm DESC;
	

SELECT * FROM forestation 
	WHERE country_name = 'United States'
	ORDER BY year;
	
SELECT a.country_name,
		a.region,
		area1990,
		area2016,
		area1990 - area2016 AS ForestReduction
FROM (SELECT country_name,
	  	region,
 		forest_area_sqkm AS area1990
FROM forestation
WHERE year = 1990
	 	AND forest_area_sqkm IS NOT NULL
	 AND country_name != 'World') AS a
INNER JOIN 
(SELECT country_name,
 		region,
 		forest_area_sqkm AS area2016
FROM forestation
WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL) AS b
ON a.country_name = b.country_name
ORDER BY ForestReduction DESC
LIMIT 10;


SELECT forest_area_sqkm, total_area_sqkm, perc_land_forest , year
FROM forestation 
WHERE country_name = 'World'  AND year in (1990,2016);

SELECT region, count(*)
FROM (
WITH area_1990 AS (
	SELECT country_name, forest_area_sqkm , region, income_group
		FROM forestation
		WHERE 
		--year = 2016
		year = 1990),


 area_2016 AS (
	SELECT country_name, forest_area_sqkm , region , income_group
		FROM forestation
		WHERE 
		year = 2016
		--year = 1990
		)
		
SELECT t1.country_name,t1.region,t1.forest_area_sqkm as area90,t2.forest_area_sqkm as area16, 
	(t2.forest_area_sqkm-t1.forest_area_sqkm) as area_diff, t1.income_group
	FROM area_1990 t1
	JOIN area_2016 t2
	ON t1.country_name = t2.country_name
	WHERE t1.forest_area_sqkm IS NOT NULL AND t2.forest_area_sqkm IS NOT NULL
	ORDER BY t2.forest_area_sqkm-t1.forest_area_sqkm ASC
	LIMIT 50
	--WHERE (t1.sum_area_1990-t2.sum_area_2016) > 0 
) a
GROUP BY 1
	;
