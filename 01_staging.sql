-- =============================================================
-- 01_staging.sql
-- Supply Chain Analysis — Staging Layer
-- Purpose: Load raw CSV data into staging tables with minimal
--          transformation. All columns stored as TEXT to avoid
--          import errors.
-- =============================================================

-- Create staging schema
CREATE SCHEMA IF NOT EXISTS staging;

-- -------------------------------------------------------------
-- staging.stg_orders
-- Source: DataCoSupplyChainDataset.csv (180,519 rows)
-- -------------------------------------------------------------
CREATE TABLE staging.stg_orders (
    type TEXT,
    days_for_shipping_real TEXT,
    days_for_shipment_scheduled TEXT,
    benefit_per_order TEXT,
    sales_per_customer TEXT,
    delivery_status TEXT,
    late_delivery_risk TEXT,
    category_id TEXT,
    category_name TEXT,
    customer_city TEXT,
    customer_country TEXT,
    customer_email TEXT,
    customer_fname TEXT,
    customer_id TEXT,
    customer_lname TEXT,
    customer_password TEXT,
    customer_segment TEXT,
    customer_state TEXT,
    customer_street TEXT,
    customer_zipcode TEXT,
    department_id TEXT,
    department_name TEXT,
    latitude TEXT,
    longitude TEXT,
    market TEXT,
    order_city TEXT,
    order_country TEXT,
    order_customer_id TEXT,
    order_date TEXT,
    order_id TEXT,
    order_item_cardprod_id TEXT,
    order_item_discount TEXT,
    order_item_discount_rate TEXT,
    order_item_id TEXT,
    order_item_product_price TEXT,
    order_item_profit_ratio TEXT,
    order_item_quantity TEXT,
    sales TEXT,
    order_item_total TEXT,
    order_profit_per_order TEXT,
    order_region TEXT,
    order_state TEXT,
    order_status TEXT,
    order_zipcode TEXT,
    product_card_id TEXT,
    product_category_id TEXT,
    product_description TEXT,
    product_image TEXT,
    product_name TEXT,
    product_price TEXT,
    product_status TEXT,
    shipping_date TEXT,
    shipping_mode TEXT
);

-- Load data via pgAdmin Import/Export:
-- Right-click staging.stg_orders → Import/Export Data
-- Format: CSV | Encoding: WIN1252 | Header: ON | Delimiter: ,

-- Verify row count (expected: 180,519)
-- SELECT COUNT(*) FROM staging.stg_orders;


-- -------------------------------------------------------------
-- staging.stg_access_logs
-- Source: tokenized_access_logs.csv (469,977 rows)
-- -------------------------------------------------------------
CREATE TABLE staging.stg_access_logs (
    product TEXT,
    category TEXT,
    event_date TEXT,
    month TEXT,
    hour TEXT,
    department TEXT,
    ip_address TEXT,
    url TEXT
);

-- Load data via pgAdmin Import/Export:
-- Right-click staging.stg_access_logs → Import/Export Data
-- Format: CSV | Encoding: WIN1252 | Header: ON | Delimiter: ,

-- Verify row count (expected: 469,977)
-- SELECT COUNT(*) FROM staging.stg_access_logs;
