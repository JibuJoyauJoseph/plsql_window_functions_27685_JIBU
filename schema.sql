-- schema.sql
-- Create schema for sales analytics (Oracle)

-- Regions
CREATE TABLE regions (
  region_id NUMBER PRIMARY KEY,
  name VARCHAR2(50) NOT NULL
);

-- Customers
CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  email VARCHAR2(100),
  region_id NUMBER REFERENCES regions(region_id)
);

-- Products (include preferred_region_id for sample analysis)
CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  category VARCHAR2(50),
  unit_price NUMBER(10,2) NOT NULL,
  preferred_region_id NUMBER REFERENCES regions(region_id)
);

-- Transactions / Sales
CREATE TABLE transactions (
  transaction_id NUMBER PRIMARY KEY,
  transaction_date DATE NOT NULL,
  customer_id NUMBER REFERENCES customers(customer_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER(10) DEFAULT 1,
  unit_price NUMBER(10,2) NOT NULL,
  total_amount NUMBER(12,2) GENERATED ALWAYS AS (quantity * unit_price) VIRTUAL
);

-- Indexes (helpful for queries)
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_customer ON transactions(customer_id);
CREATE INDEX idx_transactions_product ON transactions(product_id);
