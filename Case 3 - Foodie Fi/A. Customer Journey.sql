--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!


# 7, 122, 275, 431, 650, 777, 814, 12

# CUSTOMER 7
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =7;

- Started with a trial plan
- After 7 days subscribed to basic plan
- Couple days later subscribed to pro plan


# CUSTOMER 122
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =122;

- Customer started a free trial on 2020-03-30
- Customer cancelled after six days 

# CUSTOMER 275
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =275;

- Started started a free trial on 2020-04-27
- Customer subscribed to basic plan after trial
- Plan cancelation after couple months


# CUSTOMER 431
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =431;

- Started started a free trial on 2020-12-27
- Customer subscribed to basic plan after trial
- Plan cancelation after couple months


# CUSTOMER 650
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =650;

- Started by trial plan
- Churn after trial plan finished

# CUSTOMER 777
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =777;

- Started started a free trial on 2020-09-06
- Customer subscribed to pro plan after trial
- Plan cancelation after a month

# CUSTOMER 814, 
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =814;

- Started started a free trial on 2020-11-11
- Customer subscribed to basic plan after trial
- Plan cancelation after almost six months

# CUSTOMER 12
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions  
INNER JOIN plans USING (plan_id)
WHERE customer_id =12;

- Started started a free trial on 2020-11-11
- Customer subscribed to basic plan after trial
