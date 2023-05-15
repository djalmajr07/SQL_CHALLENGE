# :pizza: Case 2 - Pizza runner - Ingredient Optimisation  :pizza:

## Case Study Questions

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

***

## Temporary tables created to solve the below queries

```sql
DROP TABLE row_split_customer_orders_temp;

CREATE TEMPORARY TABLE row_split_customer_orders_temp AS
SELECT t.row_num,
       t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM
  (SELECT *,
          row_number() over() AS row_num
   FROM customer_orders) t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')),
                      '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')),
                      '$[*]' columns (extras varchar(50) PATH '$')) j2 ;


SELECT *
FROM row_split_customer_orders_temp;
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/ec73c6ab-cdb6-4144-b835-43ade56bda8f)


```sql
CREATE
TEMPORARY TABLE row_split_pizza_recipes_temp1 AS
SELECT
pizza_id,
SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1) as toppings_all 
FROM pizza_recipes pr 
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8) AS tops
ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1 
ORDER BY pizza_id 


SELECT *
FROM row_split_pizza_recipes_temp1;
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/7ea73bec-1fa0-4ce3-9289-8aad785c0a37)


```sql
DROP TABLE IF EXISTS standard_ingredients;

CREATE TEMPORARY TABLE standard_ingredients AS
SELECT pizza_id,
       pizza_name,
       group_concat(DISTINCT topping_name) 'standard_ingredients'
FROM row_split_pizza_recipes_temp
INNER JOIN pizza_names USING (pizza_id)
INNER JOIN pizza_toppings USING (topping_id)
GROUP BY pizza_name
ORDER BY pizza_id;

SELECT *
FROM standard_ingredients;
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/64fefa8e-48b2-4bc0-9b38-3b651c0b2465)



###  1. What are the standard ingredients for each pizza?

```sql
SELECT *
FROM standard_ingredients;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/edde2007-f877-4e16-96d3-04855bdabb40)

***

###  2. What was the most commonly added extra?

```sql
CREATE
TEMPORARY TABLE most_added_top0 AS 
SELECT 
	pizza_id,
	extras,
	COUNT(extras) AS count_most_added_nr
FROM row_split_customer_orders_temp
WHERE extras != '0'
GROUP BY 1,2
``` 
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/db8544c1-8afe-48e7-aee7-5b6d429eaa30)


```sql
SELECT 
	pizza_id,
	extras,
	count_most_added_nr,
	SUBSTRING_INDEX(SUBSTRING_INDEX(standard_ingredients, ',', 1), ',', -1)  AS MOST_ADDED_TOP_NAME
FROM standard_ingredients
INNER JOIN most_added_top0 mt USING(pizza_id)
LIMIT 2
``` 
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/92895227-4575-4eb7-805b-030442e6e3a7)

***

###  3. What was the most common exclusion?

```sql
CREATE 
TEMPORARY TABLE most_excluded_top AS 
SELECT  
	pizza_id,
	exclusions,
	COUNT(exclusions) AS most_excluded_top_nr
FROM row_split_customer_orders_temp
WHERE exclusions != 0
GROUP BY 1,2
``` 
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/ac6c35d4-1879-4ab4-971c-abf215a808ab)


```sql
SELECT 
	pizza_id,
	exclusions,
	most_excluded_top_nr,
	SUBSTRING_INDEX(SUBSTRING_INDEX(standard_ingredients, ',', 4), ',', -1) AS MOST_EXCLUDED_TOP_NAME
FROM standard_ingredients
INNER JOIN most_excluded_top USING(pizza_id)
LIMIT 2
```

#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/8d554890-0320-41e8-919e-2ceb0125a956)





```sql

```
	


***

###  4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
SELECT
	*,
	CASE 
		WHEN exclusions = 0 AND pizza_id = 1 THEN 'Meat Lovers'
		WHEN exclusions = 0 AND pizza_id = 2 THEN 'Vegetarian'
		WHEN exclusions = 3 AND pizza_id = 1 THEN 'Meat Lovers - Exclude Beef'
		WHEN extras = 1 AND pizza_id = 1 THEN 'Meat Lovers - Extra Bacon'
		WHEN exclusions = 4 AND pizza_id = 1 THEN 'Meat Lovers - Exclude Cheese'
		WHEN exclusions = 4 AND exclusions = 1 AND extras = 6 AND extras = 9 AND pizza_id = 1 THEN 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
-- 		ELSE 'Meat Lover'
	END AS customized_orders	
FROM row_split_customer_orders_temp;
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/62bb2e22-e776-4991-9467-6818b08eb491)



```sql
 CREATE TEMPORARY TABLE order_summary_cte AS
  (SELECT pizza_name,
          row_num,
          order_id,
          customer_id,
          excluded_topping,
          t2.topping_name AS extras_topping
   FROM
     (SELECT *,
             topping_name AS excluded_topping
      FROM row_split_customer_orders_temp
      LEFT JOIN standard_ingredients USING (pizza_id)
      LEFT JOIN pizza_toppings ON topping_id = exclusions) t1
   LEFT JOIN pizza_toppings t2 ON t2.topping_id = extras)
   
   
   
   SELECT * FROM order_summary_cte
```

#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/58cc6962-6ed7-4508-9324-b6b80e819ed8)


```sql
SELECT 
       order_id,
       customer_id,
       CASE
           WHEN excluded_topping IS NULL AND extras_topping   IS NULL     THEN pizza_name
           WHEN extras_topping   IS NULL AND excluded_topping IS NOT NULL THEN concat(pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
           WHEN excluded_topping IS NULL AND extras_topping   IS NOT NULL THEN concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping))
           ELSE concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping), ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
       END AS order_item
FROM order_summary_cte
GROUP BY 1,2,row_num,extras_topping,excluded_topping,pizza_name;
```

#### Final Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/5662c048-a882-44f9-9a53-72f8491b8aee)





***

###  5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
SELECT 
	   order_id,
       customer_id,
       CASE
           WHEN excluded_topping IS NULL AND extras_topping   IS NULL     THEN pizza_name
           WHEN extras_topping   IS NULL AND excluded_topping IS NOT NULL THEN concat(pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
           WHEN excluded_topping IS NULL AND extras_topping   IS NOT NULL THEN concat(pizza_name, ' - 2x', GROUP_CONCAT(DISTINCT extras_topping))
           ELSE concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping), ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
       END AS order_item
FROM order_summary_cte
GROUP BY 1,2,row_num,extras_topping,excluded_topping,pizza_name;
``` 

#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/4d0a17c9-829c-4bd2-b370-f124880c245f)


***

###  6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
CREATE TABLE pizza_ingredients_counts1 (
  pizza_id INT,
  ingredient VARCHAR(50),
  ingredient_count INT
);


INSERT INTO pizza_ingredients_counts1
SELECT 
	pizza_id, 
	topping_id, 
	COUNT(*)
FROM (SELECT * FROM row_split_customer_orders_temp cot1
LEFT JOIN row_split_pizza_recipes_temp USING(pizza_id)) as a1
GROUP BY pizza_id, topping_id;






### extra 1,4,5

UPDATE pizza_ingredients_counts1
SET ingredient_count = ingredient_count + 1
WHERE (pizza_id = 1 ) AND ingredient = 1;

UPDATE pizza_ingredients_counts
SET ingredient_count = ingredient_count + 1
WHERE pizza_id = 1 AND ingredient = 5;

UPDATE pizza_ingredients_counts1
SET ingredient_count = ingredient_count + 1
WHERE (pizza_id = 1 OR pizza_id = 2) AND ingredient = 4;



##
### exclusion 2,4,6
UPDATE pizza_ingredients_counts1
SET ingredient_count = ingredient_count - 1
WHERE (pizza_id = 1 OR pizza_id = 2) AND ingredient = 4;

UPDATE pizza_ingredients_counts1
SET ingredient_count = ingredient_count - 1
WHERE (pizza_id = 1 OR pizza_id = 2) AND ingredient = 6;


UPDATE pizza_ingredients_counts
SET ingredient_count = ingredient_count - 1
WHERE pizza_id = 1 AND ingredient = 2;

select * from pizza_ingredients_counts1
``` 
	
#### Result set:
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/65bdd7cb-825d-43c4-85f9-605507641531)

***

Click [here](https://github.com/djalmajr07/SQL_CHALLENGE/blob/main/Case%202%20-%20Pizza%20Runner/D.%20Pricing%20and%20Ratings.md) to view the  solution of D. Pricing and Ratings!

