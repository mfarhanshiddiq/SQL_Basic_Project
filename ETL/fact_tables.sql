
CREATE TABLE dwh.fact_sales (
    sales_id INT PRIMARY KEY,
    transaction_number TEXT,
    sales_date DATE,
    store_id INT,
    customer_id INT,
    product_id INT,
    quantity INT,
    price NUMERIC,
    discount NUMERIC,
    sales NUMERIC,

    FOREIGN KEY (sales_date) REFERENCES dwh.dim_date(date_id),
    FOREIGN KEY (store_id) REFERENCES dwh.dim_store(store_id),
    FOREIGN KEY (customer_id) REFERENCES dwh.dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dwh.dim_product(product_id)
);


-- Insert FACT SALES
INSERT INTO dwh.fact_sales (
    sales_id,
    transaction_number,
    sales_date,
    store_id,
    customer_id,
    product_id,
    quantity,
    price,
    discount,
    sales
)
SELECT
    sales_id,
    transaction_number,
    sales_date,
    store_id,
    customer_id,
    product_id,
    quantity,
    price, 
    discount,
    sales
FROM staging.staging_grocery;