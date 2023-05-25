-- 1. How many customers has Foodie-Fi ever had?
-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- 6. What is the number and percentage of customer plans after their initial free trial?
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- 8. How many customers have upgraded to an annual plan in 2020?
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


-- 1. How many customers has Foodie-Fi ever had?

SELECT 
	COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions s 

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
	MONTH (start_date) AS trial_start,
	YEAR  (start_date) AS trial_start,
	COUNT(DISTINCT customer_id) AS total_customers_monthly
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_name = 'trial'
GROUP BY 1,2;

## both provide the same result

SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS month_start,
       COUNT(*) AS count
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_name = 'trial'
GROUP BY 1
ORDER BY month_start;



-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT 
	plan_name,
	COUNT(customer_id) AS amoun_in_2021
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE start_date >= '2021-01-01'
GROUP BY 1


-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT  
		plan_name,
		COUNT(*) AS churn_count,
        (COUNT(*)/(SELECT count(DISTINCT customer_id) FROM subscriptions))*100 AS percentage_of_churns 
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_name = 'churn'


-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

-- https://www.topcoder.com/thrive/articles/lead-and-lag-functions-in-sql#:~:text=The%20LEAD%20function%20is%20used,PARTITION%20BY%20clause%20is%20optional.
-- lead(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan: This is the main part of the query. 
-- The LEAD function is used to retrieve the value of the plan_id from the next row based on the specified ordering. 
-- The PARTITION BY clause divides the rows into partitions based on the customer_id column, and the ORDER BY clause specifies the ordering based on the start_date column.

SELECT 
	COUNT(*) AS straight_churn,
	ROUND((COUNT(*)/(SELECT count(DISTINCT customer_id)
                FROM subscriptions)) * 100) AS percentage 
FROM (SELECT 
	*,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM subscriptions) sd
WHERE plan_id=0 AND next_plan = 4


-- 6. What is the number and percentage of customer plans after their initial free trial?

SELECT  
		plan_name,
		COUNT(*) AS plans_count,
        (COUNT(*)/(SELECT count(DISTINCT customer_id) FROM subscriptions))*100 AS customer_plans_percentage
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_name != 'trial'
GROUP BY plan_name 



SELECT 
	plan_name,
	COUNT(*) AS user_plan_count,
	ROUND((COUNT(*)/(SELECT count(DISTINCT customer_id)
                FROM subscriptions)) * 100) AS percentage 
FROM (SELECT 
	*,
    LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan
FROM subscriptions) sd
INNER JOIN plans p USING(plan_id)
WHERE previous_plan = 0
GROUP by plan_name






-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


-- SELECT  
-- 		plan_name,
-- 		COUNT(*) AS customer_count,
--         (COUNT(*)/(SELECT count(DISTINCT customer_id) FROM subscriptions))*100 AS customer_plans_percentage
-- FROM subscriptions s 
-- INNER JOIN plans p USING(plan_id)
-- WHERE start_date <= '2020-12-31'
-- GROUP BY plan_name 


CREATE TEMPORARY TABLE latest_plan_cte as (SELECT *,
          row_number() over(PARTITION BY customer_id
                            ORDER BY start_date DESC) AS latest_plan
   FROM subscriptions
   JOIN plans USING (plan_id)
   WHERE start_date <='2020-12-31' )
   
 SELECT plan_id,
       plan_name,
       count(customer_id) AS customer_count,
       round(100*count(customer_id) /
               (SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions), 2) AS percentage_breakdown
FROM latest_plan_cte
WHERE latest_plan = 1
GROUP BY 1,2
ORDER BY plan_id;


-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT 
	COUNT(latest) AS customer_upgrade_in_2020_counter
FROM (SELECT 
	plan_id,
	customer_id,
	year(start_date) AS year_20,
	LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS latest
FROM subscriptions
JOIN plans USING (plan_id)
WHERE year(start_date) = '2020')asd
WHERE latest = 3


-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

SELECT
	ROUND(AVG(DATEDIFF(upg_annual,start_date))) AS average_to_annual_plan
FROM (SELECT
	customer_id,
	plan_id,
	start_date,
	LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS upg_annual
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_id = 0 OR plan_id = 3) asd
WHERE upg_annual IS NOT NULL




-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


create temporary table t2 as (SELECT
	DATEDIFF(upg_annual,start_date) AS date_diff
FROM (SELECT
	customer_id,
	plan_id,
	start_date,
	LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS upg_annual
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)
WHERE plan_id = 0 OR plan_id = 3) asd
WHERE upg_annual IS NOT NULL)



select (date_diff) from t2 WHERE date_diff <= 30

SELECT 
  CASE
    WHEN date_diff >= 0 AND date_diff <= 30 THEN '0-30'
    WHEN date_diff >= 31 AND date_diff <= 61 THEN '31-61'
    WHEN date_diff >= 62 AND date_diff <= 92 THEN '62-92'
    WHEN date_diff >= 62 AND date_diff <= 92 THEN '93-123'
    WHEN date_diff >= 124 AND date_diff <= 154 THEN '124-154'
    WHEN date_diff >= 155 AND date_diff <= 185 THEN '155-185'
    WHEN date_diff >= 186 AND date_diff <= 216 THEN '186-216'
    WHEN date_diff >= 217 AND date_diff <= 247 THEN '217-247'
    WHEN date_diff >= 248 AND date_diff <= 278 THEN '248-278'
    WHEN date_diff >= 279 AND date_diff <= 309 THEN '279-309'
    WHEN date_diff >= 310 AND date_diff <= 340 THEN '310-340'
    ELSE 'MAX_RANGE'
  END AS range_by_30,
  ROUND(AVG(date_diff)) AS range_mean
FROM t2
GROUP BY range_by_30;


-- SELECT
--   CONCAT((FLOOR(date_diff / 31) * 31), '-', (FLOOR(date_diff / 31) * 31 + 30)) AS range_by_30,
--   ROUND(AVG(date_diff)) AS range_mean
-- FROM t2
-- GROUP BY range_by_30;


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

create temporary table next_plan_cte AS
  (SELECT *,
          lead(plan_id, 1) over(PARTITION BY customer_id
                                ORDER BY start_date) AS next_plan
   FROM subscriptions)
   
SELECT count(*) AS downgrade_count
FROM next_plan_cte
WHERE plan_id=2
  AND next_plan=1
  AND year(start_date);


 

 
 
 
 
 
 
SELECT customer_id, plan_id, plan_name, start_date, price,
   LEAD(start_date, 1) OVER(PARTITION BY customer_id 
       ORDER BY start_date, plan_id) cutoff_date
FROM subscriptions
JOIN plans
USING (plan_id)
WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
AND plan_name NOT IN('trial', 'churn')
 
 
WITH cte AS (
 SELECT customer_id, plan_id, plan_name, start_date, 
   LEAD(start_date, 1) OVER(PARTITION BY customer_id 
       ORDER BY start_date, plan_id) cutoff_date,
   price as amount
  FROM subscriptions
  JOIN plans
  USING (plan_id)
WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
AND plan_name NOT IN('trial', 'churn')
),
cte1 AS(
 SELECT customer_id, plan_id, plan_name, start_date, 
   COALESCE(cutoff_date, '2020-12-31') cutoff_date, amount
 FROM cte
)
SELECT * FROM cte1
 
 



WITH RECURSIVE cte AS (
 SELECT customer_id, plan_id, plan_name, start_date, 
   LEAD(start_date, 1) OVER(PARTITION BY customer_id 
       ORDER BY start_date, plan_id) cutoff_date,
   price as amount
  FROM subscriptions
  JOIN plans
  USING (plan_id)
  WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
   AND plan_name NOT IN('trial', 'churn')
),
cte1 AS(
 SELECT customer_id, plan_id, plan_name, start_date, 
   COALESCE(cutoff_date, '2020-12-31') cutoff_date, amount
 FROM cte
),
cte2 AS (
  SELECT customer_id, plan_id, plan_name, start_date, cutoff_date, amount FROM cte1

UNION ALL

SELECT customer_id, plan_id, plan_name, 
  DATE_ADD(start_date, INTERVAL 1 MONTH) AS start_date, 
  cutoff_date, amount FROM cte2
WHERE cutoff_date > DATE_ADD(start_date, INTERVAL 1 MONTH)
  AND plan_name <> 'pro annual'
)
SELECT * FROM cte2
ORDER BY customer_id, start_date;
 
 























-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE TABLE payments_2020 AS
WITH RECURSIVE cte AS (
 SELECT customer_id, plan_id, plan_name, start_date, 
   LEAD(start_date, 1) OVER(PARTITION BY customer_id 
       ORDER BY start_date, plan_id) cutoff_date,
   price as amount
  FROM subscriptions
  JOIN plans
  USING (plan_id)
  WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
   AND plan_name NOT IN('trial', 'churn')
),
cte1 AS(
 SELECT customer_id, plan_id, plan_name, start_date, 
   COALESCE(cutoff_date, '2020-12-31') cutoff_date, amount
 FROM cte
),
cte2 AS (
  SELECT customer_id, plan_id, plan_name, start_date, cutoff_date, amount FROM cte1

UNION ALL

SELECT customer_id, plan_id, plan_name, 
  DATE_ADD(start_date, INTERVAL 1 MONTH) AS start_date, 
  cutoff_date, amount FROM cte2
WHERE cutoff_date > DATE_ADD(start_date, INTERVAL 1 MONTH)
  AND plan_name <> 'pro annual'
),
cte3 AS (
 SELECT *, 
   LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) 
    AS last_payment_plan,
   LAG(amount, 1) OVER(PARTITION BY customer_id ORDER BY start_date) 
    AS last_amount_paid,
   RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS payment_order
 FROM cte2
 ORDER BY customer_id, start_date
)
SELECT customer_id, plan_id, plan_name, start_date AS payment_date, 
 (CASE 
   WHEN plan_id IN (2, 3) AND last_payment_plan = 1 
    THEN amount - last_amount_paid
   ELSE amount
 END) AS amount, payment_order
FROM cte3;
 

SELECT * FROM payments_2020;



WITH RECURSIVE cte AS (
  SELECT
    customer_id,
    plan_id,
    plan_name,
    start_date,
    LAG(start_date, 1, '2020-12-31') OVER (PARTITION BY customer_id ORDER BY start_date) AS cutoff_date,
    price AS amount
  FROM subscriptions
  JOIN plans USING (plan_id)
  WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
    AND plan_name NOT IN ('trial', 'churn')
),
cte2 AS (
  SELECT customer_id, plan_id, plan_name, start_date, cutoff_date, amount
  FROM cte
  WHERE plan_name = 'pro annual'
  
  UNION ALL
  
  SELECT
    customer_id,
    plan_id,
    plan_name,
    DATE_ADD(start_date, INTERVAL 1 MONTH),
    cutoff_date,
    amount
  FROM cte2
  WHERE cutoff_date > DATE_ADD(start_date, INTERVAL 1 MONTH)
    AND plan_name <> 'pro annual'
)
SELECT * FROM cte2
ORDER BY customer_id, start_date;







SELECT
	*
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)

SELECT * FROM plans p ;
SELECT * FROM subscriptions s 