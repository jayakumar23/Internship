CREATE TABLE online_sales (
    order_id    INTEGER PRIMARY KEY,
    order_date  DATE NOT NULL,
    amount      DECIMAL(10, 2) NOT NULL,
    product_id  INTEGER NOT NULL
);

INSERT INTO online_sales (order_id, order_date, amount, product_id) VALUES
(1, '2023-01-15', 120.00, 10),
(2, '2023-01-17', 450.50, 11),
(3, '2023-01-30', 320.10, 10),
(4, '2023-02-05', 220.40, 12),
(5, '2023-02-12', 310.00, 13),
(6, '2023-02-18', 540.90, 11),
(7, '2023-02-28', 123.45, 12),
(8, '2023-03-02', 230.00, 10),
(9, '2023-03-18', 440.20, 14),
(10, '2023-03-22', 350.10, 13),
(11, '2023-03-30', 400.00, 12),
(12, '2023-04-01', 215.50, 11),
(13, '2023-04-10', 318.80, 14),
(14, '2023-04-15', 530.40, 10),
(15, '2023-04-29', 250.00, 15),
(16, '2023-05-02', 600.00, 11),
(17, '2023-05-12', 320.00, 13),
(18, '2023-05-20', 420.00, 14);

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM
    online_sales
WHERE
    order_date >= '2023-01-01' AND order_date < '2024-01-01'
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    year, month;