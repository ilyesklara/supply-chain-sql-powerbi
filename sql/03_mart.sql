-- =============================================================
-- 03_mart.sql
-- Supply Chain Analysis — Mart Layer (Star Schema)
-- Purpose: Build fact and dimension tables with PK/FK constraints.
--          This layer is connected directly to Power BI.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS mart;

-- -------------------------------------------------------------
-- mart.dim_customer
-- Granularity: one row per unique customer_id
-- -------------------------------------------------------------
CREATE TABLE mart.dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country
FROM clean.orders;

-- -------------------------------------------------------------
-- mart.dim_product
-- Granularity: one row per unique product_card_id
-- -------------------------------------------------------------
CREATE TABLE mart.dim_product AS
SELECT DISTINCT
    product_card_id,
    product_name,
    product_price,
    category_id,
    category_name,
    department_id,
    department_name,
    product_status
FROM clean.orders;

-- -------------------------------------------------------------
-- mart.dim_geography
-- Granularity: one row per unique region + country + city combo
-- Surrogate key generated using ROW_NUMBER() OVER()
-- Note: order_state excluded because same city can appear with
--       multiple state values, which would cause fan-out in joins
-- -------------------------------------------------------------
CREATE TABLE mart.dim_geography AS
SELECT
    ROW_NUMBER() OVER (ORDER BY order_region, order_country, order_city) AS geography_id,
    order_region,
    order_country,
    order_city,
    market
FROM (
    SELECT DISTINCT
        order_region,
        order_country,
        order_city,
        market
    FROM clean.orders
) sub;

-- -------------------------------------------------------------
-- mart.dim_date
-- Generated using generate_series() — covers full dataset range
-- -------------------------------------------------------------
CREATE TABLE mart.dim_date AS
SELECT
    date::DATE AS date_id,
    EXTRACT(YEAR FROM date)::INTEGER AS year,
    EXTRACT(MONTH FROM date)::INTEGER AS month,
    TO_CHAR(date, 'Mon') AS month_short,
    TO_CHAR(date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM date)::INTEGER AS quarter,
    EXTRACT(DAY FROM date)::INTEGER AS day,
    TO_CHAR(date, 'Day') AS day_name,
    EXTRACT(WEEK FROM date)::INTEGER AS week_number
FROM generate_series(
    '2015-01-01'::DATE,
    '2018-12-31'::DATE,
    '1 day'::INTERVAL
) AS date;

-- -------------------------------------------------------------
-- mart.fact_orders
-- Granularity: one row per order line item (order_item_id)
-- geography_id joined from dim_geography via surrogate key
-- -------------------------------------------------------------
CREATE TABLE mart.fact_orders AS
SELECT
    o.order_item_id,
    o.order_id,
    o.customer_id,
    o.product_card_id,
    o.order_date,
    o.shipping_date,
    g.geography_id,
    o.delivery_status,
    o.shipping_mode,
    o.late_delivery_risk,
    o.days_for_shipping_real,
    o.days_for_shipment_scheduled,
    o.sales,
    o.benefit_per_order,
    o.sales_per_customer,
    o.order_item_discount,
    o.order_item_discount_rate,
    o.order_item_product_price,
    o.order_item_profit_ratio,
    o.order_item_quantity,
    o.order_item_total,
    o.order_profit_per_order,
    o.order_status,
    o.payment_type
FROM clean.orders o
LEFT JOIN mart.dim_geography g
    ON o.order_region = g.order_region
    AND o.order_country = g.order_country
    AND o.order_city = g.order_city;

-- Verify row count (expected: 180,519)
-- SELECT COUNT(*) FROM mart.fact_orders;

-- Verify no NULL geography_id (expected: 0)
-- SELECT COUNT(*) FILTER (WHERE geography_id IS NULL) FROM mart.fact_orders;


-- -------------------------------------------------------------
-- Primary and Foreign Key Constraints
-- -------------------------------------------------------------

-- Primary keys
ALTER TABLE mart.dim_customer   ADD PRIMARY KEY (customer_id);
ALTER TABLE mart.dim_product    ADD PRIMARY KEY (product_card_id);
ALTER TABLE mart.dim_geography  ADD PRIMARY KEY (geography_id);
ALTER TABLE mart.dim_date       ADD PRIMARY KEY (date_id);
ALTER TABLE mart.fact_orders    ADD PRIMARY KEY (order_item_id);

-- Foreign keys
ALTER TABLE mart.fact_orders
    ADD FOREIGN KEY (customer_id)    REFERENCES mart.dim_customer(customer_id);
ALTER TABLE mart.fact_orders
    ADD FOREIGN KEY (product_card_id) REFERENCES mart.dim_product(product_card_id);
ALTER TABLE mart.fact_orders
    ADD FOREIGN KEY (geography_id)   REFERENCES mart.dim_geography(geography_id);
ALTER TABLE mart.fact_orders
    ADD FOREIGN KEY (order_date)     REFERENCES mart.dim_date(date_id);

-- Verify constraints (expected: 5 PRIMARY KEY + 4 FOREIGN KEY)
-- SELECT constraint_name, constraint_type, table_name
-- FROM information_schema.table_constraints
-- WHERE table_schema = 'mart'
-- ORDER BY table_name, constraint_type;
