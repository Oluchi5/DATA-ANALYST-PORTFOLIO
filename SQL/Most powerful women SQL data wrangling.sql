#For this SQL project i will be answering 10 question from this data set
#Let start by introducing the table 
SELECT * 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

# 1. What is the average age of the women in the dataset?
SELECT AVG(AGE) 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

#  2.	How many women in the dataset are from each country?
SELECT COUNT(NAME) AS NUM_OF_WOMEN , LOCATION
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION 
ORDER BY COUNT(NAME) DESC;

#3.	What are the top 5 most common occupations among the women in the dataset?
SELECT CATEGORY, COUNT(CATEGORY) AS NUM_OFWOMEN
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY 1
ORDER BY NUM_OFWOMEN DESC;

#4.	How many women in the dataset are over the age of 40?
SELECT `the worlds 100 most powerful women`.NAME, AGE AS OVER40WOMEN 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
WHERE AGE > 40
ORDER BY OVER40WOMEN DESC;
#--------
SELECT COUNT(AGE) AS OVER40WOMEN 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
WHERE AGE > 40
ORDER BY OVER40WOMEN DESC;

#5.	What is the youngest and oldest age of the women in the dataset?
#YOUNGEST
SELECT `the worlds 100 most powerful women`.RANK, `the worlds 100 most powerful women`.NAME, AGE AS YOUNGEST_WOMAN, LOCATION, CATEGORY
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY YOUNGEST_WOMAN
LIMIT 1;

#6.	How many women in the dataset are from North America?
SELECT  LOCATION, COUNT(LOCATION) AS NORTH_AMERICA
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION
HAVING LOCATION = 'United states'
;

#7.	What is the median age of the women in the dataset?
SET @rowindex := -1;

SELECT AVG (AGE) AS MEDIAN_AGE
FROM 
(SELECT @ROWINDEX:=@ROWINDEX + 1 AS ROWINDEXD, AGE as AGES
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY AGE)
WHERE
`the worlds 100 most powerful women`.ROWINDEX IN (FLOOR(@ROWINDEX/2), CEIL(@ROWINDEX /2));

#8.	How many women in the dataset are in the Technology category?

SELECT CATEGORY, COUNT(CATEGORY) AS WOMEN_IN_TECH
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY CATEGORY
HAVING CATEGORY = 'Technology';

#9.	How many women in the dataset are from Asia?

SELECT LOCATION , COUNT(LOCATION) AS ASIAN_GIRLPOWER
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION
HAVING LOCATION = 'China' OR LOCATION = 'India' OR  LOCATION = 'Singapore' OR LOCATION = 'Indonesia' OR LOCATION = 'Bangladesh' OR LOCATION ='Japan' OR LOCATION = 'South Korea'
ORDER BY ASIAN_GIRLPOWER DESC;

# 10.	What is the standard deviation of the ages of the women in the dataset?
SELECT STDDEV(AGE) AS STDDEV_AGE
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

#BOUNS ROUND 
# LOCATION ASSIGNMENT  
SELECT *,
CASE 
    WHEN LOCATION = 'United States' OR LOCATION = 'Honduras'  OR LOCATION = 'Barbados' THEN 'NORTH AMERICA'
    WHEN LOCATION = 'Germany' OR LOCATION = 'Belgium' OR LOCATION = 'Italy'  OR LOCATION = 'United Kingdom' OR LOCATION = 'Spain' OR LOCATION ='France' OR LOCATION = 'Denmark'  OR LOCATION = 'Turkey'  OR LOCATION = 'Finland' OR LOCATION = 'Solvakia' THEN 'EUROPE'
    WHEN LOCATION = 'China' OR LOCATION = 'India' OR  LOCATION = 'Taiwan' OR LOCATION = 'Singapore' OR LOCATION = 'Indonesia' OR LOCATION = 'Bangladesh' OR LOCATION ='Japan' OR LOCATION = 'South Korea' THEN 'ASIA'
    WHEN LOCATION = 'Australia' OR LOCATION = 'New Zealand' THEN 'OCEANIA'
    WHEN LOCATION = 'Nigeria' OR LOCATION = 'Tanzania' THEN 'AFRICA'
    ELSE 'WHAT ARE YOU!' END AS CONTINENT
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

ALTER TABLE `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ADD CONTINENT VARCHAR (20) NOT NULL;

ALTER TABLE `data_analytics_ with_sql`.`the worlds 100 most powerful women`
drop CONTINENT ;

UPDATE `data_analytics_ with_sql`.`the worlds 100 most powerful women`
SET CONTINENT = 'NORTH AMERICA'
WHERE LOCATION = 'United States' OR location = 'Honduras' OR location = 'Barbados';

UPDATE `data_analytics_with_sql`.`the worlds 100 most powerful women`
SET CONTINENT = 'EUROPE'
WHERE LOCATION = 'Germany' OR LOCATION = 'Belgium' OR LOCATION = 'Italy'  OR LOCATION = 'United Kingdom' OR LOCATION = 'Spain' OR LOCATION ='France' OR LOCATION = 'Denmark'  OR LOCATION = 'Turkey'  OR LOCATION = 'Finland' OR LOCATION = 'Solvakia';

UPDATE `data_analytics_with_sql`.`the worlds 100 most powerful women`
SET CONTINENT = 'ASIA'
WHERE LOCATION = 'China' OR LOCATION = 'India' OR  LOCATION = 'Taiwan' OR LOCATION = 'Singapore' OR LOCATION = 'Indonesia' OR LOCATION = 'Bangladesh' OR LOCATION ='Japan' OR LOCATION = 'South Korea';


UPDATE `data_analytics_with_sql`.`the worlds 100 most powerful women`
SET CONTINENT = 'OCEANIA'
WHERE LOCATION = 'Australia' OR LOCATION = 'New Zealand';

UPDATE `data_analytics_with_sql`.`the worlds 100 most powerful women`
SET CONTINENT = 'AFRICA'
WHERE LOCATION = 'Nigeria' OR LOCATION = 'Tanzania';

