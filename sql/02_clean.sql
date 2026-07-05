-- =============================================================
-- 02_clean.sql
-- Supply Chain Analysis — Clean Layer
-- Purpose: Type casting, date conversion, trimming, and column
--          selection. Removes PII columns and irrelevant fields.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS clean;

-- -------------------------------------------------------------
-- clean.orders
-- Source: staging.stg_orders
-- Key transformations:
--   - Type casting (TEXT → INTEGER, NUMERIC, DATE)
--   - Date conversion using TO_DATE() with format mask
--   - Removal of PII columns (email, password, name, street)
--   - Removal of irrelevant columns (description, image, zipcode)
--   - Renaming type → payment_type for clarity
-- -------------------------------------------------------------
CREATE TABLE clean.orders AS
SELECT
    -- Identifiers
    order_item_id::INTEGER,
    order_id::INTEGER,
    customer_id::INTEGER,
    product_card_id::INTEGER,
    order_customer_id::INTEGER,

    -- Dates (converted from MM/DD/YYYY HH24:MI format)
    TO_DATE(TRIM(order_date), 'MM/DD/YYYY HH24:MI') AS order_date,
    TO_DATE(TRIM(shipping_date), 'MM/DD/YYYY HH24:MI') AS shipping_date,

    -- Shipping
    delivery_status,
    shipping_mode,
    late_delivery_risk::INTEGER,
    days_for_shipping_real::INTEGER,
    days_for_shipment_scheduled::INTEGER,

    -- Financial
    sales::NUMERIC,
    benefit_per_order::NUMERIC,
    sales_per_customer::NUMERIC,
    order_item_discount::NUMERIC,
    order_item_discount_rate::NUMERIC,
    order_item_product_price::NUMERIC,
    order_item_profit_ratio::NUMERIC,
    order_item_quantity::INTEGER,
    order_item_total::NUMERIC,
    order_profit_per_order::NUMERIC,
    product_price::NUMERIC,

    -- Order
    order_status,
    type AS payment_type,

    -- Product
    product_name,
    category_id::INTEGER,
    category_name,
    department_id::INTEGER,
    department_name,
    product_status::INTEGER,

    -- Customer
    customer_segment,
    customer_city,
    customer_state,
    customer_country,

    -- Shipping address
    order_city,
    order_state,
    order_country,
    order_region,
    market

FROM staging.stg_orders;

-- Verify row count (expected: 180,519)
-- SELECT COUNT(*) FROM clean.orders;

-- Sample check
-- SELECT order_date, shipping_date, sales, order_id FROM clean.orders LIMIT 5;


-- -------------------------------------------------------------
-- clean.access_logs
-- Source: staging.stg_access_logs
-- Key transformations:
--   - Timestamp conversion using TO_TIMESTAMP()
--   - TRIM on department column (trailing spaces in source)
--   - hour cast to INTEGER
-- -------------------------------------------------------------
CREATE TABLE clean.access_logs AS
SELECT
    product,
    category,
    TO_TIMESTAMP(event_date, 'MM/DD/YYYY HH24:MI')::TIMESTAMP AS event_timestamp,
    month,
    hour::INTEGER,
    TRIM(department) AS department,
    ip_address,
    url
FROM staging.stg_access_logs;

-- Verify row count (expected: 469,977)
-- SELECT COUNT(*) FROM clean.access_logs;
