-- Q6: Which states have the slowest deliveries and the unhappiest customers?
-- Delivered orders, Jan 2017 to Aug 2018. State = customer's state.
WITH order_reviews AS (
    SELECT order_id,
           AVG(TRY_CAST(review_score AS DOUBLE)) AS review_score
    FROM reviews
    WHERE TRY_CAST(review_score AS DOUBLE) BETWEEN 1 AND 5
    GROUP BY order_id
),
deliveries AS (
    SELECT c.customer_state AS state,
           DATE_DIFF('day',
                     CAST(o.order_purchase_timestamp AS DATE),
                     CAST(o.order_delivered_customer_date AS DATE)) AS delivery_days,
           CASE WHEN CAST(o.order_delivered_customer_date AS DATE)
                     > CAST(o.order_estimated_delivery_date AS DATE)
                THEN 1 ELSE 0 END AS is_late,
           r.review_score
    FROM orders o
    JOIN customers c          ON c.customer_id = o.customer_id
    LEFT JOIN order_reviews r ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp <  DATE '2018-09-01'
)
SELECT state,
       COUNT(*)                          AS orders,
       ROUND(AVG(delivery_days), 1)      AS avg_delivery_days,
       ROUND(100.0 * AVG(is_late), 1)    AS pct_late,
       ROUND(AVG(review_score), 2)       AS avg_review
FROM deliveries
GROUP BY state
ORDER BY pct_late DESC;