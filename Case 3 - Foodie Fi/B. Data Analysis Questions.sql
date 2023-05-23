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
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


SELECT
	*
FROM subscriptions s 
INNER JOIN plans p USING(plan_id)

SELECT * FROM plans p ;
SELECT * FROM subscriptions s 