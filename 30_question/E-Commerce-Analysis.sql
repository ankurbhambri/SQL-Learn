/*
You work for an e-commerce company that tracks customer orders, product inventory, and warehouse shipments. The company wants a report to identify "high-value customers" based on their ordering patterns, while also analyzing product stock movement across multiple warehouses. The query needs to handle edge cases like missing data, calculate running totals, and incorporate time-based conditions.

Tables:
customers
customer_id (integer, PK)
first_name (varchar)
last_name (varchar)
signup_date (date)
orders
order_id (integer, PK)
customer_id (integer, FK to customers)
order_date (timestamp)
total_amount (numeric)
order_items
order_item_id (integer, PK)
order_id (integer, FK to orders)
product_id (integer, FK to products)
quantity (integer)
unit_price (numeric)
products
product_id (integer, PK)
product_name (varchar)
category_id (integer, FK to categories)
default_price (numeric)
categories
category_id (integer, PK)
category_name (varchar)
warehouse_stock
stock_id (integer, PK)
product_id (integer, FK to products)
warehouse_id (integer, FK to warehouses)
quantity (integer)
last_updated (timestamp)
warehouses
warehouse_id (integer, PK)
warehouse_name (varchar)
region (varchar)
Requirements:
Write a PostgreSQL query that:

Identifies the top 5 customers who have spent the most money in the last 6 months (from April 05, 2025).
For each of these customers, calculate:
Their total spending.
The percentage of their orders that contain products from the "Electronics" category.
A running total of their order amounts over time (ordered by order_date).
For each customer's most frequently ordered product:
Show the total stock available across all warehouses.
Calculate the average stock level per warehouse for that product.
Flag if the total stock is below 50 units.
Include only customers who:
Signed up more than 1 year ago (before April 05, 2024).
Have placed at least 3 orders in the last 6 months.
Handle cases where:
Some orders might not have order items (due to data issues).
Stock data might be missing for certain products.
Expected Output Columns:
customer_id
customer_name (concatenated first_name and last_name)
total_spent (sum of order totals)
electronics_percentage (percentage of orders with Electronics products)
most_ordered_product (product name)
total_stock (sum of stock across warehouses)
avg_stock_per_warehouse (average stock per warehouse)
low_stock_flag (boolean: true if total stock < 50)
running_total_spent (running total of order amounts)


-- Insert into categories
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books');

-- Insert into products
INSERT INTO products (product_id, product_name, category_id, default_price) VALUES
(1, 'Smartphone', 1, 599.99),
(2, 'Laptop', 1, 1299.99),
(3, 'T-Shirt', 2, 19.99),
(4, 'Novel', 3, 14.99),
(5, 'Headphones', 1, 89.99);

-- Insert into warehouses
INSERT INTO warehouses (warehouse_id, warehouse_name, region) VALUES
(1, 'North Warehouse', 'North'),
(2, 'South Warehouse', 'South'),
(3, 'East Warehouse', 'East');

-- Insert into customers
INSERT INTO customers (customer_id, first_name, last_name, signup_date) VALUES
(1, 'John', 'Doe', '2023-01-15'),  -- Signed up > 1 year ago
(2, 'Jane', 'Smith', '2023-03-10'), -- Signed up > 1 year ago
(3, 'Alice', 'Johnson', '2023-06-20'), -- Signed up > 1 year ago
(4, 'Bob', 'Brown', '2023-09-01'), -- Signed up > 1 year ago
(5, 'Charlie', 'Davis', '2023-11-15'), -- Signed up > 1 year ago
(6, 'Eve', 'Wilson', '2024-05-01'); -- Signed up < 1 year ago (excluded)

-- Insert into orders (within last 6 months: Oct 05, 2024 - Apr 05, 2025)
INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(1, 1, '2024-10-10 10:00:00', 619.98), -- John: Smartphone + T-Shirt
(2, 1, '2024-11-15 14:30:00', 1299.99), -- John: Laptop
(3, 1, '2024-12-20 09:15:00', 89.99), -- John: Headphones
(4, 2, '2024-10-25 12:00:00', 134.97), -- Jane: 3 Novels
(5, 2, '2024-11-30 16:45:00', 599.99), -- Jane: Smartphone
(6, 2, '2024-12-05 11:20:00', 19.99), -- Jane: T-Shirt
(7, 3, '2024-10-15 08:30:00', 1299.99), -- Alice: Laptop
(8, 3, '2024-11-10 13:00:00', 89.99), -- Alice: Headphones
(9, 3, '2024-12-25 15:00:00', 599.99), -- Alice: Smartphone
(10, 4, '2024-10-20 09:00:00', 19.99), -- Bob: T-Shirt
(11, 4, '2024-11-25 10:30:00', 14.99), -- Bob: Novel
(12, 4, '2024-12-15 14:00:00', 89.99), -- Bob: Headphones
(13, 5, '2024-10-30 11:00:00', 599.99), -- Charlie: Smartphone
(14, 5, '2024-11-20 12:00:00', 1299.99), -- Charlie: Laptop
(15, 5, '2024-12-10 13:00:00', 89.99); -- Charlie: Headphones

-- Insert into order_items
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 599.99), -- Smartphone
(2, 1, 3, 1, 19.99), -- T-Shirt
(3, 2, 2, 1, 1299.99), -- Laptop
(4, 3, 5, 1, 89.99), -- Headphones
(5, 4, 4, 3, 14.99), -- 3 Novels
(6, 5, 1, 1, 599.99), -- Smartphone
(7, 6, 3, 1, 19.99), -- T-Shirt
(8, 7, 2, 1, 1299.99), -- Laptop
(9, 8, 5, 1, 89.99), -- Headphones
(10, 9, 1, 1, 599.99), -- Smartphone
(11, 10, 3, 1, 19.99), -- T-Shirt
(12, 11, 4, 1, 14.99), -- Novel
(13, 12, 5, 1, 89.99), -- Headphones
(14, 13, 1, 1, 599.99), -- Smartphone
(15, 14, 2, 1, 1299.99), -- Laptop
(16, 15, 5, 1, 89.99); -- Headphones

-- Insert into warehouse_stock
INSERT INTO warehouse_stock (stock_id, product_id, warehouse_id, quantity, last_updated) VALUES
(1, 1, 1, 20, '2025-04-01 10:00:00'), -- Smartphone: North
(2, 1, 2, 15, '2025-04-02 12:00:00'), -- Smartphone: South
(3, 1, 3, 10, '2025-04-03 14:00:00'), -- Smartphone: East (Total: 45, < 50)
(4, 2, 1, 30, '2025-04-01 10:00:00'), -- Laptop: North
(5, 2, 2, 25, '2025-04-02 12:00:00'), -- Laptop: South
(6, 2, 3, 20, '2025-04-03 14:00:00'), -- Laptop: East (Total: 75)
(7, 3, 1, 50, '2025-04-01 10:00:00'), -- T-Shirt: North
(8, 3, 2, 40, '2025-04-02 12:00:00'), -- T-Shirt: South
(9, 3, 3, 30, '2025-04-03 14:00:00'), -- T-Shirt: East (Total: 120)
(10, 4, 1, 100, '2025-04-01 10:00:00'), -- Novel: North
(11, 4, 2, 80, '2025-04-02 12:00:00'), -- Novel: South
(12, 4, 3, 60, '2025-04-03 14:00:00'), -- Novel: East (Total: 240)
(13, 5, 1, 15, '2025-04-01 10:00:00'), -- Headphones: North
(14, 5, 2, 10, '2025-04-02 12:00:00'), -- Headphones: South
(15, 5, 3, 5, '2025-04-03 14:00:00'); -- Headphones: East (Total: 30, < 50)

/*

WITH filtered_customers AS (
    -- Step 1: Filter customers who signed up > 1 year ago and have 3+ orders in last 6 months
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o 
        ON c.customer_id = o.customer_id 
        AND o.order_date >= '2024-10-05'  -- 6 months before April 05, 2025
        AND o.order_date <= '2025-04-05'
    WHERE c.signup_date < '2024-04-05'  -- Signed up > 1 year ago
    GROUP BY c.customer_id, c.first_name, c.last_name
    HAVING COUNT(o.order_id) >= 3
),

customer_orders AS (
    -- Step 2: Calculate total spent and running total for qualifying customers
    SELECT 
        o.customer_id,
        SUM(o.total_amount) AS total_spent,
        SUM(o.total_amount) OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_date
        ) AS running_total_spent
    FROM orders o
    JOIN filtered_customers fc ON o.customer_id = fc.customer_id
    WHERE o.order_date >= '2024-10-05' 
    AND o.order_date <= '2025-04-05'
    GROUP BY o.customer_id, o.order_id, o.order_date
),

electronics_orders AS (
    -- Step 3: Calculate percentage of orders with Electronics products
    SELECT 
        co.customer_id,
        COUNT(DISTINCT CASE 
            WHEN cat.category_name = 'Electronics' THEN o.order_id 
            ELSE NULL 
        END)::float / COUNT(DISTINCT o.order_id) * 100 AS electronics_percentage
    FROM customer_orders co
    JOIN orders o ON co.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN categories cat ON p.category_id = cat.category_id
    WHERE o.order_date >= '2024-10-05' 
    AND o.order_date <= '2025-04-05'
    GROUP BY co.customer_id
),

most_ordered_products AS (
    -- Step 4: Identify most frequently ordered product per customer
    SELECT 
        co.customer_id,
        p.product_name AS most_ordered_product,
        p.product_id,
        COUNT(oi.order_item_id) AS order_count,
        ROW_NUMBER() OVER (
            PARTITION BY co.customer_id 
            ORDER BY COUNT(oi.order_item_id) DESC
        ) AS rn
    FROM customer_orders co
    JOIN orders o ON co.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_date >= '2024-10-05' 
    AND o.order_date <= '2025-04-05'
    GROUP BY co.customer_id, p.product_id, p.product_name
),

stock_analysis AS (
    -- Step 5: Calculate stock metrics for most ordered products
    SELECT 
        mop.customer_id,
        mop.most_ordered_product,
        SUM(ws.quantity) AS total_stock,
        AVG(ws.quantity)::numeric(10,2) AS avg_stock_per_warehouse,
        CASE WHEN SUM(ws.quantity) < 50 THEN true ELSE false END AS low_stock_flag
    FROM most_ordered_products mop
    LEFT JOIN warehouse_stock ws ON mop.product_id = ws.product_id
    WHERE mop.rn = 1  -- Only take the top product per customer
    GROUP BY mop.customer_id, mop.most_ordered_product
),

top_customers AS (
    -- Step 6: Combine all metrics and limit to top 5 customers by total spent
    SELECT 
        co.customer_id,
        fc.customer_name,
        co.total_spent,
        eo.electronics_percentage,
        sa.most_ordered_product,
        sa.total_stock,
        sa.avg_stock_per_warehouse,
        sa.low_stock_flag,
        co.running_total_spent
    FROM customer_orders co
    JOIN filtered_customers fc ON co.customer_id = fc.customer_id
    JOIN electronics_orders eo ON co.customer_id = eo.customer_id
    JOIN stock_analysis sa ON co.customer_id = sa.customer_id
    ORDER BY co.total_spent DESC
    LIMIT 5
)

-- Final result
SELECT * FROM top_customers;
