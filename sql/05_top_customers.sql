-- Q4: How much revenue comes from the top 10% of customers?
-- Customers = customer_unique_id. Delivered orders, Jan 2017 to Aug 2018.
WITH spend AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS orders,
           SUM(i.price)               AS revenue
    FROM orders o
    JOIN customers c   ON c.customer_id = o.customer_id
    JOIN order_items i ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp <  DATE '2018-09-01'
    GROUP BY c.customer_unique_id
),
ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM spend
)
SELECT decile,
       COUNT(*)                  AS customers,
       ROUND(SUM(revenue), 2)    AS revenue,
       ROUND(AVG(revenue), 2)    AS avg_spend,
       ROUND(AVG(orders), 2)     AS avg_orders,
       ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
       ROUND(100.0 * SUM(SUM(revenue)) OVER (ORDER BY decile)
             / SUM(SUM(revenue)) OVER (), 1) AS cumulative_share_pct
FROM ranked
GROUP BY decile
ORDER BY decile;