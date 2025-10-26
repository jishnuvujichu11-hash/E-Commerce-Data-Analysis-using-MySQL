USE ecommerce_db;

-- 1. List all products in a specific category
SELECT product_id, product_category_name
FROM products
WHERE product_category_name = 'bebes';

-- 2. Top 10 selling products by total sales
SELECT oi.product_id, p.product_category_name, SUM(oi.price) AS total_sales
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;

-- 3. Total sales per product category
SELECT p.product_category_name, SUM(oi.price) AS total_sales
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC;

-- 4. Number of times each product sold per category
SELECT p.product_category_name, COUNT(*) AS total_sold
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sold DESC;

-- 5. Average price per product
SELECT oi.product_id, p.product_category_name, AVG(oi.price) AS avg_price
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name
ORDER BY avg_price DESC
LIMIT 10;

-- 6. Products with price above 500
SELECT oi.product_id, p.product_category_name, oi.price
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.price > 500
ORDER BY oi.price DESC
LIMIT 20;

-- 7. Subquery: Products with total sales above average
SELECT product_id, total_sales
FROM (
    SELECT oi.product_id, SUM(oi.price) AS total_sales
    FROM order_items_ oi
    GROUP BY oi.product_id
) AS sub
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM (
        SELECT SUM(price) AS total_sales
        FROM order_items_
        GROUP BY product_id
    ) AS avg_sub
)
ORDER BY total_sales DESC;

-- 8. Create a view for top-selling products
CREATE OR REPLACE VIEW top_products AS
SELECT oi.product_id, p.product_category_name, COUNT(*) AS total_sold
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name;

-- Query the view
SELECT * FROM top_products
ORDER BY total_sold DESC
LIMIT 10;

-- 9. Index on product_id to optimize joins (prefix required for TEXT)
CREATE INDEX idx_product_id ON order_items_(product_id(20));

-- 10. Count of products per category
SELECT product_category_name, COUNT(product_id) AS total_products
FROM products
GROUP BY product_category_name
ORDER BY total_products DESC;

-- 11. Total revenue per product category
SELECT p.product_category_name, SUM(oi.price) AS revenue
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

-- 12. Top 5 most expensive products
SELECT oi.product_id, p.product_category_name, oi.price
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.price DESC
LIMIT 5;

-- 13. Top 5 cheapest products
SELECT oi.product_id, p.product_category_name, oi.price
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.price ASC
LIMIT 5;

-- 14. Total sales and count per product
SELECT oi.product_id, p.product_category_name, SUM(oi.price) AS total_sales, COUNT(*) AS total_sold
FROM order_items_ oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name
ORDER BY total_sales DESC
LIMIT 20;

-- 15. Top-selling product per category using ranking 
SELECT product_category_name, product_id, total_sold
FROM (
    SELECT p.product_category_name, oi.product_id, COUNT(*) AS total_sold,
           RANK() OVER (PARTITION BY p.product_category_name ORDER BY COUNT(*) DESC) AS rank_no
    FROM order_items_ oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name, oi.product_id
) AS ranked
WHERE rank_no = 1
ORDER BY product_category_name;
