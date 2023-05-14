# :pizza: Case 2 - Pizza Runner - Runner and Customer Experience :pizza:

## Case Study Questions

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

***

###  1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
- Returned week number is between 0 and 52 or 0 and 53.
- Default mode of the week =0 -> First day of the week is Sunday
- Extract week -> WEEK(registration_date) or EXTRACT(week from registration_date)

```sql
SELECT 
	runner_id,
	registration_date ,
	WEEK(registration_date, 1) 
FROM runners r 
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/55b284b8-32dc-49d8-982e-560a5893cf26)

***

###  2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
CREATE TEMPORARY TABLE hd_pickup
(SELECT 
	DISTINCT (order_id),
	ro.runner_id,
	ROUND(TIMESTAMPDIFF(MINUTE, order_time, ro.pickup_time),2) as  pick_hd
FROM  customer_orders co 
INNER JOIN runner_orders ro USING (order_id)
WHERE distance > 0) 
```

#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/061343f5-f8b7-47b6-80ab-3d77ffd81e6a)



```sql
SELECT  ROUND(avg(pick_hd),2) AS avg_time FROM hd_pickup GROUP BY runner_id
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/79e441f2-fbd7-4bfe-866b-cb82d4f25e78)

***

###  3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
SELECT
order_id,
COUNT(order_id) as qtd_pizza_by_order,
AVG(pick_hd) as avg_prep_by_qtd
FROM(SELECT 
	co.order_id,
	ROUND(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time),2) as pick_hd
FROM customer_orders co
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.duration > 0) AS pizza_toprep1
GROUP BY order_id
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/f12f0be4-9f51-4fb4-85a2-3c601600e28b)

***

###  4. What was the average distance travelled for each customer?

```sql
SELECT 
customer_id,
ROUND(AVG(distance), 2) AS avg_dist_per_cust
FROM (SELECT 
	co.customer_id,
	ro.distance
FROM runner_orders ro 
INNER JOIN customer_orders co USING (order_id)
WHERE ro.cancellation = 0) AS all_cust
GROUP BY 1
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/f2bc1ca1-c48e-42d3-abc0-1c253e70537b)

***

###  5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT 
MIN(duration),
MAX(duration),
(MAX(duration) - MIN(duration)) AS max_difference
FROM  runner_orders ro 
WHERE duration > 0
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/f177eaa4-7147-4c6d-bb72-81168ff4e3d5)

***

###  6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
- To convert minutes to hours, divide the minutes by 60. So the total time taken is 32/60 = 0.53 hours.
- Only the duration and the distance been the same the avg speed is 60km/h

```sql
SELECT 
runner_id,
distance,
duration,
ROUND((duration/60),2) AS duration_minutes,
ROUND((distance/(duration/60)),2) AS avg_speed
FROM  runner_orders 
WHERE cancellation = 0
ORDER BY runner_id ASC
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/e20b655f-99ae-40d8-94c7-cace7e294564)

***

###  7. What is the successful delivery percentage for each runner?

```sql
SELECT 
sub_all.runner_id,
(sub_del.success_deliveries/sub_all.all_deliveries)*100 AS percentge_success_deliveries_by_runner
FROM 
	(SELECT 
	runner_id,
	COUNT(order_id) AS all_deliveries
	FROM  runner_orders ro 
	
	GROUP BY 1) AS sub_all
JOIN 
	(SELECT 
	runner_id,
	COUNT(order_id) AS success_deliveries
	FROM  runner_orders ro 
	WHERE cancellation < 1
	GROUP BY 1) AS sub_del
ON sub_del.runner_id = sub_all.runner_id
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/dac8346d-e34d-42fe-b38a-6d260b9ad777)

***

Click [here](https://github.com/djalmajr07/SQL_CHALLENGE/blob/main/Case%202%20-%20Pizza%20Runner/C.%20Ingredient%20Optimisation.md) to view the  solution of C. Ingredient Optimisation!
