
-- Datamart table
-- Total transaksi per jam dan total pengguna yang melakukan pembelian per jam
CREATE TABLE datamart.dm_sales_per_hour AS
SELECT 
    DATE_TRUNC('hour', f.sales_date) AS hour,
    COUNT(DISTINCT f.transaction_number) AS total_transactions,
    COUNT(DISTINCT f.customer_id) AS total_users
FROM dwh.fact_sales f
GROUP BY DATE_TRUNC('hour', f.sales_date)
ORDER BY hour;

-- Total barang terjual berdasarkan barang_id

CREATE TABLE datamart.dm_product_sales AS
SELECT 
    product_id,
    SUM(quantity) AS total_sold
FROM dwh.fact_sales
GROUP BY product_id
ORDER BY total_sold DESC;

-- Total barang terjual berdasarkan store_id

CREATE TABLE datamart.dm_store_sales AS
SELECT 
    store_id,
    SUM(quantity) AS total_sold
FROM dwh.fact_sales
GROUP BY store_id
ORDER BY total_sold DESC;

-- Satu datamart bebas

CREATE TABLE datamart.dm_category_monthly AS
SELECT 
    p.category_name,
    d.year,
    d.month,
    SUM(f.sales) AS total_revenue
FROM dwh.fact_sales f
JOIN dwh.dim_product p ON f.product_id = p.product_id
JOIN dwh.dim_date d ON f.sales_date = d.date_id
GROUP BY p.category_name, d.year, d.month
ORDER BY d.year, d.month;

-- Partitioning
DROP TABLE IF EXISTS dwh.fact_sales_partitioned CASCADE;

CREATE TABLE dwh.fact_sales_partitioned (
    sales_id INT,
    transaction_number TEXT,
    sales_date DATE NOT NULL,
    store_id INT,
    customer_id INT,
    product_id INT,
    quantity INT,
    price NUMERIC,
    discount NUMERIC,
    sales NUMERIC
) PARTITION BY RANGE (sales_date);


-- Buat partisi untuk tahun 2018
CREATE TABLE dwh.fact_sales_2018 
PARTITION OF dwh.fact_sales_partitioned
FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');

-- Buat table sales_default
CREATE TABLE dwh.fact_sales_default
PARTITION OF dwh.fact_sales_partitioned
DEFAULT;

-- Insert data ke table partitioned
INSERT INTO dwh.fact_sales_partitioned (
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
FROM dwh.fact_sales;

-- Cek jumlah data di setiap partisi
SELECT tableoid::regclass, COUNT(*)
FROM dwh.fact_sales_partitioned
GROUP BY tableoid;

-- Stored Procedure

CREATE OR REPLACE PROCEDURE datamart.refresh_all_datamart()
LANGUAGE plpgsql
AS $$
BEGIN

    -- Hapus data lama
    TRUNCATE TABLE datamart.dm_sales_per_hour;
    TRUNCATE TABLE datamart.dm_product_sales;
    TRUNCATE TABLE datamart.dm_store_sales;
    TRUNCATE TABLE datamart.dm_category_monthly;

    -- Insert ulang dm_sales_per_hour
    INSERT INTO datamart.dm_sales_per_hour
    SELECT 
        DATE_TRUNC('hour', f.sales_date) AS hour,
        COUNT(DISTINCT f.transaction_number),
        COUNT(DISTINCT f.customer_id)
    FROM dwh.fact_sales f
    GROUP BY DATE_TRUNC('hour', f.sales_date);

    -- Insert ulang dm_product_sales
    INSERT INTO datamart.dm_product_sales
    SELECT 
        product_id,
        SUM(quantity)
    FROM dwh.fact_sales
    GROUP BY product_id;

    -- Insert ulang dm_store_sales
    INSERT INTO datamart.dm_store_sales
    SELECT 
        store_id,
        SUM(quantity)
    FROM dwh.fact_sales
    GROUP BY store_id;

    -- Insert ulang dm_category_monthly
    INSERT INTO datamart.dm_category_monthly
    SELECT 
        p.category_name,
        d.year,
        d.month,
        SUM(f.sales)
    FROM dwh.fact_sales f
    JOIN dwh.dim_product p ON f.product_id = p.product_id
    JOIN dwh.dim_date d ON f.sales_date = d.date_id
    GROUP BY p.category_name, d.year, d.month;

END;
$$;

CALL datamart.refresh_all_datamart();