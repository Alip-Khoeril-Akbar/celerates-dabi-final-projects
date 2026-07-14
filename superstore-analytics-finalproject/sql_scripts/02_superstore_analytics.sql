CREATE TABLE dimensi.dim_customer (
    sk_customer SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(150),
    segment VARCHAR(50)
);

CREATE TABLE dimensi.dim_product (
    sk_product SERIAL PRIMARY KEY,
    product_id VARCHAR(100),
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

CREATE TABLE dimensi.dim_region (
    sk_region SERIAL PRIMARY KEY,
    country VARCHAR(100),
    region VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dimensi.dim_shipping (
    sk_shipping SERIAL PRIMARY KEY,
    ship_mode VARCHAR(100)
);

CREATE TABLE dimensi.dim_date (
    sk_waktu SERIAL PRIMARY KEY,
    full_date DATE,
    tahun INTEGER,
    kuartal INTEGER,
    bulan INTEGER,
    nama_bulan VARCHAR(20),
    minggu INTEGER,
    hari INTEGER,
    nama_hari VARCHAR(20),
    is_weekend BOOLEAN
);

CREATE TABLE fact.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    sk_customer INTEGER,
    sk_product INTEGER,
    sk_region INTEGER,
    sk_shipping INTEGER,
    sk_order_date INTEGER,
    sk_ship_date INTEGER,
    order_id VARCHAR(50),
    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(12,2),
    profit NUMERIC(12,2)
);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_customer
FOREIGN KEY (sk_customer)
REFERENCES dimensi.dim_customer(sk_customer);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_product
FOREIGN KEY (sk_product)
REFERENCES dimensi.dim_product(sk_product);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_region
FOREIGN KEY (sk_region)
REFERENCES dimensi.dim_region(sk_region);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_shipping
FOREIGN KEY (sk_shipping)
REFERENCES dimensi.dim_shipping(sk_shipping);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_waktu
FOREIGN KEY (sk_waktu)
REFERENCES dimensi.dim_date(sk_waktu);

SELECT COUNT(*)
FROM fact.fact_sales;


DROP TABLE IF EXISTS fact.fact_sales;

CREATE TABLE fact.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    sk_customer INTEGER NOT NULL,
    sk_product INTEGER NOT NULL,
    sk_region INTEGER NOT NULL,
    sk_shipping INTEGER NOT NULL,
    sk_waktu INTEGER NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(12,2),
    profit NUMERIC(12,2),
    CONSTRAINT fk_customer
        FOREIGN KEY (sk_customer)
        REFERENCES dimensi.dim_customer(sk_customer),
    CONSTRAINT fk_product
        FOREIGN KEY (sk_product)
        REFERENCES dimensi.dim_product(sk_product),
    CONSTRAINT fk_region
        FOREIGN KEY (sk_region)
        REFERENCES dimensi.dim_region(sk_region),
    CONSTRAINT fk_shipping
        FOREIGN KEY (sk_shipping)
        REFERENCES dimensi.dim_shipping(sk_shipping),
    CONSTRAINT fk_waktu
        FOREIGN KEY (sk_waktu)
        REFERENCES dimensi.dim_date(sk_waktu)
);

DROP TABLE IF EXISTS datamart.dm_superstore;

CREATE TABLE datamart.dm_superstore (
    order_id VARCHAR(50),
    order_date date,
    kuartal INTEGER,
    customer_name VARCHAR(255),
    segment VARCHAR(100),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),
    country VARCHAR(100),
    region VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    ship_mode VARCHAR(100),
    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(12,2),
    profit NUMERIC(12,2)
);