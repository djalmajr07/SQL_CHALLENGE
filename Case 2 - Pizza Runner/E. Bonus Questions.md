# :pizza: Case 2 - Pizza runner - Bonus Question :pizza:

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

Supreme pizza has all toppings on it.

![image]()

We'd have to insert data into pizza_names and pizza_recipes tables

***

```sql
INSERT INTO pizza_names VALUES(3, 'Supreme');
SELECT * FROM pizza_names;
``` 
![image]()

```sql
INSERT INTO pizza_recipes
VALUES(3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));
``` 

```sql
SELECT * FROM pizza_recipes;
``` 
![image]()

*** 

```sql
SELECT *
FROM pizza_names
INNER JOIN pizza_recipes USING(pizza_id);
``` 
![image]()

***

Click [here]() to move back to the 8-Week-SQL-Challenge repository!

