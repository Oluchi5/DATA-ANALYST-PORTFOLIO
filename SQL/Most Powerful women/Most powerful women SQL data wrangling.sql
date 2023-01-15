#For this SQL project i will be answering 10 question from this data set
#Let start by introducing the table 

SELECT * 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

# 1. What is the average age of the women in the dataset?

SELECT AVG(AGE) 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

#  2.	How many women in the dataset are from each country?

SELECT COUNT(NAME) AS NUM_OF_WOMEN, 
LOCATION
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION 
ORDER BY COUNT(NAME) DESC;

#3.	What are the top 5 most common occupations among the women in the dataset?

SELECT CATEGORY, 
COUNT(CATEGORY) AS NUM_OFWOMEN
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY 1
ORDER BY NUM_OFWOMEN DESC;

#4.	How many women in the dataset are over the age of 40?

SELECT COUNT(AGE) AS OVER40WOMEN 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
WHERE AGE > 40
ORDER BY OVER40WOMEN DESC;  

#-----OR---

SELECT `the worlds 100 most powerful women`.NAME, 
AGE AS OVER40WOMEN 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
WHERE AGE > 40
ORDER BY OVER40WOMEN DESC;

#5.	What is the youngest and oldest age of the women in the dataset?
#YOUNGEST
SELECT `the worlds 100 most powerful women`.RANK,
`the worlds 100 most powerful women`.NAME, 
AGE AS YOUNGEST_WOMAN, LOCATION, CATEGORY
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY YOUNGEST_WOMAN
LIMIT 1;

#OLDEST

SELECT `the worlds 100 most powerful women`.RANK,
`the worlds 100 most powerful women`.NAME, 
AGE AS OLDERST_WOMAN, LOCATION, CATEGORY
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY OLDERST_WOMAN DESC
LIMIT 1;

#6.	How many women in the dataset are from North America?

SELECT  LOCATION, 
COUNT(LOCATION) AS NORTH_AMERICA
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION
HAVING LOCATION IN ('United states', 'Honduras', 'Barbados') ; 



#7.	How many women in the dataset are in the Technology category?

SELECT CATEGORY, 
COUNT(CATEGORY) AS WOMEN_IN_TECH
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY CATEGORY
HAVING CATEGORY = 'Technology';

#8.	How many women in the dataset are from Asia?

SELECT LOCATION, 
COUNT(LOCATION) AS ASIAN_GIRLPOWER
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY LOCATION
HAVING LOCATION IN ('China', 'India', 'Singapore',  'Indonesia' , 'Bangladesh', 'Japan', 'South Korea', 'Tiwan')
ORDER BY ASIAN_GIRLPOWER DESC;

#---or----

SELECT LOCATION , 
COUNT(
CASE
WHEN LOCATION IN ('China', 'India', 'Singapore',  'Indonesia' , 'Bangladesh', 'Japan', 'South Korea', 'Tiwan') Then 1 END) AS GIRLS
FROM`data_analytics_ with_sql`.`the worlds 100 most powerful women`
GROUP BY 1 
ORDER BY GIRLS DESC;

# 9.	What is the standard deviation of the ages of the women in the dataset?

SELECT STDDEV(AGE) AS STDDEV_AGE
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`;

 
#10.  ASSIGNMENT LOCATION TO TEMPORARY COULMNS TO SHOWCASE COLUMNS
SELECT *,
CASE 
    WHEN LOCATION IN ('United States', 'Honduras', 'Barbados') THEN 'NORTH AMERICA'
    WHEN LOCATION IN ('Germany', 'Belgium', 'Italy', 'United Kingdom', 'Spain', 'France', 'Denmark',  'Turkey', 'Finland', 'Solvakia') THEN 'EUROPE'
    WHEN LOCATION IN ('China', 'India', 'Taiwan', 'Singapore', 'Indonesia', 'Bangladesh', 'Japan', 'South Korea') THEN 'ASIA'
    WHEN LOCATION IN('Australia','New Zealand') THEN 'OCEANIA'
    WHEN LOCATION IN ('Nigeria', 'Tanzania') THEN 'AFRICA'
    ELSE 'WHAT ARE YOU!' END AS CONTINENT
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY CONTINENT;


#11. What is the median age of the women in the dataset?

SELECT AVG (AGE) AS MEDIAN_AGE
FROM 
(SELECT AGE 
FROM `data_analytics_ with_sql`.`the worlds 100 most powerful women`
ORDER BY AGE);

