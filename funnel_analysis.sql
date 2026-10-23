-- Dataset: eCommerce Behavior Data from Multi-Category Store
-- File: 2019-Nov.csv
--
-- Available source columns:
-- event_time     : Timestamp of the event
-- event_type     : Event type (view, cart, remove_from_cart, purchase, etc.)
-- product_id     : Identifier of the product
-- category_id    : Identifier of the product category
-- category_code  : Hierarchical product category, when available
-- brand          : Product brand, when available
-- price          : Product price
-- user_id        : Identifier of the user
-- user_session   : Identifier of the user session
--
-- Columns used in this funnel query:
-- event_time, event_type, product_id, user_id, user_session
--
-- Journey grain: user_id + user_session + product_id
--
-- Result: To count total number of products viewed, added to cart and purchased such that time required to purchase> time required to add to cart> time required to view creating a proper funnel and 
-- finally find the cart to view percentage, purchase to cart percentage and successful funnel percentage
-- IMPORTANT:
-- Update the file path below to match your Kaggle environment.
-- Run this query against the raw November 2019 CSV.

WITH events AS (
    SELECT
        user_id,
        user_session,
        product_id,
        event_type,
        event_time
    FROM read_csv_auto(
        '/kaggle/input/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store/2019-Nov.csv'
    )
    WHERE event_type IN ('view', 'cart', 'purchase')
      AND user_id IS NOT NULL
      AND user_session IS NOT NULL
      AND product_id IS NOT NULL
),

first_view AS (
    SELECT
        user_id,
        user_session,
        product_id,
        MIN(event_time) AS view_time
    FROM events
    WHERE event_type = 'view'
    GROUP BY user_id, user_session, product_id
),

cart_after_view AS (
    SELECT
        v.user_id,
        v.user_session,
        v.product_id,
        v.view_time,
        MIN(e.event_time) AS cart_time
    FROM first_view v
    LEFT JOIN events e
      ON e.user_id = v.user_id
     AND e.user_session = v.user_session
     AND e.product_id = v.product_id
     AND e.event_type = 'cart'
     AND e.event_time >= v.view_time
    GROUP BY
        v.user_id,
        v.user_session,
        v.product_id,
        v.view_time
),

purchase_after_cart AS (
    SELECT
        c.user_id,
        c.user_session,
        c.product_id,
        c.view_time,
        c.cart_time,
        MIN(e.event_time) AS purchase_time
    FROM cart_after_view c
    LEFT JOIN events e
      ON e.user_id = c.user_id
     AND e.user_session = c.user_session
     AND e.product_id = c.product_id
     AND e.event_type = 'purchase'
     AND e.event_time >= c.cart_time
    GROUP BY
        c.user_id,
        c.user_session,
        c.product_id,
        c.view_time,
        c.cart_time
),

funnel_counts AS (
    SELECT
        (SELECT COUNT(*) FROM first_view) AS viewed_journeys,
        (SELECT COUNT(*) FROM cart_after_view) AS cart_after_view,
        (SELECT COUNT(*) FROM purchase_after_cart) AS completed_sequentially
)

SELECT
    viewed_journeys,
    cart_after_view,
    completed_sequentially,

    ROUND(
        100.0 * cart_after_view
        / NULLIF(viewed_journeys, 0),
        2
    ) AS view_to_cart_pct,

    ROUND(
        100.0 * completed_sequentially
        / NULLIF(cart_after_view, 0),
        2
    ) AS cart_to_purchase_pct,

    ROUND(
        100.0 * completed_sequentially
        / NULLIF(viewed_journeys, 0),
        2
    ) AS overall_conversion_pct

FROM funnel_counts;
