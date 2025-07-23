-- Retrieve the total number of orders placed.

SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.

SELECT pizza_id, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered. 

SELECT p.size, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM order_data) AS order_hour, COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS pizza_count
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT round(avg(quantity),0)from
(select orders.order_data, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_data) as order_quantity;

--                            advance
-- Calculate the percentage contribution of each pizza type to total revenue.

WITH revenue_by_pizza AS (
    SELECT pt.name AS pizza_name, SUM(od.quantity * p.price) AS pizza_revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
), total AS (
    SELECT SUM(pizza_revenue) AS total_revenue FROM revenue_by_pizza
)
SELECT pizza_name,
       ROUND(pizza_revenue, 2) AS revenue,
       ROUND((pizza_revenue / total.total_revenue) * 100, 2) AS percentage
FROM revenue_by_pizza, total
ORDER BY percentage DESC;

-- Analyze the cumulative revenue generated over time.

select pizza_types.category,
round(sum(order_details.quantity*pizzas.price) / (select
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue 
from
(select category, name,revenue,
rank () over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;

SELECT pt.name, ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;







