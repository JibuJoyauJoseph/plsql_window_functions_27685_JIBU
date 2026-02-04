-- part_b_window_functions.sql
-- Implements the five measurable goals using Oracle analytic/window functions

SET PAGESIZE 200

-- Prep: monthly sales per product per region
WITH monthly_sales AS (
  SELECT
    p.product_id,
    p.name AS product_name,
    p.preferred_region_id,
    r.name AS region_name,
    TRUNC(t.transaction_date, 'MM') AS month_start,
    SUM(t.quantity * t.unit_price) AS product_month_sales
  FROM transactions t
  JOIN products p ON t.product_id = p.product_id
  LEFT JOIN regions r ON p.preferred_region_id = r.region_id
  GROUP BY p.product_id, p.name, p.preferred_region_id, r.name, TRUNC(t.transaction_date, 'MM')
)

-- 1) Top 5 products per region or quarter → RANK()
PROMPT -- Top products per region (RANK)
SELECT * FROM (
  SELECT region_name, product_id, product_name, month_start, product_month_sales,
         RANK() OVER (PARTITION BY region_name ORDER BY product_month_sales DESC) AS sales_rank
  FROM monthly_sales
)
WHERE sales_rank <= 5
ORDER BY region_name, sales_rank;

-- Business interpretation:
-- RANK() highlights top-performing SKUs per region; ties get same rank.

-- 2) Running monthly sales totals → SUM() OVER()
PROMPT -- Running monthly total sales (cumulative)
WITH monthly_total AS (
  SELECT TRUNC(transaction_date,'MM') AS month_start, SUM(quantity * unit_price) AS month_sales
  FROM transactions
  GROUP BY TRUNC(transaction_date,'MM')
)
SELECT month_start,
       month_sales,
       SUM(month_sales) OVER (ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM monthly_total
ORDER BY month_start;

-- Business interpretation:
-- Running totals show cumulative revenue across months to track progress toward targets.

-- 3) Month-over-month growth → LAG()
PROMPT -- Month-over-month growth using LAG
WITH monthly_total AS (
  SELECT TRUNC(transaction_date,'MM') AS month_start, SUM(quantity * unit_price) AS month_sales
  FROM transactions
  GROUP BY TRUNC(transaction_date,'MM')
)
SELECT month_start,
       month_sales,
       LAG(month_sales) OVER (ORDER BY month_start) AS prev_month_sales,
       CASE WHEN LAG(month_sales) OVER (ORDER BY month_start) IS NULL THEN NULL
            WHEN LAG(month_sales) OVER (ORDER BY month_start) = 0 THEN NULL
            ELSE ROUND((month_sales - LAG(month_sales) OVER (ORDER BY month_start)) / LAG(month_sales) OVER (ORDER BY month_start) * 100, 2)
       END AS mom_pct_change
FROM monthly_total
ORDER BY month_start;

-- Business interpretation:
-- LAG() lets analysts see percent growth/decline month-over-month for trend detection.

-- 4) Customer quartile segmentation → NTILE(4)
PROMPT -- Customer segmentation by total spend (quartiles)
WITH customer_spend AS (
  SELECT c.customer_id, c.name, NVL(SUM(t.quantity * t.unit_price),0) AS total_spent
  FROM customers c
  LEFT JOIN transactions t ON c.customer_id = t.customer_id
  GROUP BY c.customer_id, c.name
)
SELECT customer_id, name, total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_quartile
FROM customer_spend
ORDER BY spend_quartile, total_spent DESC;

-- Business interpretation:
-- NTILE(4) segments customers into quartiles for tiered marketing strategies.

-- 5) Three-month moving averages → AVG() OVER()
PROMPT -- Three-month moving average of monthly sales
WITH monthly_total AS (
  SELECT TRUNC(transaction_date,'MM') AS month_start, SUM(quantity * unit_price) AS month_sales
  FROM transactions
  GROUP BY TRUNC(transaction_date,'MM')
)
SELECT month_start,
       month_sales,
       ROUND(AVG(month_sales) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS three_month_moving_avg
FROM monthly_total
ORDER BY month_start;

-- Business interpretation:
-- 3-month moving averages smooth volatility and help detect underlying trends.

--------------------------------------------------------------------------------
-- Additional window-function demonstrations (all required categories)
--------------------------------------------------------------------------------

-- Ranking Functions: ROW_NUMBER(), RANK(), DENSE_RANK(), PERCENT_RANK()
PROMPT -- Ranking functions: top customers by total revenue (global and by region)
WITH customer_revenue AS (
  SELECT c.customer_id, c.name AS customer_name, r.name AS region_name,
         NVL(SUM(t.quantity * t.unit_price),0) AS total_spent
  FROM customers c
  LEFT JOIN transactions t ON c.customer_id = t.customer_id
  LEFT JOIN regions r ON c.region_id = r.region_id
  GROUP BY c.customer_id, c.name, r.name
)
SELECT customer_id, customer_name, region_name, total_spent,
       ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS rn_global,
       RANK() OVER (ORDER BY total_spent DESC) AS rnk_global,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS dense_rnk_global,
       PERCENT_RANK() OVER (ORDER BY total_spent DESC) AS pct_rank_global
FROM customer_revenue
ORDER BY total_spent DESC;

-- Interpretation:
-- ROW_NUMBER() gives a strict ordering (useful for Top-N selection), RANK() leaves gaps on ties,
-- DENSE_RANK() compresses tied ranks, and PERCENT_RANK() shows relative standing in [0,1].

-- Aggregate Window Functions using ROWS and RANGE frames
PROMPT -- Aggregate window functions: SUM(), AVG(), MIN(), MAX() with ROWS and RANGE frames
WITH monthly_total AS (
  SELECT TRUNC(transaction_date,'MM') AS month_start, SUM(quantity * unit_price) AS month_sales
  FROM transactions
  GROUP BY TRUNC(transaction_date,'MM')
)
SELECT month_start,
       month_sales,
       -- Running total using ROWS frame (unbounded preceding to current row)
       SUM(month_sales) OVER (ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_rows,
       -- 3-period moving average using ROWS frame (2 preceding to current)
       AVG(month_sales) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_3row,
       -- Running total using RANGE frame (date-based). RANGE treats peers with same ORDER value together.
       SUM(month_sales) OVER (ORDER BY month_start RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_range,
       MIN(month_sales) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS min_3row,
       MAX(month_sales) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS max_3row
FROM monthly_total
ORDER BY month_start;

-- Interpretation:
-- ROWS frames operate on physical row counts (e.g., 2 previous rows). RANGE frames consider value-based peers (same month_start).

-- Navigation Functions: LAG(), LEAD()
PROMPT -- Navigation functions: LAG and LEAD for month-over-month comparison
WITH monthly_total AS (
  SELECT TRUNC(transaction_date,'MM') AS month_start, SUM(quantity * unit_price) AS month_sales
  FROM transactions
  GROUP BY TRUNC(transaction_date,'MM')
)
SELECT month_start,
       month_sales,
       LAG(month_sales,1,0) OVER (ORDER BY month_start) AS prev_month_sales,
       LEAD(month_sales,1,0) OVER (ORDER BY month_start) AS next_month_sales,
       -- simple growth and forward-looking delta
       month_sales - LAG(month_sales,1,0) OVER (ORDER BY month_start) AS delta_from_prev,
       LEAD(month_sales,1,0) OVER (ORDER BY month_start) - month_sales AS delta_to_next
FROM monthly_total
ORDER BY month_start;

-- Interpretation:
-- LAG and LEAD allow period-to-period comparisons (previous and next) to compute growth or predict short-term changes.

-- Distribution Functions: NTILE(4), CUME_DIST()
PROMPT -- Distribution functions: NTILE and CUME_DIST for customer segmentation
WITH customer_spend AS (
  SELECT c.customer_id, c.name, NVL(SUM(t.quantity * t.unit_price),0) AS total_spent
  FROM customers c
  LEFT JOIN transactions t ON c.customer_id = t.customer_id
  GROUP BY c.customer_id, c.name
)
SELECT customer_id, name, total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) AS quartile_desc,
       CUME_DIST() OVER (ORDER BY total_spent DESC) AS cume_dist_desc
FROM customer_spend
ORDER BY total_spent DESC;

-- Interpretation:
-- NTILE(4) segments customers into quartiles for targeted campaigns. CUME_DIST() shows the cumulative proportion of customers
-- at or below a given spend level and helps identify thresholds for loyalty tiers.
