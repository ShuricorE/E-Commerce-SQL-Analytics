-- Q1: How are revenue and orders growing month by month?
-- Revenue = item price (excludes shipping), delivered orders only.
-- Jan 2017 to Aug 2018: earlier and later months are incomplete.
WITH delivered AS (
    SELECT order_id,
           DATE_TRUNC('month', order_purchase_timestamp) AS month
    FROM orders
    WHERE order_status = 'delivered'
),
monthly AS (
    SELECT d.month,
           COUNT(DISTINCT d.order_id) AS orders,
           ROUND(SUM(i.price), 2)     AS revenue
    FROM delivered d
    JOIN order_items i ON i.order_id = d.order_id
    GROUP BY d.month
)
SELECT month,
       orders,
       revenue,
       ROUND(revenue / orders, 2) AS avg_order_value,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS revenue_growth_pct
FROM monthly
WHERE month BETWEEN DATE '2017-01-01' AND DATE '2018-08-01'
ORDER BY month;
