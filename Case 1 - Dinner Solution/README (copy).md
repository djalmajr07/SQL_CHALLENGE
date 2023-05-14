# :ramen: Case Study #1: Danny's Diner :ramen:

## Case Study Questions

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

###  1. What is the total amount each customer spent at the restaurant?

```sql
SELECT 
	s.customer_id,
	SUM(m.price) AS amount_spent
FROM sales s
INNER JOIN menu m USING (product_id )
GROUP BY s.customer_id
ORDER BY customer_id;
``` 
	
#### Result set:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | $76         |
| B           | $74         |
| C           | $36         |

***

###  2. How many days has each customer visited the restaurant?

```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) 
FROM sales s 
GROUP BY customer_id 
ORDER BY customer_id;
``` 
	
#### Result set:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

***

###  3. What was the first item from the menu purchased by each customer?

- This appproach solves the question but what if the customers had their first purchase in different days?

```sql
SELECT 
	s.customer_id,
	s.order_date,
	MIN(order_date) AS first_purchase,
	m.product_name 
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY customer_id
```

#### Final approach 
```sql
WITH order_info_cte AS
  (SELECT customer_id,
          order_date,
          product_name,
          DENSE_RANK() OVER(PARTITION BY s.customer_id
                            ORDER BY s.order_date) AS rank_num
   FROM dannys_diner.sales AS s
   JOIN dannys_diner.menu AS m ON s.product_id = m.product_id)
SELECT customer_id,
       product_name
FROM order_info_cte
WHERE rank_num = 1
GROUP BY customer_id,
         product_name;
``` 
	
#### Result set:
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

```sql
WITH order_info_cte AS
  (SELECT customer_id,
          order_date,
          product_name,
          DENSE_RANK() OVER(PARTITION BY s.customer_id
                            ORDER BY s.order_date) AS rank_num
   FROM dannys_diner.sales AS s
   JOIN dannys_diner.menu AS m ON s.product_id = m.product_id)
  SELECT customer_id,
          GROUP_CONCAT(DISTINCT product_name
                    ORDER BY product_name) AS product_name
   FROM order_info_cte
   WHERE rank_num = 1
   GROUP BY customer_id
;
``` 

#### Result set:
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry, sushi |
| B           | curry        |
| C           | ramen        |

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

- What is the most purchased item on the menu
```sql
SELECT 	product_id, COUNT(product_id) AS most_pop FROM sales s GROUP BY product_id  ORDER BY most_pop DESC
``` 

- how many times was it purchased by all customers

```sql
SELECT 
	s.customer_id,
	m.product_name, 
	COUNT(product_id) AS most_purchased_item
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY s.customer_id, m.product_name 
ORDER BY most_purchased_item DESC 
``` 
	
#### Result set:
| most_purchased_item | order_count |
| ------------------- | ----------- |
| ramen               | 8           |



***

###  5. Which item was the most popular for each customer?

```sql
SELECT 
	s.customer_id,
	m.product_name, 
	COUNT(product_id) AS most_purchased_item
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY s.customer_id, m.product_name 
ORDER BY most_purchased_item DESC ;
``` 
	
#### Result set:
| customer_id | product_name | order_count |
| ----------- | ------------ | ----------- |
| A           | ramen        | 3           |
| B           | ramen        | 2           |
| B           | curry        | 2           |
| B           | sushi        | 2           |
| C           | ramen        | 3           |


***

###  6. Which item was purchased first by the customer after they became a member?

```sql
SELECT 
	m.customer_id,
	s.order_date,
	m2.product_name
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date >= m.join_date 
GROUP BY s.customer_id
``` 
	
#### Result set:
| customer_id | product_name | order_date               |
| ----------- | ------------ | ------------------------ |
| A           | curry        | 2021-01-07T00:00:00.000Z |
| B           | sushi        | 2021-01-11T00:00:00.000Z |

***

###  7. Which item was purchased just before the customer became a member?

```sql
SELECT 
	customer_id,
	m2.product_name,
	s.order_date 
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id, product_name, s.order_date 
``` 
	
#### Result set:
| customer_id | product_name | order_date               | join_date                |
| ----------- | ------------ | ------------------------ | ------------------------ |
| A           | curry,sushi  | 2021-01-01T00:00:00.000Z | 2021-01-07T00:00:00.000Z |
| B           | sushi        | 2021-01-04T00:00:00.000Z | 2021-01-09T00:00:00.000Z |

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
SELECT 
	customer_id,
	COUNT(product_name) AS total_items,
	SUM(m2.price) AS amount_spent
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id 
``` 
	
#### Result set:
| customer_id | total_items | amount_spent |
| ----------- | ----------- | ------------ |
| A           | 2           | $25          |
| B           | 3           | $40          |

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

#### Had the customer joined the loyalty program before making the purchases, total points that each customer would have accrued
```sql
CREATE TEMPORARY TABLE promo_1 AS 
SELECT
	*,
	CASE WHEN product_id = 1 THEN price * 2 
	ELSE price 
	END AS points
FROM menu m2
 
SELECT 
	s.customer_id, 
	SUM(p.points) AS score
FROM promo_1 AS p  
JOIN sales s USING (product_id)
GROUP BY s.customer_id 
``` 
	
#### Result set:
| customer_id | customer_points |
| ----------- | --------------- |
| A           | 860             |
| B           | 940             |
| C           | 360             |

#### Total points that each customer has accrued after taking a membership
```sql
SELECT s.customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM dannys_diner.menu AS m
INNER JOIN dannys_diner.sales AS s ON m.product_id = s.product_id
INNER JOIN dannys_diner.members AS mem ON mem.customer_id = s.customer_id
WHERE order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
``` 
	
#### Result set:
| customer_id | customer_points |
| ----------- | --------------- |
| A           | 510             |
| B           | 440             |

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

#### Steps
1. Find the program_last_date which is 7 days after a customer joins the program (including their join date)
2. Determine the customer points for each transaction and for members with a membership
- During the first week of the membership -> points = price*20 irrespective of the purchase item
- Product = Sushi -> and order_date is not within a week of membership -> points = price*20
- Product = Not Sushi -> and order_date is not within a week of membership -> points = price*10
3. Conditions in WHERE clause
- order_date <= '2021-01-31' -> Order must be placed before 31st January 2021
- order_date >= join_date -> Points awarded to only customers with a membership

```sql
CREATE TEMPORARY TABLE member_promo_1 AS 
SELECT
	*,
	CASE WHEN product_id IN (1,2,3) THEN price * 2 
	END AS member_points
FROM menu m2
```


```sql
SELECT 
	s.customer_id,
	SUM(p.member_points) AS score
FROM member_promo_1 AS p  
JOIN sales s USING (product_id)
JOIN members m USING (customer_id)
WHERE s.order_date >= m.join_date AND s.order_date < '2021-01-31'
GROUP BY s.customer_id 
```


## Rank All The Things

```sql
SELECT 
	s.customer_id,
	order_date,
	m.product_name,
	CASE 
	WHEN (customer_id = "A" AND m.product_name = "ramen") THEN 1
	WHEN (customer_id = "A" AND m.product_name = "curry") THEN 2
	WHEN (customer_id = "B" AND m.product_name = "sushi") THEN 1
	WHEN (customer_id = "B" AND m.product_name = "ramen") THEN 2
	END AS "ranking",
	m.price,
	CASE WHEN (s.customer_id IN ("A", "B") AND s.order_date >= "2021-01-07") OR (s.customer_id IN ("A", "B") AND s.order_date >= "2021-01-11") THEN "YES"
	ELSE "NOT YET"
	END AS "currently_member"
FROM sales s 
LEFT JOIN menu m USING (product_id)
```




```sql
CREATE TEMPORARY TABLE ranking AS
SELECT 
	s.customer_id,
	m.product_name,
	order_date,
	CASE 
	WHEN (customer_id = "A" AND m.product_name = "ramen") THEN 1
	WHEN (customer_id = "A" AND m.product_name = "curry") THEN 2
	WHEN (customer_id = "B" AND m.product_name = "sushi") THEN 1
	WHEN (customer_id = "B" AND m.product_name = "ramen") THEN 2
	END AS "ranking"
FROM sales s 
LEFT JOIN menu m USING (product_id)
WHERE (customer_id = "A" AND order_date >= "2021-01-07") OR  (customer_id = "B" AND order_date >= "2021-01-11") OR (customer_id = "C")
GROUP BY s.customer_id, m.product_name 
ORDER BY customer_id ASC 
``` 

--SELECT
--	s.customer_id ,
--	m.product_name ,
--	RANK () OVER ( 
--		ORDER BY m.product_name  
--	) ValRank
--FROM sales s 
--LEFT JOIN menu m USING (product_id)


```sql
CREATE TEMPORARY TABLE ranking_1 AS
SELECT 
  customer_id ,
  order_date ,
  m.product_name  ,
  RANK() OVER (PARTITION BY customer_id
                    ORDER BY m.product_name DESC
                    ) AS ranking
FROM sales s 
LEFT JOIN menu m USING (product_id)
WHERE (customer_id = "A" AND order_date >= "2021-01-07") OR  (customer_id = "B" AND order_date >= "2021-01-11") OR (customer_id = "C")
``` 

--select *from sales s 
--SELECT 
--	s.customer_id,
--	m.product_name, 
--	COUNT(product_id) AS most_purchased_item
--FROM sales s 
--LEFT JOIN menu m USING (product_id)
--WHERE 
--GROUP BY s.customer_id, m.product_name 
--ORDER BY most_purchased_item DESC 



```sql
SELECT 
	s.customer_id as ID
  	,(SUM(m.price)*20) As Total_points
FROM sales s
INNER JOIN menu m
    ON s.product_id  = m.product_id
INNER JOIN members mem
     ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date AND s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY  ID
``` 

***


Click [here](https://github.com/djalmajr07/SQL_CHALLENGE) to move back to the 8-Week-SQL-Challenge repository!



