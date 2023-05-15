# :pizza: Case 2 - Pizza runner - Bonus Question :pizza:

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

Supreme pizza has all toppings on it.

![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/f29d46c5-e1b5-42e2-979f-44ba396647a4)

We'd have to insert data into pizza_names and pizza_recipes tables

***

```sql
INSERT INTO pizza_names VALUES(3, 'Supreme');
SELECT * FROM pizza_names;
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/c83c792c-b5e8-4b50-9d64-bcd714f170ab)

```sql
INSERT INTO pizza_recipes
VALUES(3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));
``` 

```sql
SELECT * FROM pizza_recipes;
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/9f64746b-1222-4640-a2a6-b3a22ee02ff3)

*** 

```sql
SELECT *
FROM pizza_names
INNER JOIN pizza_recipes USING(pizza_id);
``` 
![image](https://github.com/djalmajr07/SQL_CHALLENGE/assets/85264359/c8ba5c3d-da06-46ea-9eba-55a425789c9d)

***

Click [here](https://github.com/djalmajr07/SQL_CHALLENGE/tree/main) to move back to the 8-Week-SQL-Challenge repository!
