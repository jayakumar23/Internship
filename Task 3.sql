create database intenship;
use intenship;

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);








INSERT INTO customers (id, name, email) VALUES
(1, 'Alice Smith', 'alice@example.com'),
(2, 'Bob Johnson', 'bob@example.com'),
(3, 'Charlie Lee', 'charlie@example.com');

INSERT INTO products (id, product_name, category, price) VALUES
(1, 'Laptop', 'Electronics', 900.00),
(2, 'Smartphone', 'Electronics', 500.00),
(3, 'Book', 'Books', 20.00),
(4, 'T-shirt', 'Clothing', 15.00),
(5, 'Headphones', 'Electronics', 80.00);


INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(1, 1, '2025-05-01', 920.00),
(2, 2, '2025-05-03', 520.00),
(3, 1, '2025-05-10', 35.00),
(4, 3, '2025-05-12', 95.00);


INSERT INTO order_items (id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),   -- Alice bought 1 Laptop
(2, 1, 3, 1),   -- Alice bought 1 Book
(3, 2, 2, 1),   -- Bob bought 1 Smartphone
(4, 2, 3, 1),   -- Bob bought 1 Book
(5, 3, 4, 2),   -- Alice bought 2 T-shirts
(6, 4, 5, 1),   -- Charlie bought 1 Headphones
(7, 4, 4, 1);   -- Charlie bought 1 T-shirt



SELECT product_name, price, category 
FROM products 
WHERE price > 50 
ORDER BY category ASC;


SELECT category, SUM(price * quantity) AS total_sales
FROM order_items
JOIN products ON order_items.product_id = products.id
GROUP BY category;

SELECT orders.id, customers.name, orders.order_date 
FROM orders 
INNER JOIN customers ON orders.customer_id = customers.id;

SELECT customers.name, COUNT(orders.id) AS order_count 
FROM customers 
LEFT JOIN orders ON customers.id = orders.customer_id 
GROUP BY customers.name;

SELECT products.product_name, COALESCE(SUM(order_items.quantity), 0) AS total_ordered
FROM order_items
RIGHT JOIN products ON order_items.product_id = products.id
GROUP BY products.product_name
LIMIT 0, 2000;

SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (
    SELECT AVG(total_amount) 
    FROM orders
);

SELECT 
    EXTRACT(MONTH FROM order_date) AS month,
    AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY month
ORDER BY month;

CREATE VIEW monthly_sales AS
SELECT 
    EXTRACT(YEAR_MONTH FROM order_date) AS sales_month,
    SUM(total_amount) AS total_sales,
    COUNT(*) AS order_count
FROM orders
GROUP BY sales_month;

CREATE VIEW customer_orders AS
SELECT 
    c.name,
    o.order_date,
    o.total_amount,
    p.product_name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

EXPLAIN SELECT * FROM products WHERE category = 'Electronics';

SELECT 
    c.id,
    c.name,
    SUM(o.total_amount) AS lifetime_value,
    COUNT(o.id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY lifetime_value DESC;

SELECT 
    product_id,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    SUM(quantity) AS units_sold,
    LAG(SUM(quantity)) OVER (PARTITION BY product_id ORDER BY EXTRACT(QUARTER FROM order_date)) AS prev_quarter_sales
FROM order_items
JOIN orders ON order_items.order_id = orders.id
GROUP BY product_id, quarter;


DELIMITER $$

CREATE PROCEDURE ecommerce_analysis()
BEGIN

    -- 1. Products with price > $50, sorted by category
    SELECT product_name, price, category 
    FROM products 
    WHERE price > 50 
    ORDER BY category ASC;

    -- 2. Total sales by product category
    SELECT category, SUM(price * quantity) AS total_sales
    FROM order_items
    JOIN products ON order_items.product_id = products.id
    GROUP BY category;

    -- 3. Orders with customer details (Inner Join)
    SELECT orders.id, customers.name, orders.order_date 
    FROM orders 
    INNER JOIN customers ON orders.customer_id = customers.id;

    -- 4. All customers with order count (Left Join)
    SELECT customers.name, COUNT(orders.id) AS order_count 
    FROM customers 
    LEFT JOIN orders ON customers.id = orders.customer_id 
    GROUP BY customers.name;

    -- 5. Products with order quantities (Right Join)
    SELECT products.product_name, COALESCE(SUM(order_items.quantity), 0) AS total_ordered 
    FROM order_items
    RIGHT JOIN products ON order_items.product_id = products.id 
    GROUP BY products.product_name;

    -- 6. Customers with above-average spending (Subquery)
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > (
        SELECT AVG(total_amount) FROM orders
    );

    -- 7. Average order value by month
    SELECT 
        MONTH(order_date) AS month,
        AVG(total_amount) AS avg_order_value
    FROM orders
    GROUP BY month
    ORDER BY month;

    -- 8. Customer lifetime value
    SELECT 
        c.id,
        c.name,
        SUM(o.total_amount) AS lifetime_value,
        COUNT(o.id) AS total_orders
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id
    GROUP BY c.id, c.name
    ORDER BY lifetime_value DESC;

END$$

DELIMITER ;

CALL ecommerce_analysis();


