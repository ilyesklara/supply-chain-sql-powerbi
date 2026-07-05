-- =============================================================
-- 04_materialized_view.sql
-- Supply Chain Analysis — Materialized View
-- Purpose: Join order data with webshop access logs to identify
--          high-traffic, low-conversion products.
--
-- Performance note: Direct JOIN on 470K access logs was too slow
-- (~5 min). Solution: pre-aggregate both datasets using CTEs
-- before joining, reducing runtime to ~3 seconds.
-- =============================================================

-- -------------------------------------------------------------
-- Indexes for join performance
-- -------------------------------------------------------------
CREATE INDEX idx_access_logs_product
    ON clean.access_logs (LOWER(TRIM(product)));

CREATE INDEX idx_dim_product_name
    ON mart.dim_product (LOWER(TRIM(product_name)));

CREATE INDEX idx_fact_orders_product
    ON mart.fact_orders (product_card_id);


-- -------------------------------------------------------------
-- mart.product_view_vs_sales
-- Joins: dim_product + access_logs (by product name) +
--        fact_orders (by product_card_id)
-- Matching: LOWER(TRIM()) for fuzzy product name matching
--           between access logs and product dimension
-- -------------------------------------------------------------
CREATE MATERIALIZED VIEW mart.product_view_vs_sales AS
WITH visitor_counts AS (
    -- Pre-aggregate access logs by product name
    SELECT
        LOWER(TRIM(product)) AS product_name_lower,
        COUNT(DISTINCT ip_address) AS unique_visitors
    FROM clean.access_logs
    GROUP BY LOWER(TRIM(product))
),
sales_counts AS (
    -- Pre-aggregate fact orders by product
    SELECT
        product_card_id,
        SUM(order_item_quantity) AS total_units_sold,
        SUM(sales) AS total_revenue
    FROM mart.fact_orders
    GROUP BY product_card_id
)
SELECT
    p.product_name,
    p.category_name,
    p.department_name,
    COALESCE(v.unique_visitors, 0) AS unique_visitors,
    COALESCE(s.total_units_sold, 0) AS total_units_sold,
    COALESCE(s.total_revenue, 0) AS total_revenue
FROM mart.dim_product p
LEFT JOIN visitor_counts v
    ON LOWER(TRIM(p.product_name)) = v.product_name_lower
LEFT JOIN sales_counts s
    ON p.product_card_id = s.product_card_id
ORDER BY unique_visitors DESC;

-- Verify
-- SELECT * FROM mart.product_view_vs_sales LIMIT 10;
