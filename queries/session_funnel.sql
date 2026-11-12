WITH all_sessions AS (
    SELECT 
        session_id
        , started_at
        , week_start
        , channel
        , started_at AS occurred_at
        , 'session' AS event_type
    FROM sessions

)

, product_view AS (
    WITH stg AS ( 
        SELECT
            sessions.session_id
            , sessions.started_at
            , sessions.week_start
            , channel
            , occurred_at
            , event_type
            , ROW_NUMBER() OVER(PARTITION BY funnel_events.session_id ORDER BY occurred_at ASC) AS rn
        FROM sessions
            LEFT JOIN funnel_events USING (session_id)
        WHERE (unixepoch(occurred_at) - unixepoch(started_at)) < (24 * 3600)
            AND occurred_at >= started_at
            AND event_type = 'view_item'
        )
    SELECT * FROM stg WHERE rn = 1
)

, add_to_cart AS (
    WITH stg AS ( 
        SELECT 
            product_view.session_id
            , product_view.started_at
            , product_view.week_start
            , product_view.channel
            , funnel_events.occurred_at
            , funnel_events.event_type
            , ROW_NUMBER() OVER(PARTITION BY funnel_events.session_id ORDER BY funnel_events.occurred_at ASC) AS rn
        FROM product_view
            LEFT JOIN funnel_events USING (session_id)
        WHERE funnel_events.occurred_at >= product_view.occurred_at
            AND (unixepoch(funnel_events.occurred_at) - unixepoch(product_view.started_at)) < (24 * 3600)
            AND funnel_events.event_type = 'add_to_cart'
    )
    SELECT * FROM stg WHERE rn = 1
)

, checkout AS (
    WITH stg AS ( 
        SELECT 
            add_to_cart.session_id
            , add_to_cart.started_at
            , add_to_cart.week_start
            , add_to_cart.channel
            , funnel_events.occurred_at
            , funnel_events.event_type
            , ROW_NUMBER() OVER(PARTITION BY funnel_events.session_id ORDER BY funnel_events.occurred_at ASC) AS rn
        FROM add_to_cart
            LEFT JOIN funnel_events USING (session_id)
        WHERE funnel_events.occurred_at >= add_to_cart.occurred_at
            AND (unixepoch(funnel_events.occurred_at) - unixepoch(add_to_cart.started_at)) < (24 * 3600)
            AND funnel_events.event_type = 'begin_checkout'
    )
    SELECT * FROM stg WHERE rn = 1
)

, purchase AS (
    WITH stg AS (
    SELECT 
        checkout.session_id
        , checkout.started_at
        , checkout.week_start
        , checkout.channel
        , paid_at AS occurred_at
        , 'Purchase' AS event_type
        , ROW_NUMBER() OVER(PARTITION BY orders.session_id ORDER BY paid_at) AS rn
    FROM checkout
        INNER JOIN orders USING (session_id)
    WHERE paid_at >= checkout.occurred_at
        AND (unixepoch(paid_at) - unixepoch(checkout.started_at)) < (24 * 3600)
    )
    SELECT * FROM stg WHERE rn = 1
)

, funnel AS (
    SELECT session_id, week_start, channel, event_type FROM all_sessions
    UNION ALL
    SELECT session_id, week_start, channel, event_type FROM product_view
    UNION ALL
    SELECT session_id, week_start, channel, event_type FROM add_to_cart
    UNION ALL
    SELECT session_id, week_start, channel, event_type FROM checkout
    UNION ALL
    SELECT session_id, week_start, channel, event_type FROM purchase
)

, final AS (
    SELECT
    week_start
    , channel
    , COUNT(DISTINCT CASE WHEN event_type = 'session'        THEN session_id END) AS sessions
    , COUNT(DISTINCT CASE WHEN event_type = 'view_item'      THEN session_id END) AS product_views
    , COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN session_id END) AS add_to_carts
    , COUNT(DISTINCT CASE WHEN event_type = 'begin_checkout' THEN session_id END) AS checkouts
    , COUNT(DISTINCT CASE WHEN event_type = 'Purchase'       THEN session_id END) AS purchases
FROM funnel
GROUP BY week_start, channel
ORDER BY week_start, channel
)

SELECT
    week_start
    , channel
    , sessions
    , product_views
    , add_to_carts
    , checkouts
    , purchases
    , product_views * 1.0 / NULLIF(sessions, 0)       AS session_to_view_rate
    , add_to_carts  * 1.0 / NULLIF(product_views, 0)  AS view_to_cart_rate
    , checkouts     * 1.0 / NULLIF(add_to_carts, 0)   AS cart_to_checkout_rate
    , purchases     * 1.0 / NULLIF(checkouts, 0)      AS checkout_to_purchase_rate
    , checkouts     * 1.0 / NULLIF(sessions, 0)       AS session_to_checkout_rate
FROM counts
ORDER BY week_start, channel