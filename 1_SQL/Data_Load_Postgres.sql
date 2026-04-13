-- =====================================================================
-- BRAZILIAN OLIST E-COMMERCE DATABASE SETUP SCRIPT (POSTGRESQL VERSION)
-- =====================================================================

-- Create database (run separately if needed)
-- CREATE DATABASE ecommerce;

-- Connect to database
-- \c ecommerce;

-- ======================================================
-- PART 1: CREATE TABLES
-- ======================================================

DROP TABLE IF EXISTS olist_order_reviews CASCADE;
DROP TABLE IF EXISTS olist_order_payments CASCADE;
DROP TABLE IF EXISTS olist_order_items CASCADE;
DROP TABLE IF EXISTS olist_orders CASCADE;
DROP TABLE IF EXISTS olist_products CASCADE;
DROP TABLE IF EXISTS olist_sellers CASCADE;
DROP TABLE IF EXISTS olist_customers CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;
DROP TABLE IF EXISTS olist_geolocation CASCADE;
DROP TABLE IF EXISTS geolocation_clean CASCADE;

CREATE TABLE olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES olist_customers(customer_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE olist_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE olist_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(255) PRIMARY KEY,
    product_category_name_english VARCHAR(255)
);

CREATE TABLE olist_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES olist_products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES olist_sellers(seller_id) ON DELETE SET NULL
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id) ON DELETE CASCADE
);

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id) ON DELETE SET NULL
);

CREATE TABLE olist_geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

CREATE TABLE geolocation_clean (
    geolocation_zip_code_prefix VARCHAR(10) PRIMARY KEY,
    city_lat DECIMAL(10,8),
    city_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

-- ======================================================
-- PART 2: LOAD DATA (USE \copy IN psql)
-- ======================================================

-- Example:
-- \copy olist_order_payments FROM 'D:/Downloads/Team Project/Dataset/Data/product_category_name_translation.csv' CSV HEADER;
-- \copy geolocation_clean FROM 'D:/Downloads/Team Project/Dataset/Data/olist_geolocation_dataset.csv' CSV HEADER;
-- Repeat for all tables

-- ======================================================
-- PART 3: CLEAN GEOLOCATION DATA
-- ======================================================

INSERT INTO geolocation_clean
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat),
    AVG(geolocation_lng),
    MAX(geolocation_city),
    MAX(geolocation_state)
FROM olist_geolocation
GROUP BY geolocation_zip_code_prefix
ON CONFLICT (geolocation_zip_code_prefix)
DO UPDATE SET
    city_lat = EXCLUDED.city_lat,
    city_lng = EXCLUDED.city_lng,
    geolocation_city = EXCLUDED.geolocation_city,
    geolocation_state = EXCLUDED.geolocation_state;

-- ======================================================
-- PART 4: VIEWS
-- ======================================================

CREATE OR REPLACE VIEW v_master_products_sellers AS
SELECT 
    oi.order_id,
    o.order_purchase_timestamp,
    oi.product_id,
    p.product_category_name AS category_br,
    pt.product_category_name_english AS category_en,
    s.seller_id,
    s.seller_city,
    s.seller_state,
    g.city_lat AS seller_lat,
    g.city_lng AS seller_lng,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_cost
FROM olist_order_items oi
LEFT JOIN olist_orders o ON oi.order_id = o.order_id
LEFT JOIN olist_products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt 
    ON p.product_category_name = pt.product_category_name
LEFT JOIN olist_sellers s ON oi.seller_id = s.seller_id
LEFT JOIN geolocation_clean g ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;

CREATE OR REPLACE VIEW v_final_project_summary AS
SELECT 
    o.order_id,
    c.customer_city,
    c.customer_state,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    p.payment_type,
    p.payment_value AS revenue,
    r.review_score,
    o.order_status
FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
LEFT JOIN olist_order_payments p ON o.order_id = p.order_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered';

CREATE OR REPLACE VIEW v_revenue_per_year AS
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS sales_year,
    ROUND(SUM(total_item_cost), 2) AS total_revenue
FROM v_master_products_sellers
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY sales_year
ORDER BY sales_year;

CREATE OR REPLACE VIEW v_top_categories_per_year AS
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS sales_year,
    category_en,
    COUNT(*) AS units_sold
FROM v_master_products_sellers
WHERE order_purchase_timestamp IS NOT NULL 
  AND category_en IS NOT NULL
GROUP BY sales_year, category_en
ORDER BY sales_year DESC, units_sold DESC;

CREATE OR REPLACE VIEW v_product_pricing_strategy AS
SELECT 
    category_en,
    COUNT(*) AS units_sold,
    ROUND(AVG(price), 2) AS avg_unit_price,
    ROUND(SUM(price), 2) AS total_category_revenue
FROM v_master_products_sellers
WHERE category_en IS NOT NULL
GROUP BY category_en
ORDER BY avg_unit_price DESC;

CREATE OR REPLACE VIEW v_geo_seller_density AS
SELECT 
    seller_state,
    COUNT(DISTINCT seller_id) AS total_sellers,
    ROUND(SUM(price), 2) AS state_revenue,
    ROUND(SUM(price) / COUNT(DISTINCT seller_id), 2) AS avg_revenue_per_seller
FROM v_master_products_sellers
WHERE seller_state IS NOT NULL
GROUP BY seller_state
ORDER BY total_sellers DESC;

CREATE OR REPLACE VIEW v_orders_per_state AS
SELECT 
    seller_state,
    COUNT(DISTINCT order_id) AS orders_count
FROM v_master_products_sellers
GROUP BY seller_state;

CREATE OR REPLACE VIEW v_avg_items_per_order_by_state AS
WITH order_counts AS (
    SELECT 
        order_id,
        seller_state,
        COUNT(product_id) AS items_in_this_order
    FROM v_master_products_sellers
    WHERE seller_state IS NOT NULL
    GROUP BY order_id, seller_state
)
SELECT 
    seller_state,
    ROUND(AVG(items_in_this_order), 2) AS avg_items_per_order,
    COUNT(DISTINCT order_id) AS total_orders_in_state
FROM order_counts
GROUP BY seller_state
ORDER BY avg_items_per_order DESC;

CREATE OR REPLACE VIEW v_shipping_impact_analysis AS
SELECT 
    seller_state,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(freight_value), 2) AS avg_shipping,
    ROUND((AVG(freight_value) / AVG(price)) * 100, 2) AS shipping_cost_percentage
FROM v_master_products_sellers
WHERE seller_state IS NOT NULL AND price > 0
GROUP BY seller_state
ORDER BY shipping_cost_percentage DESC;

CREATE OR REPLACE VIEW v_top_10_sellers_by_revenue AS
SELECT 
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM v_master_products_sellers
WHERE seller_id IS NOT NULL
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

CREATE OR REPLACE VIEW v_category_translation_map AS
SELECT DISTINCT 
    category_br,
    category_en
FROM v_master_products_sellers
WHERE category_en IS NOT NULL;
