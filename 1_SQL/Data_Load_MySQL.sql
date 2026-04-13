-- ======================================================
-- BRAZILIAN OLIST E-COMMERCE DATABASE SETUP SCRIPT
-- ======================================================
-- Author: Data Engineer
-- Description: Complete setup script for Olist E-commerce database
-- Includes: Table creation, CSV data loading, and analytical views
-- Database: MySQL 8.0+
-- ======================================================

-- Enable local infile for data loading
SET GLOBAL local_infile = 1;

-- Create and use the database
CREATE DATABASE IF NOT EXISTS `ecommerce` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_0900_ai_ci;

USE `ecommerce`;

-- ======================================================
-- PART 1: CREATE TABLES WITH FOREIGN KEYS
-- ======================================================

-- ------------------------------------------------------
-- Table: olist_customers
-- Stores customer information
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_customers`;
CREATE TABLE `olist_customers` (
    `customer_id` VARCHAR(50) NOT NULL,
    `customer_unique_id` VARCHAR(50) DEFAULT NULL,
    `customer_zip_code_prefix` INT DEFAULT NULL,
    `customer_city` VARCHAR(100) DEFAULT NULL,
    `customer_state` CHAR(2) DEFAULT NULL,
    PRIMARY KEY (`customer_id`),
    INDEX `idx_customer_unique` (`customer_unique_id`),
    INDEX `idx_customer_zip` (`customer_zip_code_prefix`),
    INDEX `idx_customer_state` (`customer_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_orders
-- Stores order information
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_orders`;
CREATE TABLE `olist_orders` (
    `order_id` VARCHAR(50) NOT NULL,
    `customer_id` VARCHAR(50) DEFAULT NULL,
    `order_status` VARCHAR(20) DEFAULT NULL,
    `order_purchase_timestamp` DATETIME DEFAULT NULL,
    `order_approved_at` DATETIME DEFAULT NULL,
    `order_delivered_carrier_date` DATETIME DEFAULT NULL,
    `order_delivered_customer_date` DATETIME DEFAULT NULL,
    `order_estimated_delivery_date` DATETIME DEFAULT NULL,
    PRIMARY KEY (`order_id`),
    INDEX `idx_order_customer` (`customer_id`),
    INDEX `idx_order_status` (`order_status`),
    INDEX `idx_order_purchase` (`order_purchase_timestamp`),
    CONSTRAINT `fk_orders_customers` 
        FOREIGN KEY (`customer_id`) 
        REFERENCES `olist_customers` (`customer_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_sellers
-- Stores seller information
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_sellers`;
CREATE TABLE `olist_sellers` (
    `seller_id` VARCHAR(50) NOT NULL,
    `seller_zip_code_prefix` VARCHAR(10) DEFAULT NULL,
    `seller_city` VARCHAR(100) DEFAULT NULL,
    `seller_state` CHAR(2) DEFAULT NULL,
    PRIMARY KEY (`seller_id`),
    INDEX `idx_seller_zip` (`seller_zip_code_prefix`),
    INDEX `idx_seller_state` (`seller_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_products
-- Stores product information
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_products`;
CREATE TABLE `olist_products` (
    `product_id` VARCHAR(50) NOT NULL,
    `product_category_name` VARCHAR(100) DEFAULT NULL,
    `product_name_length` INT DEFAULT NULL,
    `product_description_length` INT DEFAULT NULL,
    `product_photos_qty` INT DEFAULT NULL,
    `product_weight_g` INT DEFAULT NULL,
    `product_length_cm` INT DEFAULT NULL,
    `product_height_cm` INT DEFAULT NULL,
    `product_width_cm` INT DEFAULT NULL,
    PRIMARY KEY (`product_id`),
    INDEX `idx_product_category` (`product_category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: product_category_name_translation
-- Translates product categories to English
-- ------------------------------------------------------
DROP TABLE IF EXISTS `product_category_name_translation`;
CREATE TABLE `product_category_name_translation` (
    `product_category_name` VARCHAR(255) NOT NULL,
    `product_category_name_english` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`product_category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_order_items
-- Stores individual items within orders
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_order_items`;
CREATE TABLE `olist_order_items` (
    `order_id` VARCHAR(50) NOT NULL,
    `order_item_id` INT NOT NULL,
    `product_id` VARCHAR(50) DEFAULT NULL,
    `seller_id` VARCHAR(50) DEFAULT NULL,
    `shipping_limit_date` DATETIME DEFAULT NULL,
    `price` DECIMAL(10,2) DEFAULT NULL,
    `freight_value` DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (`order_id`, `order_item_id`),
    INDEX `idx_order_items_product` (`product_id`),
    INDEX `idx_order_items_seller` (`seller_id`),
    CONSTRAINT `fk_order_items_orders` 
        FOREIGN KEY (`order_id`) 
        REFERENCES `olist_orders` (`order_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_order_items_products` 
        FOREIGN KEY (`product_id`) 
        REFERENCES `olist_products` (`product_id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_order_items_sellers` 
        FOREIGN KEY (`seller_id`) 
        REFERENCES `olist_sellers` (`seller_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_order_payments
-- Stores payment information for orders
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_order_payments`;
CREATE TABLE `olist_order_payments` (
    `order_id` VARCHAR(50) NOT NULL,
    `payment_sequential` INT NOT NULL,
    `payment_type` VARCHAR(20) DEFAULT NULL,
    `payment_installments` INT DEFAULT NULL,
    `payment_value` DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (`order_id`, `payment_sequential`),
    INDEX `idx_payment_order` (`order_id`),
    INDEX `idx_payment_type` (`payment_type`),
    CONSTRAINT `fk_payments_orders` 
        FOREIGN KEY (`order_id`) 
        REFERENCES `olist_orders` (`order_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_order_reviews
-- Stores customer reviews for orders
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_order_reviews`;
CREATE TABLE `olist_order_reviews` (
    `review_id` VARCHAR(50) NOT NULL,
    `order_id` VARCHAR(50) DEFAULT NULL,
    `review_score` INT DEFAULT NULL,
    `review_comment_title` TEXT,
    `review_comment_message` TEXT,
    `review_creation_date` DATETIME DEFAULT NULL,
    `review_answer_timestamp` DATETIME DEFAULT NULL,
    PRIMARY KEY (`review_id`),
    INDEX `idx_review_order` (`order_id`),
    INDEX `idx_review_score` (`review_score`),
    CONSTRAINT `fk_reviews_orders` 
        FOREIGN KEY (`order_id`) 
        REFERENCES `olist_orders` (`order_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: olist_geolocation
-- Stores geographical location data
-- ------------------------------------------------------
DROP TABLE IF EXISTS `olist_geolocation`;
CREATE TABLE `olist_geolocation` (
    `geolocation_zip_code_prefix` VARCHAR(10) NOT NULL,
    `geolocation_lat` DECIMAL(10,8) DEFAULT NULL,
    `geolocation_lng` DECIMAL(11,8) DEFAULT NULL,
    `geolocation_city` VARCHAR(100) DEFAULT NULL,
    `geolocation_state` CHAR(2) DEFAULT NULL,
    INDEX `idx_geolocation_zip` (`geolocation_zip_code_prefix`),
    INDEX `idx_geolocation_city_state` (`geolocation_city`, `geolocation_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------
-- Table: geolocation_clean
-- Stores cleaned geographical data (unique city-level coordinates)
-- ------------------------------------------------------
DROP TABLE IF EXISTS `geolocation_clean`;
CREATE TABLE `geolocation_clean` (
    `geolocation_zip_code_prefix` VARCHAR(10) NOT NULL,
    `city_lat` DECIMAL(10,8) DEFAULT NULL,
    `city_lng` DECIMAL(11,8) DEFAULT NULL,
    `geolocation_city` VARCHAR(100) DEFAULT NULL,
    `geolocation_state` CHAR(2) DEFAULT NULL,
    PRIMARY KEY (`geolocation_zip_code_prefix`),
    INDEX `idx_clean_zip` (`geolocation_zip_code_prefix`),
    INDEX `idx_clean_city_state` (`geolocation_city`, `geolocation_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ======================================================
-- PART 2: LOAD DATA FROM CSV FILES
-- ======================================================
-- IMPORTANT: Update the file paths to match your CSV file locations
-- Example: 'C:/data/olist_customers_dataset.csv' or '/var/lib/mysql-files/olist_customers_dataset.csv'
-- ======================================================

-- Enable local infile for this session
SET SESSION sql_mode = '';

-- ------------------------------------------------------
-- Load customers data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_customers_dataset.csv'
INTO TABLE olist_customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@customer_id, @customer_unique_id, @customer_zip_code_prefix, 
 @customer_city, @customer_state)
SET 
    customer_id = NULLIF(@customer_id, ''),
    customer_unique_id = NULLIF(@customer_unique_id, ''),
    customer_zip_code_prefix = NULLIF(@customer_zip_code_prefix, ''),
    customer_city = NULLIF(@customer_city, ''),
    customer_state = NULLIF(@customer_state, '');

-- ------------------------------------------------------
-- Load sellers data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_sellers_dataset.csv'
INTO TABLE olist_sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@seller_id, @seller_zip_code_prefix, @seller_city, @seller_state)
SET 
    seller_id = NULLIF(@seller_id, ''),
    seller_zip_code_prefix = NULLIF(@seller_zip_code_prefix, ''),
    seller_city = NULLIF(@seller_city, ''),
    seller_state = NULLIF(@seller_state, '');

-- ------------------------------------------------------
-- Load products data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_products_dataset.csv'
INTO TABLE olist_products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@product_id, @product_category_name, @product_name_length, 
 @product_description_length, @product_photos_qty, @product_weight_g,
 @product_length_cm, @product_height_cm, @product_width_cm)
SET 
    product_id = NULLIF(@product_id, ''),
    product_category_name = NULLIF(@product_category_name, ''),
    product_name_length = NULLIF(@product_name_length, ''),
    product_description_length = NULLIF(@product_description_length, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');

-- ------------------------------------------------------
-- Load category translation data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@product_category_name, @product_category_name_english)
SET 
    product_category_name = NULLIF(@product_category_name, ''),
    product_category_name_english = NULLIF(@product_category_name_english, '');

-- ------------------------------------------------------
-- Load orders data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_orders_dataset.csv'
INTO TABLE olist_orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @customer_id, @order_status, @order_purchase_timestamp,
 @order_approved_at, @order_delivered_carrier_date, 
 @order_delivered_customer_date, @order_estimated_delivery_date)
SET 
    order_id = NULLIF(@order_id, ''),
    customer_id = NULLIF(@customer_id, ''),
    order_status = NULLIF(@order_status, ''),
    order_purchase_timestamp = STR_TO_DATE(NULLIF(@order_purchase_timestamp, ''), '%Y-%m-%d %H:%i:%s'),
    order_approved_at = STR_TO_DATE(NULLIF(@order_approved_at, ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_carrier_date = STR_TO_DATE(NULLIF(@order_delivered_carrier_date, ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_customer_date = STR_TO_DATE(NULLIF(@order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s'),
    order_estimated_delivery_date = STR_TO_DATE(NULLIF(@order_estimated_delivery_date, ''), '%Y-%m-%d %H:%i:%s');

-- ------------------------------------------------------
-- Load order items data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_order_items_dataset.csv'
INTO TABLE olist_order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @order_item_id, @product_id, @seller_id, 
 @shipping_limit_date, @price, @freight_value)
SET 
    order_id = NULLIF(@order_id, ''),
    order_item_id = NULLIF(@order_item_id, ''),
    product_id = NULLIF(@product_id, ''),
    seller_id = NULLIF(@seller_id, ''),
    shipping_limit_date = STR_TO_DATE(NULLIF(@shipping_limit_date, ''), '%Y-%m-%d %H:%i:%s'),
    price = NULLIF(@price, ''),
    freight_value = NULLIF(@freight_value, '');

-- ------------------------------------------------------
-- Load order payments data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @payment_sequential, @payment_type, 
 @payment_installments, @payment_value)
SET 
    order_id = NULLIF(@order_id, ''),
    payment_sequential = NULLIF(@payment_sequential, ''),
    payment_type = NULLIF(@payment_type, ''),
    payment_installments = NULLIF(@payment_installments, ''),
    payment_value = NULLIF(@payment_value, '');

-- ------------------------------------------------------
-- Load order reviews data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@review_id, @order_id, @review_score, @review_comment_title,
 @review_comment_message, @review_creation_date, @review_answer_timestamp)
SET 
    review_id = NULLIF(@review_id, ''),
    order_id = NULLIF(@order_id, ''),
    review_score = NULLIF(@review_score, ''),
    review_comment_title = NULLIF(@review_comment_title, ''),
    review_comment_message = NULLIF(@review_comment_message, ''),
    review_creation_date = STR_TO_DATE(NULLIF(@review_creation_date, ''), '%Y-%m-%d %H:%i:%s'),
    review_answer_timestamp = STR_TO_DATE(NULLIF(@review_answer_timestamp, ''), '%Y-%m-%d %H:%i:%s');

-- ------------------------------------------------------
-- Load geolocation data
-- ------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/data/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@geolocation_zip_code_prefix, @geolocation_lat, @geolocation_lng,
 @geolocation_city, @geolocation_state)
SET 
    geolocation_zip_code_prefix = NULLIF(@geolocation_zip_code_prefix, ''),
    geolocation_lat = NULLIF(@geolocation_lat, ''),
    geolocation_lng = NULLIF(@geolocation_lng, ''),
    geolocation_city = NULLIF(@geolocation_city, ''),
    geolocation_state = NULLIF(@geolocation_state, '');

-- ------------------------------------------------------
-- Clean and aggregate geolocation data to zip code level
-- ------------------------------------------------------
INSERT INTO geolocation_clean (geolocation_zip_code_prefix, city_lat, city_lng, geolocation_city, geolocation_state)
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) as city_lat,
    AVG(geolocation_lng) as city_lng,
    MAX(geolocation_city) as geolocation_city,
    MAX(geolocation_state) as geolocation_state
FROM olist_geolocation
GROUP BY geolocation_zip_code_prefix
ON DUPLICATE KEY UPDATE
    city_lat = VALUES(city_lat),
    city_lng = VALUES(city_lng),
    geolocation_city = VALUES(geolocation_city),
    geolocation_state = VALUES(geolocation_state);

-- ======================================================
-- PART 3: CREATE ANALYTICAL VIEWS
-- ======================================================

-- ------------------------------------------------------
-- View: v_master_products_sellers
-- Master view combining products, sellers, and orders
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_master_products_sellers`;
CREATE VIEW `v_master_products_sellers` AS
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

-- ------------------------------------------------------
-- View: v_final_project_summary
-- Summary of delivered orders with payments and reviews
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_final_project_summary`;
CREATE VIEW `v_final_project_summary` AS
SELECT 
    o.order_id,
    c.customer_city,
    c.customer_state,
    YEAR(o.order_purchase_timestamp) AS order_year,
    p.payment_type,
    p.payment_value AS revenue,
    r.review_score,
    o.order_status
FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
LEFT JOIN olist_order_payments p ON o.order_id = p.order_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered';

-- ------------------------------------------------------
-- View: v_revenue_per_year
-- Total revenue aggregated by year
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_revenue_per_year`;
CREATE VIEW `v_revenue_per_year` AS
SELECT 
    YEAR(order_purchase_timestamp) AS sales_year,
    ROUND(SUM(total_item_cost), 2) AS total_revenue
FROM v_master_products_sellers
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY sales_year
ORDER BY sales_year;

-- ------------------------------------------------------
-- View: v_top_categories_per_year
-- Top product categories by units sold per year
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_top_categories_per_year`;
CREATE VIEW `v_top_categories_per_year` AS
SELECT 
    YEAR(order_purchase_timestamp) AS sales_year,
    category_en,
    COUNT(*) AS units_sold
FROM v_master_products_sellers
WHERE order_purchase_timestamp IS NOT NULL 
  AND category_en IS NOT NULL
GROUP BY sales_year, category_en
ORDER BY sales_year DESC, units_sold DESC;

-- ------------------------------------------------------
-- View: v_product_pricing_strategy
-- Pricing analysis by product category
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_product_pricing_strategy`;
CREATE VIEW `v_product_pricing_strategy` AS
SELECT 
    category_en,
    COUNT(*) AS units_sold,
    ROUND(AVG(price), 2) AS avg_unit_price,
    ROUND(SUM(price), 2) AS total_category_revenue
FROM v_master_products_sellers
WHERE category_en IS NOT NULL
GROUP BY category_en
ORDER BY avg_unit_price DESC;

-- ------------------------------------------------------
-- View: v_geo_seller_density
-- Geographic distribution of sellers and revenue
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_geo_seller_density`;
CREATE VIEW `v_geo_seller_density` AS
SELECT 
    seller_state,
    COUNT(DISTINCT seller_id) AS total_sellers,
    ROUND(SUM(price), 2) AS state_revenue,
    ROUND(SUM(price) / COUNT(DISTINCT seller_id), 2) AS avg_revenue_per_seller
FROM v_master_products_sellers
WHERE seller_state IS NOT NULL
GROUP BY seller_state
ORDER BY total_sellers DESC;

-- ------------------------------------------------------
-- View: v_orders_per_state
-- Number of orders per seller state
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_orders_per_state`;
CREATE VIEW `v_orders_per_state` AS
SELECT 
    seller_state,
    COUNT(DISTINCT order_id) AS orders_count
FROM v_master_products_sellers
GROUP BY seller_state;

-- ------------------------------------------------------
-- View: v_avg_items_per_order_by_state
-- Average number of items per order by seller state
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_avg_items_per_order_by_state`;
CREATE VIEW `v_avg_items_per_order_by_state` AS
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

-- ------------------------------------------------------
-- View: v_shipping_impact_analysis
-- Impact of shipping costs on total price by state
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_shipping_impact_analysis`;
CREATE VIEW `v_shipping_impact_analysis` AS
SELECT 
    seller_state,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(freight_value), 2) AS avg_shipping,
    ROUND((AVG(freight_value) / AVG(price)) * 100, 2) AS shipping_cost_percentage
FROM v_master_products_sellers
WHERE seller_state IS NOT NULL AND price > 0
GROUP BY seller_state
ORDER BY shipping_cost_percentage DESC;

-- ------------------------------------------------------
-- View: v_top_10_sellers_by_revenue
-- Top 10 sellers ranked by total revenue
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_top_10_sellers_by_revenue`;
CREATE VIEW `v_top_10_sellers_by_revenue` AS
SELECT 
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM v_master_products_sellers
WHERE seller_id IS NOT NULL
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------
-- View: v_category_translation_map
-- Mapping of Portuguese to English category names
-- ------------------------------------------------------
DROP VIEW IF EXISTS `v_category_translation_map`;
CREATE VIEW `v_category_translation_map` AS
SELECT DISTINCT 
    category_br,
    category_en
FROM v_master_products_sellers
WHERE category_en IS NOT NULL;

-- ======================================================
-- VERIFICATION QUERIES (Optional - Run to verify setup)
-- ======================================================
-- SELECT 'Tables created successfully!' AS Status;
-- SELECT COUNT(*) AS customers_count FROM olist_customers;
-- SELECT COUNT(*) AS orders_count FROM olist_orders;
-- SELECT COUNT(*) AS products_count FROM olist_products;
-- SELECT COUNT(*) AS sellers_count FROM olist_sellers;
-- SELECT COUNT(*) AS order_items_count FROM olist_order_items;
-- SELECT COUNT(*) AS payments_count FROM olist_order_payments;
-- SELECT COUNT(*) AS reviews_count FROM olist_order_reviews;
-- SELECT COUNT(*) AS geolocation_count FROM olist_geolocation;
-- 
-- -- Verify views
-- SELECT * FROM v_revenue_per_year;
-- SELECT * FROM v_top_10_sellers_by_revenue LIMIT 5;
-- SELECT * FROM v_geo_seller_density LIMIT 5;
-- ======================================================

-- End of script