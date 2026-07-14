CREATE SCHEMA dimensi;
CREATE SCHEMA fact;

CREATE SCHEMA staging;
CREATE TABLE staging.stg_sales
(
    row_id INTEGER,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),

    customer_id VARCHAR(50),
    customer_name VARCHAR(255),
    segment VARCHAR(50),

    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(100),

    product_id VARCHAR(50),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name TEXT,

    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(5,2),
    profit NUMERIC(12,2)
);

SELECT COUNT(*)
FROM staging.stg_sales;

CREATE TABLE dimensi.dim_customer
(
    sk_customer SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(255),
    segment VARCHAR(50)
);

CREATE TABLE dimensi.dim_product
(
    sk_product SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    product_name TEXT,
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

CREATE TABLE dimensi.dim_region
(
    sk_region SERIAL PRIMARY KEY,
    country VARCHAR(100),
    region VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dimensi.dim_shipping
(
    sk_shipping SERIAL PRIMARY KEY,
    ship_mode VARCHAR(50)
);


INSERT INTO dimensi.dim_customer
(
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT
       customer_id,
       customer_name,
       segment
FROM staging.stg_sales;

INSERT INTO dimensi.dim_product
(
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT
       product_id,
       product_name,
       category,
       sub_category
FROM staging.stg_sales;

INSERT INTO dimensi.dim_region
(
    country,
    region,
    state,
    city,
    postal_code
)
SELECT DISTINCT
       country,
       region,
       state,
       city,
       postal_code
FROM staging.stg_sales;

INSERT INTO dimensi.dim_shipping
(
    ship_mode
)
SELECT DISTINCT ship_mode
FROM staging.stg_sales;

DROP TABLE IF EXISTS dimensi.dim_date;
CREATE TABLE dimensi.dim_date
(
    sk_waktu INTEGER PRIMARY KEY,
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

INSERT INTO dimensi.dim_date
(
    sk_waktu,
    full_date,
    tahun,
    kuartal,
    bulan,
    nama_bulan,
    minggu,
    hari,
    nama_hari,
    is_weekend
)
SELECT DISTINCT

    CAST(TO_CHAR(dt,'YYYYMMDD') AS INTEGER),

    dt,

    EXTRACT(YEAR FROM dt),

    EXTRACT(QUARTER FROM dt),

    EXTRACT(MONTH FROM dt),

    TO_CHAR(dt,'Month'),

    EXTRACT(WEEK FROM dt),

    EXTRACT(DAY FROM dt),

    TO_CHAR(dt,'Day'),

    CASE
        WHEN EXTRACT(ISODOW FROM dt) IN (6,7)
        THEN TRUE
        ELSE FALSE
    END

FROM
(
    SELECT order_date AS dt
    FROM staging.stg_sales

    UNION

    SELECT ship_date
    FROM staging.stg_sales
) x;

SELECT COUNT(*) FROM dimensi.dim_customer;
SELECT COUNT(*) FROM dimensi.dim_product;
SELECT COUNT(*) FROM dimensi.dim_region;
SELECT COUNT(*) FROM dimensi.dim_shipping;
SELECT COUNT(*) FROM dimensi.dim_date;

DROP TABLE IF EXISTS fact.fact_sales;

CREATE TABLE fact.fact_sales
(
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
    discount NUMERIC(5,2),
    profit NUMERIC(12,2)
);

INSERT INTO fact.fact_sales
(
    sk_customer,
    sk_product,
    sk_region,
    sk_shipping,

    sk_order_date,
    sk_ship_date,

    order_id,

    sales,
    quantity,
    discount,
    profit
)

SELECT

    dc.sk_customer,
    dp.sk_product,
    dr.sk_region,
    ds.sk_shipping,

    CAST(TO_CHAR(s.order_date,'YYYYMMDD') AS INTEGER),
    CAST(TO_CHAR(s.ship_date,'YYYYMMDD') AS INTEGER),

    s.order_id,

    s.sales,
    s.quantity,
    s.discount,
    s.profit

FROM staging.stg_sales s

INNER JOIN dimensi.dim_customer dc
ON s.customer_id = dc.customer_id

INNER JOIN dimensi.dim_product dp
ON s.product_id = dp.product_id

INNER JOIN dimensi.dim_region dr
ON s.country = dr.country
AND s.region = dr.region
AND s.state = dr.state
AND s.city = dr.city
AND s.postal_code = dr.postal_code

INNER JOIN dimensi.dim_shipping ds
ON s.ship_mode = ds.ship_mode;

SELECT
    COUNT(*) FILTER (WHERE sk_customer IS NULL) customer_null,
    COUNT(*) FILTER (WHERE sk_product IS NULL) product_null,
    COUNT(*) FILTER (WHERE sk_region IS NULL) region_null,
    COUNT(*) FILTER (WHERE sk_shipping IS NULL) shipping_null,
    COUNT(*) FILTER (WHERE sk_order_date IS NULL) order_date_null,
    COUNT(*) FILTER (WHERE sk_ship_date IS NULL) ship_date_null
FROM fact.fact_sales;

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
ADD CONSTRAINT fk_order_date
FOREIGN KEY (sk_order_date)
REFERENCES dimensi.dim_date(sk_waktu);

ALTER TABLE fact.fact_sales
ADD CONSTRAINT fk_ship_date
FOREIGN KEY (sk_ship_date)
REFERENCES dimensi.dim_date(sk_waktu);

CREATE INDEX idx_fact_customer
ON fact.fact_sales(sk_customer);

CREATE INDEX idx_fact_product
ON fact.fact_sales(sk_product);

CREATE INDEX idx_fact_region
ON fact.fact_sales(sk_region);

CREATE INDEX idx_fact_order_date
ON fact.fact_sales(sk_order_date);

SELECT
    p.category,
    SUM(f.sales) total_sales
FROM fact.fact_sales f
JOIN dimensi.dim_product p
ON f.sk_product = p.sk_product
GROUP BY p.category
ORDER BY total_sales DESC;

SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'fact';

SELECT
    conname,
    pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'fact.fact_sales'::regclass;

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
ADD CONSTRAINT fk_order_date
FOREIGN KEY (sk_order_date)
REFERENCES dimensi.dim_date(sk_waktu);

SELECT
    conname,
    pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'fact.fact_sales'::regclass;