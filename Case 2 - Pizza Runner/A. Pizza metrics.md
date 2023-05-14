# :pizza: Case 2 - Pizza Runner - Pizza Metrics :pizza:

## Case Study Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

***

###  1. How many pizzas were ordered?

```sql
SELECT 
    COUNT(order_id) AS total_orders  
FROM customer_orders co 

``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/9153dbcf-d139-4861-9cf2-1d9cfda7b22f)

***

###  2. How many unique customer orders were made?

```sql
SELECT 
  COUNT(DISTINCT order_id) AS 'total_orders'
FROM customer_orders;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/9cd7e698-8c12-4faf-9aaf-fc07330ddca1)

***

###  3. How many successful orders were delivered by each runner?

```sql
SELECT 
	runner_id, 
	COUNT(order_id) AS pizza_delivered
FROM runner_orders ro 
WHERE distance NOT IN (0)
GROUP BY runner_id
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/9c4d76d2-c36f-4444-bef6-fe5f7b9b7428)

***

###  4. How many of each type of pizza was delivered?

```sql
SELECT 
	COUNT(ro.order_id) AS total_pizzas_delivered,
	pn.pizza_name
FROM customer_orders co 
LEFT JOIN runner_orders ro USING (order_id)
LEFT JOIN pizza_names pn USING(pizza_id)
WHERE ro.distance NOT IN (0)
GROUP BY pn.pizza_name
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/58f79cdb-b969-41f7-a146-aeda7bc4cee6)

***

###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT 
	customer_id,
	pizza_name, 
	COUNT(pn.pizza_name) AS quantity_by_user
FROM customer_orders co 
LEFT JOIN pizza_names pn USING(pizza_id)
GROUP BY customer_id, pizza_name
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/82461488-71d3-403e-872f-b8eedf726796)

***

###  6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT 
	order_id,
	COUNT(pizza_id) AS max_quantity_pizza_ordered,
	order_time
FROM customer_orders co 
LEFT JOIN runner_orders ro USING (order_id)
LEFT JOIN pizza_names pn USING(pizza_id)
WHERE ro.distance NOT IN (0)
GROUP BY order_id, order_time
ORDER BY max_quantity_pizza_ordered DESC
LIMIT 1
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/7ebf89a9-504a-4d56-8457-f21f46a8a3ef)

***

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- at least 1 change -> either exclusion or extras 
- no changes -> exclusion and extras are NULL

```sql
SELECT 
	customer_id,
	SUM(CASE WHEN (exclusions > 0  OR extras > 0) THEN 1 ELSE 0 END) AS at_least_one_change,
	SUM(CASE WHEN (exclusions = 0 AND extras = 0) THEN 1 ELSE 0 END) AS no_change
FROM customer_orders co 
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.distance NOT IN (0)
GROUP BY customer_id;
``` 

#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/60148375-737b-4205-bdc9-21e7e0da8b3f)

***

###  8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT STRFTIME('%Y-%m-%d %H', order_time) as hour,
       COUNT(*) as max_volume_of_order
FROM customer_orders co 
GROUP BY STRFTIME('%Y-%m-%d %H', order_time)
ORDER BY hour ASC
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/6104827d-fcab-4077-bbf6-a98903b1840c)

***

###  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT hour(order_time) AS 'Hour',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164611355-1e9338d0-0523-42f6-8648-079a394387ff.png)

***

###  10. What was the volume of orders for each day of the week?
- The DAYOFWEEK() function returns the weekday index for a given date ( 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday )
- DAYNAME() returns the name of the week day 

```sql
SELECT dayname(order_time) AS 'Day Of Week',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/49058e18-c009-4cd7-ab08-4c602eb16908)

***

Click [here]() to view the solution of B. Runner and Customer Experience!

