-- Q5: Do late deliveries lead to bad reviews?
-- Days late = actual delivery date minus the date promised to the customer.
-- One order can have more than one review, so scores are averaged per order.
WITH order_reviews AS (
    SELECT order_id,
           AVG(TRY_CAST(review_score AS DOUBLE)) AS review_score
    FROM reviews
    WHERE TRY_CAST(review_score AS DOUBLE) BETWEEN 1 AND 5
    GROUP BY order_id
),
deliveries AS (
    SELECT o.order_id,
           DATE_DIFF('day',
                     CAST(o.order_estimated_delivery_date AS DATE),
                     CAST(o.order_delivered_customer_date AS DATE)) AS days_late,
           r.review_score
    FROM orders o
    JOIN order_reviews r ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp <  DATE '2018-09-01'
)
SELECT CASE WHEN days_late <= 0 THEN '1. On time or early'
            WHEN days_late <= 3 THEN '2. 1 to 3 days late'
            WHEN days_late <= 7 THEN '3. 4 to 7 days late'
            ELSE '4. More than 7 days late' END AS delivery,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
FROM deliveries
GROUP BY delivery
ORDER BY delivery;