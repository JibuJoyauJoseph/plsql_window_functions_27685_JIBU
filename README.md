# SQL JOINs & Window Functions Analytics Project

## Student: Joseph  
Course: Database Development with PL/SQL (INSY 8311)

---

##  Business Problem

A retail electronics company operates across multiple regions and records customer purchases over time. Management lacks analytical insight into product performance, customer behavior, and sales growth trends.

The objective is to transform transactional data into actionable business intelligence using SQL JOINs and Window Functions.

---

## Success Criteria

1. Rank top products per region using RANK()
2. Calculate running sales totals using SUM() OVER()
3. Analyze month-over-month growth using LAG()
4. Segment customers into revenue quartiles using NTILE(4)
5. Compute three-month moving averages using AVG() OVER()

---

##  Database Schema

Tables:

- customers (customer_id, name, region)
- products (product_id, product_name, category, price)
- sales (sale_id, customer_id, product_id, sale_date, quantity, total_amount)

Relationships:
customers 1—∞ sales ∞—1 products

(See ER_diagram.png)

---

##  SQL JOIN Implementations

### INNER JOIN
Retrieves valid transactions with customers and products.

### LEFT JOIN
Identifies customers who have never purchased.

### RIGHT JOIN
Detects products without sales activity.

### FULL OUTER JOIN
Includes matched and unmatched customers and products.

### SELF JOIN
Compares customers within the same region.

(See joins.sql with screenshots)

---

##  Window Functions

### Ranking Functions
RANK(), ROW_NUMBER(), DENSE_RANK() for top products and customers.

### Aggregate Windows
Running totals and moving averages.

### Navigation Functions
Month-to-month sales growth using LAG().

### Distribution Functions
Customer segmentation using NTILE(4).

(See window_functions.sql)

---

##  Results Analysis

### Descriptive
Sales showed consistent growth across months, with electronics dominating revenue.

### Diagnostic
High-performing regions had repeat customers contributing most revenue.

### Prescriptive
Focus marketing on high-value customers, improve engagement in low-performing regions, and optimize product offerings.

---

##  References

- Oracle SQL Window Functions Documentation  
- PostgreSQL Analytical Functions Guide  
- SQLZoo Tutorials  

---

## ✅ Integrity Statement

“All sources were properly cited. Implementations and analysis represent original work. No AI-generated content was copied without attribution or adaptation.”
