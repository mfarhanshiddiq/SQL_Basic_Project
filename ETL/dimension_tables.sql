-- DIM STORE
CREATE TABLE dwh.dim_store (
    store_id INT PRIMARY KEY,
    store_city TEXT
);

-- DIM CUSTOMER
CREATE TABLE dwh.dim_customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT
);

-- DIM PRODUCT
CREATE TABLE dwh.dim_product (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    category_name TEXT
);

-- DIM DATE
CREATE TABLE dwh.dim_date (
    date_id DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT
);

-- Insert DIM STORE
INSERT INTO dwh.dim_store (store_id, store_city)
SELECT DISTINCT store_id, store_city
FROM staging.staging_grocery;

-- Insert DIM CUSTOMER
INSERT INTO dwh.dim_customer (customer_id, first_name, last_name)
SELECT DISTINCT customer_id, first_name, last_name
FROM staging.staging_grocery;

-- Insert DIM PRODUCT
INSERT INTO dwh.dim_product (product_id, product_name, category_name)
SELECT DISTINCT product_id, product_name, category_name
FROM staging.staging_grocery;

-- Insert DIM DATE
INSERT INTO dwh.dim_date (date_id, year, month, day)
SELECT DISTINCT sales_date,
        EXTRACT(YEAR FROM sales_date),
        EXTRACT(MONTH FROM sales_date),
        EXTRACT(DAY FROM sales_date)
FROM staging.staging_grocery;


-- Cekcek
SELECT * FROM dwh.dim_store LIMIT 10;
SELECT * FROM dwh.dim_customer LIMIT 10;
SELECT * FROM dwh.dim_product LIMIT 10;
SELECT * FROM dwh.dim_date LIMIT 10;
