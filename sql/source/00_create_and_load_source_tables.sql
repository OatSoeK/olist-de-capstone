-- ============================================================
-- Olist Capstone — Source Table Setup
-- Run ONCE before any Week 2+ SQL hands-on.
-- Prereq: the 9 Olist CSVs are unzipped into ./data/ (gitignored).
--
-- This is a deliberately simple, SQL-only load (COPY) so you can
-- start querying before Module 3 teaches the real Python ingestion
-- pipeline. In Week 7 you'll replace this script with a proper
-- Python loader — the tables it creates stay the same shape.
--
-- Run from the project root with:
--   psql -d olist_capstone -f sql/00_create_and_load_source_tables.sql
-- ============================================================

DROP TABLE IF EXISTS order_reviews, order_payments, order_items, orders,
    products, category_translation, sellers, geolocation, customers CASCADE;

CREATE TABLE customers (
    customer_id             VARCHAR(32) PRIMARY KEY,
    customer_unique_id      VARCHAR(32),
    customer_zip_code_prefix VARCHAR(5),
    customer_city           TEXT,
    customer_state          VARCHAR(2)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(5),
    geolocation_lat         DOUBLE PRECISION,
    geolocation_lng         DOUBLE PRECISION,
    geolocation_city        TEXT,
    geolocation_state       VARCHAR(2)
);

CREATE TABLE sellers (
    seller_id               VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(5),
    seller_city             TEXT,
    seller_state            VARCHAR(2)
);

CREATE TABLE category_translation (
    product_category_name          TEXT PRIMARY KEY,
    product_category_name_english  TEXT
);

CREATE TABLE products (
    product_id                 VARCHAR(32) PRIMARY KEY,
    product_category_name      TEXT,
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

CREATE TABLE orders (
    order_id                      VARCHAR(32) PRIMARY KEY,
    customer_id                   VARCHAR(32) REFERENCES customers(customer_id),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id            VARCHAR(32) REFERENCES orders(order_id),
    order_item_id        INT,
    product_id           VARCHAR(32) REFERENCES products(product_id),
    seller_id             VARCHAR(32) REFERENCES sellers(seller_id),
    shipping_limit_date   TIMESTAMP,
    price                 NUMERIC(10,2),
    freight_value         NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id              VARCHAR(32) REFERENCES orders(order_id),
    payment_sequential    INT,
    payment_type          VARCHAR(20),
    payment_installments  INT,
    payment_value         NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id                 VARCHAR(32),
    order_id                  VARCHAR(32) REFERENCES orders(order_id),
    review_score              INT,
    review_comment_title      TEXT,
    review_comment_message    TEXT,
    review_creation_date      TIMESTAMP,
    review_answer_timestamp   TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);

-- ------------------------------------------------------------
-- Load each CSV. \copy runs client-side (psql only) so the file
-- paths are relative to where you run psql, not the server.
-- Order matters: load tables with no foreign keys first.
-- ------------------------------------------------------------
\copy customers           FROM 'data/raw/olist_customers_dataset.csv' CSV HEADER
\copy geolocation          FROM 'data/raw/olist_geolocation_dataset.csv' CSV HEADER
\copy sellers              FROM 'data/raw/olist_sellers_dataset.csv' CSV HEADER
\copy category_translation FROM 'data/raw/product_category_name_translation.csv' CSV HEADER
\copy products             FROM 'data/raw/olist_products_dataset.csv' CSV HEADER
\copy orders               FROM 'data/raw/olist_orders_dataset.csv' CSV HEADER
\copy order_items          FROM 'data/raw/olist_order_items_dataset.csv' CSV HEADER
\copy order_payments       FROM 'data/raw/olist_order_payments_dataset.csv' CSV HEADER
\copy order_reviews        FROM 'data/raw/olist_order_reviews_dataset.csv' CSV HEADER

-- ------------------------------------------------------------
-- Sanity check — row counts should roughly match Kaggle's listing
-- (orders ~99.4k, order_items ~112.6k, customers ~99.4k, etc.)
-- ------------------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;
