SELECT * FROM gym_profit.gym_profit_data;

-- 1. KPIs 
-- TOTAL PROFIT ('$15,406,369')
SELECT 
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT
FROM GYM_PROFIT_DATA;

-- 2. HIGHEST PROFITABLE BRAND UNDER EACH PRODUCT CATEGORY AIRBIKE(APEX_ATHLETICS '$973,381'), ROWING_MACHINE(FORGE_FITNESS '$981,680') AND TREADMILL(STEEL_POWER '$974,940')
SELECT *
FROM
(SELECT 
      DISTINCT(CATEGORY),
      BRAND,
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT,
      ROW_NUMBER () OVER (PARTITION BY CATEGORY ORDER BY SUM(PROFIT_MONTH) DESC) AS ROW_NUM
FROM GYM_PROFIT_DATA
GROUP BY CATEGORY, BRAND) A
WHERE A.ROW_NUM = 1;

-- 3. TOP MONTH MARCH('$14,12,264')
SELECT 
      DISTINCT(MONTH),
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT
FROM GYM_PROFIT_DATA
GROUP BY MONTH
ORDER BY SUM(PROFIT_MONTH) DESC
LIMIT 1;
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- PRIMARY PRODUCT PROFIT DISTRIBUTION:

WITH CTE_TOTAL_PROFIT AS (
SELECT 
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT
FROM GYM_PROFIT_DATA
),
CTE_ROWING_MACHINE AS (
SELECT 
	  DISTINCT(CATEGORY),
      SUM(PROFIT_MONTH) AS ROWING_MACHINE_PROFIT
FROM GYM_PROFIT_DATA
WHERE CATEGORY = 'ROWING MACHINE'
GROUP BY CATEGORY
),
CTE_TREADMILL AS (
SELECT 
	  DISTINCT(CATEGORY),
      SUM(PROFIT_MONTH) AS TREADMILL_PROFIT
FROM GYM_PROFIT_DATA
WHERE CATEGORY = 'TREADMILL'
GROUP BY CATEGORY
),
CTE_AIRBIKE AS (
SELECT 
	  DISTINCT(CATEGORY),
      SUM(PROFIT_MONTH) AS AIRBIKE_PROFIT
FROM GYM_PROFIT_DATA
WHERE CATEGORY = 'AIRBIKE'
GROUP BY CATEGORY
)
SELECT 
      DISTINCT(A.CATEGORY),
      SUM(PROFIT_MONTH),
      CASE
      WHEN A.CATEGORY = 'AIRBIKE' THEN AIRBIKE_PROFIT / TOTAL_PROFIT * 100 
      WHEN A.CATEGORY = 'TREADMILL' THEN TREADMILL_PROFIT / TOTAL_PROFIT * 100 
      WHEN A.CATEGORY = 'ROWING MACHINE' THEN ROWING_MACHINE_PROFIT / TOTAL_PROFIT * 100
      END AS TOTAL_PERCENTAGE
FROM gym_profit_data A
JOIN CTE_ROWING_MACHINE
JOIN CTE_TREADMILL
JOIN CTE_AIRBIKE
JOIN CTE_TOTAL_PROFIT
GROUP BY A.CATEGORY, AIRBIKE_PROFIT, TREADMILL_PROFIT, ROWING_MACHINE_PROFIT, TOTAL_PROFIT;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- HISTORICAL YEARLY PROFIT:

SELECT  
      DISTINCT(YEAR),
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT,
      CONCAT(ROUND((SUM(PROFIT_MONTH) - LAG(SUM(PROFIT_MONTH)) OVER (order by YEAR)) / LAG(SUM(PROFIT_MONTH)) OVER (order BY YEAR) * 100,2),'%')  AS CHANGES
FROM GYM_PROFIT_DATA
GROUP BY YEAR;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- HISTORICAL MONTHLY PROFIT:

SELECT  
      DISTINCT(MONTH),
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT,
      CONCAT(ROUND((SUM(PROFIT_MONTH) - LAG(SUM(PROFIT_MONTH)) OVER (order by month)) / LAG(SUM(PROFIT_MONTH)) OVER (order BY MONTH) * 100,2),'%')  AS CHANGES
FROM GYM_PROFIT_DATA
GROUP BY MONTH;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------

-- GYM PRIMARY PRODUCTS YEAR TO YEAR PROFITS AND CHANGES.

SELECT 
      DISTINCT(YEAR),
      CATEGORY,
      SUM(PROFIT_MONTH),
      SUM(SUM(PROFIT_MONTH)) OVER (PARTITION BY CATEGORY ORDER BY YEAR) AS CUMULATIVE,
      CONCAT(ROUND((SUM(PROFIT_MONTH) - LAG(SUM(PROFIT_MONTH)) OVER (PARTITION BY CATEGORY ORDER BY YEAR )) / LAG(SUM(PROFIT_MONTH)) OVER (PARTITION BY CATEGORY ORDER BY YEAR) * 100,2),'%') AS PERCENTAGE_CHANGE
FROM gym_profit_data
GROUP BY YEAR, CATEGORY;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- RANK OF SUPPLIER PROFIT DISTRIBUTION BY PRODUCT CATAGEORY 

SELECT 
      DISTINCT (CATEGORY),
      SUPPLIER,
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT,
      DENSE_RANK () OVER (PARTITION BY CATEGORY ORDER BY SUM(PROFIT_MONTH) DESC) AS ORDER_RANK
FROM gym_profit_data
GROUP BY CATEGORY, SUPPLIER;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- BRAND PROFIT RANKING UNDER EACH CATEGORY 
SELECT 
      DISTINCT (CATEGORY),
      SUPPLIER,
      BRAND,
      SUM(PROFIT_MONTH) AS TOTAL_PROFIT,
      DENSE_RANK () OVER (PARTITION BY CATEGORY ORDER BY SUM(PROFIT_MONTH) DESC) AS ORDER_RANK
FROM gym_profit_data
GROUP BY CATEGORY, SUPPLIER, BRAND;
