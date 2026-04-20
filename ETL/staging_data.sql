-- Buat raw table
CREATE TABLE staging.staging_grocery (
    sales_id INT PRIMARY KEY,
    transaction_number VARCHAR(100),
    sales_date DATE,
    store_id INT,
    store_city VARCHAR(100),
    customer_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    category_name VARCHAR(100),
    quantity INT,
    price NUMERIC(10, 2),
    discount NUMERIC(10, 2),
    sales NUMERIC(10, 2)
);

-- DROP TABLE IF EXISTS raw.raw_grocery;

COPY staging.staging_grocery
FROM 'D:/DIBIMBING/SQL/DAY-24-ETL/ASSIGNMENT/grocery_sales.csv'
DELIMITER ','
CSV HEADER;