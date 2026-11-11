CREATE VIEW acquisition_weekly AS
WITH orders_per_week AS (
    SELECT
        week_start
        , last_click_channel AS channel_
        , COUNT(order_id) AS backend_orders_count
    FROM orders
    GROUP BY 1,2
)
, new_cust AS (
    SELECT 
        orders.week_start
        , last_click_channel AS channel_
        , COUNT(customers.customer_id) AS new_customers
    FROM customers
        LEFT JOIN orders 
            ON customers.first_paid_order_id = orders.order_id
    WHERE first_paid_order_id NOT LIKE 'H%'
    GROUP BY 1,2
)
, repeated AS (
    SELECT 
        orders.week_start
        , last_click_channel AS channel_
        , COUNT(order_id) AS repeat_orders
    FROM orders
        LEFT JOIN customers
            ON orders.order_id = customers.first_paid_order_id
    WHERE first_paid_order_id IS NULL
    GROUP BY 1,2
)
, net_order AS (
    WITH refs AS (
        SELECT order_id, SUM(refund_amount) AS refund_amount
        FROM refunds
        GROUP BY 1
    )
    SELECT 
        order_id, week_start, last_click_channel
        , gross_revenue - IFNULL(refund_amount, 0) AS net_revenue
    FROM orders
        LEFT JOIN refs USING(order_id)
)
, all_net AS (
        SELECT week_start, last_click_channel
            , SUM(net_revenue) AS all_net
        FROM net_order
        GROUP BY 1,2
    )
, net_rev AS (
    SELECT 
        week_start
        , last_click_channel AS channel_
        , SUM(net_revenue) net_revenue
        , SUM(CASE WHEN first_paid_order_id IS NOT NULL THEN net_revenue ELSE 0 END) AS new_customer_net_revenue
    FROM net_order
        LEFT JOIN customers 
            ON net_order.order_id = customers.first_paid_order_id
    GROUP BY 1,2
)
, nc_cac AS (
    SELECT
        channel_week.week_start
        , channel_week.channel AS channel_
        , spend/ NULLIF(new_customers, 0) AS nc_cac
    FROM channel_week
        LEFT JOIN new_cust 
            ON channel_week.week_start = new_cust.week_start
            AND channel_week.channel = new_cust.channel_
)
, roas AS (
    SELECT
        channel_week.week_start
        , channel_week.channel              AS channel_
        , SUM(all_net) / SUM(spend)         AS backend_net_roas_
        , SUM(platform_purchases)           AS platform_purchases
        , SUM(platform_revenue)/ SUM(spend) AS platform_roas
    FROM channel_week
        LEFT JOIN all_net
            ON channel_week.week_start = all_net.week_start
            AND channel_week.channel = all_net.last_click_channel
    GROUP BY 1,2
)
SELECT channel_week.week_start, channel_week.channel

    , channel_week.spend
    , orders_per_week.backend_orders_count
    , new_cust.new_customers
    , repeated.repeat_orders
    , net_rev.net_revenue
    , net_rev.new_customer_net_revenue
    , nc_cac.nc_cac
    , roas.backend_net_roas_
    , roas.platform_purchases
    , roas.platform_roas

FROM channel_week
    LEFT JOIN orders_per_week 
        ON channel_week.week_start = orders_per_week.week_start
        AND channel_week.channel = orders_per_week.channel_
    LEFT JOIN new_cust
        ON channel_week.week_start = new_cust.week_start
        AND channel_week.channel = new_cust.channel_
    LEFT JOIN repeated
        ON channel_week.week_start = repeated.week_start
        AND channel_week.channel = repeated.channel_
    LEFT JOIN net_rev
        ON channel_week.week_start = net_rev.week_start
        AND channel_week.channel = net_rev.channel_
    LEFT JOIN nc_cac
        ON channel_week.week_start = nc_cac.week_start
        AND channel_week.channel = nc_cac.channel_
    LEFT JOIN roas
        ON channel_week.week_start = roas.week_start
        AND channel_week.channel = roas.channel_
