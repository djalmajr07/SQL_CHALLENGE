# :pizza: Case 2 - Pizza runner - Pricing and Ratings :pizza:

## Case Study Questions

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

***

###  1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT
	CONCAT('$ ', SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END)) AS total_money_made_by_pizza_runner
FROM  customer_orders co
LEFT JOIN  runner_orders ro USING(order_id)
WHERE ro.cancellation = 0;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/e6a02377-b975-4dbe-900c-ec2da1b750ea)

***

###  2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
 CREATE TEMPORARY TABLE customer_orders_pizza_price(SELECT *,
		 length(extras) - length(replace(extras, ",", ""))+1 AS topping_count
  FROM customer_orders co
  INNER JOIN pizza_names USING (pizza_id)
  INNER JOIN runner_orders USING (order_id)
  WHERE cancellation = 0
  ORDER BY order_id) 
  
  
UPDATE customer_orders_pizza_price
SET pizza_price = pizza_price + 
           CASE WHEN extras <> '0' 
                THEN LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1 
                ELSE 0 
           END
WHERE extras <> '0' 
 
 
 SELECT CONCAT('$', SUM(pizza_price))  FROM customer_orders_pizza_price 
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/2deff205-b39e-4402-bfa0-c6806b344b2f)


#### I DECIDE TO CREATE A PROCEDURE TO RUN AND CORRECT THE PRICE FOR EACH NEW ENTRY

```sql
# PROCEDURE TO RUN EACH NEW ENTRY 
DELIMITER //

CREATE TRIGGER after_insert_t12
AFTER INSERT ON t12
FOR EACH ROW
BEGIN
    UPDATE t12
    SET pizza_price = pizza_price + 
               CASE WHEN extras <> '0' 
                    THEN LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1 
                    ELSE 0 
               END
    WHERE order_id = NEW.order_id;
END //

DELIMITER ;
```
***

###  3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings(
		order_id INTEGER,
		rating INTEGER,
		feedback varchar(55));

INSERT INTO runner_ratings(order_id, rating, feedback)
VALUES
    (1, 2, 'Cold pizza, I didnt like it'),
    (2, 3, 'Good service'),
    (3, 3, 'Pizza still pretty warm'),
    (4, 1, 'ARE YOU EATING MY FOOD????'),
    (5, 5, 'Efficient delivery'),
    (6, NULL, 'Got it canceled')
    (7, 4, 'Good service'),
    (8, 4, 'Super fast I really liked it'),
    (9, NULL, 'Canceled')
    (10, 5, 'This guy came flying!');
    
 SELECT * FROM  runner_ratings
``` 


	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/3c3f0de4-6b96-416e-bf32-a534d9f501f7)




***

###  4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql

SELECT 
	customer_id,
	order_id,
	ro.runner_id,
	rr.rating,
	order_time,
	ro.pickup_time,
	ROUND(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time),2) as pick_hd,
	ROUND((ro.duration/60),2) AS duration_minutes,
	ROUND((ro.distance/(ro.duration/60)),2) AS avg_speed,
	COUNT(ro.order_id) AS total_pizzas_delivered
FROM customer_orders co 
INNER JOIN runner_orders ro USING(order_id)
INNER JOIN runner_ratings rr USING(order_id)
GROUP BY 1,2,3,4,5,6,7,8,9 
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/1eb00840-baea-4fbe-aa89-09622b5544dc)

***

###  5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
SELECT  
	order_id ,
		order_time ,
		customer_id ,
		distance ,
		(0.30 * distance) as runner_payment,
	(pizza_price - (0.30 * distance)) as last_pizza_money
FROM (SELECT 
		order_id ,
		order_time ,
		pizza_id ,
		customer_id ,
		distance ,
		CASE
			WHEN pizza_id = 1 THEN 12 ELSE 10
		END AS pizza_price,
		length(extras) - length(replace(extras, ",", ""))+1 AS topping_count
  FROM customer_orders co
  INNER JOIN pizza_names USING (pizza_id)
  INNER JOIN runner_orders USING (order_id)
  WHERE cancellation = 0
  GROUP BY co.order_id, co.order_time, co.pizza_id, co.customer_id, distance, topping_count, pizza_price
  ORDER BY order_id) sub_query;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/897e2b5f-7420-45cb-b9f9-fd98854b8f00)


***

Click [here](https://github.com/djalmajr07/SQL_CHALLENGE/blob/main/Case%202%20-%20Pizza%20Runner/E.%20Bonus%20Questions.md) to view the solution of E. Bonus Questions!

Click [here](https://github.com/djalmajr07/SQL_CHALLENGE/tree/main) to move back to the 8-Week-SQL-Challenge repository!


