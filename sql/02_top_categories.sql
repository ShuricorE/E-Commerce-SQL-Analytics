-- Q2: Which product categories bring in the most revenue?
-- Delivered orders, Jan 2017 to Aug 2018. Revenue = item price.
WITH items AS (
    SELECT i.order_id,
           i.price,
           COALESCE(t.product_category_name_english,
                    p.product_category_name, 'unknown') AS category
    FROM order_items i
    JOIN orders o               ON o.order_id = i.order_id
    LEFT JOIN products p        ON p.product_id = i.product_id
    LEFT JOIN category_translation t
                                ON t.product_category_name = p.product_category_name
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp <  DATE '2018-09-01'
)
SELECT category,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue,
       ROUND(AVG(price), 2)     AS avg_item_price,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1) AS revenue_share_pct,
       ROUND(100.0 * SUM(SUM(price)) OVER (ORDER BY SUM(price) DESC)
             / SUM(SUM(price)) OVER (), 1) AS cumulative_share_pct
FROM items
GROUP BY category
ORDER BY revenue DESC
LIMIT 15;