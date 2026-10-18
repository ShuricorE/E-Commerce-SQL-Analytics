-- Q3b: Monthly cohort retention.
-- Cohort = month of a customer's first purchase. Retention = share of the
-- cohort who bought again 1 to 6 months later. Delivered orders, Jan 2017 to Aug 2018.
WITH purchases AS (
    SELECT c.customer_unique_id,
           DATE_TRUNC('month', o.order_purchase_timestamp) AS month
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp <  DATE '2018-09-01'
),
first_month AS (
    SELECT customer_unique_id, MIN(month) AS cohort
    FROM purchases
    GROUP BY customer_unique_id
),
activity AS (
    SELECT DISTINCT f.cohort,
           p.customer_unique_id,
           DATE_DIFF('month', f.cohort, p.month) AS months_since_first
    FROM purchases p
    JOIN first_month f USING (customer_unique_id)
),
cohort_size AS (
    SELECT cohort, COUNT(*) AS customers
    FROM first_month
    GROUP BY cohort
)
SELECT a.cohort,
       s.customers AS cohort_size,
       a.months_since_first,
       COUNT(*) AS returning_customers,
       ROUND(100.0 * COUNT(*) / s.customers, 2) AS retention_pct
FROM activity a
JOIN cohort_size s USING (cohort)
WHERE a.months_since_first BETWEEN 1 AND 6
GROUP BY a.cohort, s.customers, a.months_since_first
ORDER BY a.cohort, a.months_since_first;