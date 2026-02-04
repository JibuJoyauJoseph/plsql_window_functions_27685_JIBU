-- sample_data.sql
-- Insert regions, customers, products and transactions

-- Regions
INSERT INTO regions(region_id, name) VALUES (1, 'North');
INSERT INTO regions(region_id, name) VALUES (2, 'South');
INSERT INTO regions(region_id, name) VALUES (3, 'East');
INSERT INTO regions(region_id, name) VALUES (4, 'West');

-- Customers (include a couple with no transactions)
INSERT INTO customers(customer_id, name, email, region_id) VALUES (101, 'Alice Corp', 'alice@example.com', 1);
INSERT INTO customers(customer_id, name, email, region_id) VALUES (102, 'Beta LLC', 'contact@beta.com', 2);
INSERT INTO customers(customer_id, name, email, region_id) VALUES (103, 'Gamma Inc', 'sales@gamma.com', 3);
INSERT INTO customers(customer_id, name, email, region_id) VALUES (104, 'Delta Co', 'info@delta.com', 1);
INSERT INTO customers(customer_id, name, email, region_id) VALUES (105, 'Epsilon Ltd', 'hello@epsilon.com', 4);
INSERT INTO customers(customer_id, name, email, region_id) VALUES (106, 'NoBuyers Ltd', 'nobuy@example.com', 4); -- no transactions

-- Products (include some with preferred region and some with no sales)
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (201, 'Alpha Widget', 'Widgets', 10.00, 1);
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (202, 'Beta Widget', 'Widgets', 12.50, 2);
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (203, 'Gamma Gadget', 'Gadgets', 25.00, 3);
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (204, 'Delta Gadget', 'Gadgets', 30.00, 1);
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (205, 'Epsilon Thing', 'Thingamajigs', 7.50, 4);
INSERT INTO products(product_id, name, category, unit_price, preferred_region_id) VALUES (206, 'NoSale Item', 'Obsolete', 5.00, 2); -- no sales

-- Transactions across months (to enable MoM and moving averages)
-- Use dates spanning 2025-11 to 2026-01
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1001, DATE '2025-11-05', 101, 201, 5, 10.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1002, DATE '2025-11-12', 102, 202, 3, 12.50);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1003, DATE '2025-11-20', 103, 203, 2, 25.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1004, DATE '2025-12-01', 101, 204, 1, 30.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1005, DATE '2025-12-15', 104, 201, 10, 10.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1006, DATE '2025-12-20', 105, 205, 20, 7.50);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1007, DATE '2026-01-05', 101, 201, 2, 10.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1008, DATE '2026-01-10', 102, 203, 4, 25.00);
INSERT INTO transactions(transaction_id, transaction_date, customer_id, product_id, quantity, unit_price) VALUES (1009, DATE '2026-01-22', 103, 204, 3, 30.00);

COMMIT;
