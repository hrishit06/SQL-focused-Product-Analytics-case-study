
-- Project: E-commerce Funnel Analysis
-- File: category_analysis.sql
-- Dataset: 2019-Nov.csv
-- SQL engine: DuckDB
--
-- Source columns used:
-- event_time, event_type, product_id, category_code,
-- user_id, user_session
--
-- Analysis grain:
-- user_id + user_session + product_id
--
-- Objective:
-- Compare sequential view -> cart -> purchase progression
-- across product categories.

WITH events AS (
    SELECT
        user_id,
        user_session,
        product_id,
        category_code,
        event_type,
        event_time
    FROM read_csv_auto(
        '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
    )
    WHERE event_type IN ('view', 'cart', 'purchase')
      AND user_id IS NOT NULL
      AND user_session IS NOT NULL
      AND product_id IS NOT NULL
      AND category_code IS NOT NULL
),

first_view AS (
    SELECT
        user_id,
        user_session,
        product_id,
        category_code,
        MIN(event_time) AS view_time
    FROM events
    WHERE event_type = 'view'
    GROUP BY
        user_id,
        user_session,
        product_id,
        category_code
),

cart_after_view AS (
    SELECT
        v.user_id,
        v.user_session,
        v.product_id,
        v.category_code,
        v.view_time,
        MIN(e.event_time) AS cart_time
    FROM first_view v
    LEFT JOIN events e
      ON e.user_id = v.user_id
     AND e.user_session = v.user_session
     AND e.product_id = v.product_id
     AND e.category_code = v.category_code
     AND e.event_type = 'cart'
     AND e.event_time >= v.view_time
    GROUP BY
        v.user_id,
        v.user_session,
        v.product_id,
        v.category_code,
        v.view_time
),

purchase_after_cart AS (
    SELECT
        c.user_id,
        c.user_session,
        c.product_id,
        c.category_code,
        c.view_time,
        c.cart_time,
        MIN(e.event_time) AS purchase_time
    FROM cart_after_view c
    LEFT JOIN events e
      ON e.user_id = c.user_id
     AND e.user_session = c.user_session
     AND e.product_id = c.product_id
     AND e.category_code = c.category_code
     AND e.event_type = 'purchase'
     AND e.event_time >= c.cart_time
    GROUP BY
        c.user_id,
        c.user_session,
        c.product_id,
        c.category_code,
        c.view_time,
        c.cart_time
),

category_funnel AS (
    SELECT
        v.category_code,
        COUNT(*) AS viewed_journeys,
        COUNT(c.cart_time) AS carted_journeys,
        COUNT(p.purchase_time) AS completed_journeys
    FROM first_view v
    LEFT JOIN cart_after_view c
      ON c.user_id = v.user_id
     AND c.user_session = v.user_session
     AND c.product_id = v.product_id
     AND c.category_code = v.category_code
    LEFT JOIN purchase_after_cart p
      ON p.user_id = c.user_id
     AND p.user_session = c.user_session
     AND p.product_id = c.product_id
     AND p.category_code = c.category_code
    GROUP BY v.category_code
)

SELECT
    category_code,
    viewed_journeys,
    carted_journeys,
    completed_journeys,

    ROUND(
        100.0 * carted_journeys
        / NULLIF(viewed_journeys, 0),
        2
    ) AS view_to_cart_pct,

    ROUND(
        100.0 * completed_journeys
        / NULLIF(carted_journeys, 0),
        2
    ) AS cart_to_purchase_pct,

    ROUND(
        100.0 * completed_journeys
        / NULLIF(viewed_journeys, 0),
        2
    ) AS overall_conversion_pct

FROM category_funnel
WHERE viewed_journeys >= 100
ORDER BY overall_conversion_pct DESC;
