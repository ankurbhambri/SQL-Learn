/*

You work for an e-commerce company that tracks customer orders, product inventory, and warehouse shipments. The company wants a report to identify **"high-value customers"** based on their ordering patterns, while also analyzing product stock movement across multiple warehouses. The query needs to handle edge cases like missing data, calculate running totals, and incorporate time-based conditions.

### Tables:
- **customers**
    - `customer_id` (integer, PK)
    - `first_name` (varchar)
    - `last_name` (varchar)
    - `signup_date` (date)

- **orders**
    - `order_id` (integer, PK)
    - `customer_id` (integer, FK to customers)
    - `order_date` (timestamp)
    - `total_amount` (numeric)

- **order_items**
    - `order_item_id` (integer, PK)
    - `order_id` (integer, FK to orders)
    - `product_id` (integer, FK to products)
    - `quantity` (integer)
    - `unit_price` (numeric)

- **products**
    - `product_id` (integer, PK)
    - `product_name` (varchar)
    - `category_id` (integer, FK to categories)
    - `default_price` (numeric)

- **categories**
    - `category_id` (integer, PK)
    - `category_name` (varchar)

- **warehouse_stock**
    - `stock_id` (integer, PK)
    - `product_id` (integer, FK to products)
    - `warehouse_id` (integer, FK to warehouses)
    - `quantity` (integer)
    - `last_updated` (timestamp)

- **warehouses**
    - `warehouse_id` (integer, PK)
    - `warehouse_name` (varchar)
    - `region` (varchar)


### Requirements:
Write a PostgreSQL query that:

1. Identifies the **top 5 customers** who have spent the most money in the last 6 months (from **April 05, 2025**).
2. For each of these customers, calculate:
     - Their **total spending**.
     - The **percentage of their orders** that contain products from the **"Electronics"** category.
     - A **running total** of their order amounts over time (ordered by `order_date`).
3. For each customer's **most frequently ordered product**:
     - Show the **total stock available** across all warehouses.
     - Calculate the **average stock level per warehouse** for that product.
     - Flag if the **total stock is below 50 units**.
4. Include only customers who:
     - Signed up **more than 1 year ago** (before **April 05, 2024**).
     - Have placed **at least 3 orders** in the last 6 months.
5. Handle cases where:
     - Some orders might **not have order items** (due to data issues).
     - Stock data might be **missing for certain products**.


### Expected Output Columns:
- `customer_id`
- `customer_name` (concatenated `first_name` and `last_name`)
- `total_spent` (sum of order totals)
- `electronics_percentage` (percentage of orders with Electronics products)
- `most_ordered_product` (product name)
- `total_stock` (sum of stock across warehouses)
- `avg_stock_per_warehouse` (average stock per warehouse)
- `low_stock_flag` (boolean: true if total stock < 50)
- `running_total_spent` (running total of order amounts)


### Notes:
- The query should handle edge cases like missing data in `order_items` or `warehouse_stock`.
- Use the provided sample data to test the query.
 
*/

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
        SUM(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS running_total_spent
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
        ROW_NUMBER() OVER (PARTITION BY co.customer_id ORDER BY COUNT(oi.order_item_id) DESC) AS rn

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
SELECT * FROM top_customers;
