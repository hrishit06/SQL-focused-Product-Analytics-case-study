
-- Project: E-commerce Funnel Analysis
-- File: event_exploration.sql
-- Dataset: eCommerce Behavior Data from Multi-Category Store
-- Source file: 2019-Nov.csv
-- SQL engine: DuckDB
--
-- Available source columns:
-- event_time, event_type, product_id, category_id,
-- category_code, brand, price, user_id, user_session
--
-- Objective:
-- Explore event types, data volume, and data quality
-- before performing product funnel analysis.

DESCRIBE
SELECT *
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
);

SELECT
    event_type,
    COUNT(*) AS total_events
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
)
GROUP BY event_type
ORDER BY total_events DESC;

SELECT
    event_type,
    COUNT(DISTINCT user_id) AS unique_users
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
)
GROUP BY event_type
ORDER BY unique_users DESC;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS missing_user_id,
    COUNT(*) FILTER (WHERE user_session IS NULL) AS missing_user_session,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE event_time IS NULL) AS missing_event_time,
    COUNT(*) FILTER (WHERE event_type IS NULL) AS missing_event_type
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
);

SELECT
    event_type,
    COUNT(*) AS total_events,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS event_share_pct
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
)
GROUP BY event_type
ORDER BY total_events DESC;

SELECT
    MIN(event_time) AS first_event,
    MAX(event_time) AS last_event
FROM read_csv_auto(
    '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
);
