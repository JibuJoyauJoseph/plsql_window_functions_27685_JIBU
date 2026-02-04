
-- Demonstrate JOIN types with comments and short business interpretations

SET PAGESIZE 200
COLUMN transaction_date FORMAT A12

-- 1) INNER JOIN: Retrieve transactions with valid customers and products
-- Returns only transactions that have matching customer and product records.

-- INNER JOIN: valid transactions with customer and product
SELECT t.transaction_id,
       t.transaction_date,
       c.customer_id, c.name AS customer_name,
       p.product_id, p.name AS product_name,
       t.quantity, t.unit_price, t.total_amount
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id
ORDER BY t.transaction_date;

-- Business interpretation:
-- Inner join confirms which sales map to known customers and catalog products. Useful for validating data integrity.

-- 2) LEFT JOIN: Identify customers who have never made a transaction
 -- LEFT JOIN: customers without transactions
SELECT c.customer_id, c.name, c.email, r.name AS region
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
LEFT JOIN regions r ON c.region_id = r.region_id
WHERE t.transaction_id IS NULL;

-- Business interpretation:
-- Identifies inactive or new customers for targeted re-engagement campaigns.

-- 3) FULL OUTER JOIN (used to detect products with no sales activity
 -- FULL OUTER JOIN: products and transactions -> find products with no sales
SELECT p.product_id, p.name AS product_name, t.transaction_id, t.transaction_date
FROM products p
FULL OUTER JOIN transactions t ON p.product_id = t.product_id
WHERE t.transaction_id IS NULL OR p.product_id IS NULL
ORDER BY p.product_id NULLS LAST;

-- Business interpretation:
-- Rows where t.transaction_id IS NULL show products with no matching sales — candidates for promos or delisting.

-- 4) FULL OUTER JOIN: Compare customers and products by preferred region (includes unmatched)
 -- FULL OUTER JOIN: customers vs products by region
SELECT c.customer_id, c.name AS customer_name, c.region_id AS customer_region,
       p.product_id, p.name AS product_name, p.preferred_region_id
FROM customers c
FULL OUTER JOIN products p ON c.region_id = p.preferred_region_id
ORDER BY NVL(c.region_id, p.preferred_region_id), c.customer_id;

-- Business interpretation:
-- Shows which products are targeted to regions with matching customers and highlights products or customer regions that lack matches.

-- 5) SELF JOIN: Compare customers in same region (pairwise)
 -- SELF JOIN: customers in the same region (pairs)
SELECT c1.customer_id AS cust1_id, c1.name AS cust1_name, c2.customer_id AS cust2_id, c2.name AS cust2_name, r.name AS region
FROM customers c1
JOIN customers c2 ON c1.region_id = c2.region_id AND c1.customer_id < c2.customer_id
LEFT JOIN regions r ON c1.region_id = r.region_id
ORDER BY r.name, c1.customer_id;

-- Business interpretation:
-- Helps identify nearby customers for regional bundling or joint promotions.
