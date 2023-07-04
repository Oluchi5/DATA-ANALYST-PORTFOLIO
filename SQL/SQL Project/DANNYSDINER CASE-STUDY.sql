/* --------------------
   Case Study Questions
   --------------------*/

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

-- Select table Query:

--Members Table
SELECT
  	*
FROM dannys_diner.dbo.members;


-- Menu table
SELECT
  	*
FROM dannys_diner.dbo.menu;


--Sales table
SELECT
  	*
FROM dannys_diner.dbo.sales;


-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    s.customer_id, 
	SUM(m.price) AS total_amount_spent
FROM dannys_diner.dbo.sales s
JOIN dannys_diner.dbo.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;



-- 2. How many days has each customer visited the restaurant?

SELECT 
    customer_id, 
	COUNT(DISTINCT order_date) AS total_days_visited
FROM dannys_diner.dbo.sales 
GROUP BY customer_id
ORDER BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?

WITH customer_first_purchase AS (
  SELECT 
      s.customer_id, m.product_name,
	  MIN(s.order_date) AS first_purchase_date
  FROM dannys_diner.dbo.sales s
  JOIN dannys_diner.dbo.menu m
  ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
  ORDER BY first_purchase_date
)
SELECT 
    c.customer_id, 
	c.product_name
FROM customer_first_purchase c
WHERE c.first_purchase_date = (
  SELECT MIN(first_purchase_date)
  FROM customer_first_purchase
  WHERE customer_id = c.customer_id
)
ORDER BY c.customer_id;
SELECT c.customer_id, m.product_name
FROM (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM dannys_diner.dbo.sales
  GROUP BY customer_id
) AS c
JOIN dannys_diner.dbo.sales AS s ON c.customer_id = s.customer_id AND c.first_order_date = s.order_date
JOIN dannys_diner.dbo.menu AS m ON s.product_id = m.product_id
ORDER BY c.customer_id;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    M.product_id,
	product_name,
	price,
	COUNT(S.product_id) AS total_purchases
FROM dannys_diner.dbo.menu AS M
INNER JOIN dannys_diner.dbo.sales AS S
ON M.product_id= S.product_id
GROUP BY M.product_id, product_name, price
ORDER BY total_purchases DESC
;



-- 5. Which item was the most popular for each customer?

WITH popular_items AS (
  SELECT 
      customer_id, 
	  product_id, 
	  COUNT(*) AS order_count,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
  FROM dannys_diner.dbo.sales
  GROUP BY customer_id, product_id
)
SELECT 
    p.customer_id, 
	m.product_name AS most_popular_item
FROM popular_items p
JOIN dannys_diner.dbo.menu m 
ON p.product_id = m.product_id
WHERE p.rn = 1
ORDER BY p.customer_id;



-- 6. Which item  was purchased first by the customer after they became a member?

SELECT 
    m.customer_id, 
	m.join_date, 
	MIN(s.order_date) AS first_purchase_date, 
	u.product_name AS first_purchase_item
FROM dannys_diner.dbo.members m
JOIN dannys_diner.dbo.sales s ON m.customer_id = s.customer_id
JOIN dannys_diner.dbo.menu u ON s.product_id = u.product_id
WHERE s.order_date > m.join_date
GROUP BY m.customer_id, m.join_date, u.product_name
ORDER BY m.customer_id;



-- 7. Which item was purchased just before the customer became a member?

SELECT 
    m.customer_id, 
	m.join_date, 
	MAX(s.order_date) AS last_purchase_date,
	u.product_name AS last_purchase_item
FROM dannys_diner.dbo.members m
JOIN dannys_diner.dbo.sales s 
ON m.customer_id = s.customer_id
JOIN dannys_diner.dbo.menu u 
ON s.product_id = u.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, m.join_date, u.product_name
ORDER BY m.customer_id;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
     m.customer_id, 
	 m.join_date,
     COUNT(s.product_id) AS total_items,
     SUM(u.price) AS total_amount_spent
FROM dannys_diner.dbo.members m
JOIN dannys_diner.dbo.sales s 
ON m.customer_id = s.customer_id
JOIN dannys_diner.dbo.menu u 
ON s.product_id = u.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, m.join_date
ORDER BY m.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
     s.customer_id, 
SUM(
  CASE
    WHEN m.product_name = 'sushi' THEN 20 * m.price
    ELSE 10 * m.price
  END
) AS total_points
FROM dannys_diner.dbo.sales s
JOIN dannys_diner.dbo.menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 
WITH customer_points AS (
  SELECT s.customer_id, s.order_date, u.product_name,
         CASE
           WHEN u.product_name = 'sushi' THEN
             CASE
               WHEN s.order_date <= DATEADD(DAY, 6, m.join_date) THEN 20 * u.price
               ELSE 10 * u.price
             END
           ELSE
             CASE
               WHEN s.order_date <= DATEADD(DAY, 6, m.join_date) THEN 20 * u.price
               ELSE 10 * u.price
             END
         END AS points
  FROM dannys_diner.dbo.sales s
  JOIN dannys_diner.dbo.menu u ON s.product_id = u.product_id
  JOIN dannys_diner.dbo.members m ON s.customer_id = m.customer_id
  WHERE s.order_date <= '2021-01-31' -- End of January
    AND (s.order_date >= m.join_date OR s.order_date <= DATEADD(DAY, 6, m.join_date))
)
SELECT customer_id, SUM(points) AS total_points
FROM customer_points
WHERE customer_id IN ('A', 'B')
GROUP BY customer_id
ORDER BY customer_id;
 
