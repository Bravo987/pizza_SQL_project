create database pizzahut;
use  pizzahut;
create table orders (order_id int not null , order_date date not null, order_time time not null , primary key (order_id));

create table orders_details
(order_details_id int not null, order_id int not null, 
pizza_id text not null, quantity int not null ,primary key (order_details_id));

 -- Questions are Below 
 
--  Q1 Reterive the total number of orders placed
select count(order_id) as total_orders from orders;

-- Q2 calculate the total revenue generated from pizaa sales-- 

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
    -- Q3 identify the highest - priced pizza.
   SELECT 
    pizzahut.pizza_types.name, pizzahut.pizzas.price
FROM
    pizzahut.pizza_types
        JOIN
    pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types 
-- along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5; 

-- Intermediate Questions 

--  Q1 join the necessary tables to find the 
-- total amount of each pizza category ordered. 

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity;


-- Q2 determine the distribution of orders by hour of the city.
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Q3 Join relevant tables to find the 
-- category - wise distribution of pizzas.

select category, count(name) from pizza_types group by category;

-- Q4 group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
   round( AVG(quantity),0)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    -- Q5 Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;    
    
-- Advanced query 

-- Q1 Calculate the percentage contribution of each 
-- pizza type to total revenue. 

SELECT 
    pizza_types.category,
   (SUM(orders_details.quantity * pizzas.price) / SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id))*100 as 
    
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q2  analyze the cumulative revenue generated over time.
select order_date, 
sum(revenue) over(order by order_date) as cum_revenue from 
(select orders.order_date ,
sum(orders_details.quantity * pizzas.price) as revenue 
from orders_details join pizzas 
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id 
group by orders.order_date) as sales;

-- Q3 Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.

select name, revenue from

(select category, name , revenue ,
rank() over (partition by category order by revenue desc ) as rn from
(select pizza_types.category, pizza_types.name , 
sum((orders_details.quantity ) * pizzas.price ) as revenue 
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b 
where rn <= 3;    