WITH checks AS (
    SELECT
        'backend_orders_count'                                   AS check_name
        , (SELECT SUM(backend_orders_count) FROM acquisition_weekly) AS output_value
        , (SELECT COUNT(order_id) FROM orders)                       AS source_value

    UNION ALL

    SELECT
        'spend'                                                  AS check_name
        , (SELECT SUM(spend) FROM acquisition_weekly)                  AS output_value
        , (SELECT SUM(spend) FROM channel_week)                                AS source_value

    UNION ALL

    SELECT
        'net_revenue'                                            AS check_name
        , (SELECT SUM(net_revenue) FROM acquisition_weekly)           AS output_value
        , (SELECT SUM(gross_revenue) FROM orders) 
        - (SELECT sum(refund_amount) FROM refunds)                          AS source_value
        --, (SELECT sum(refund_amount)*-1 FROM refunds)       AS source_value2
        
)

SELECT
    check_name
    , output_value
    , source_value
    , output_value - source_value                                AS difference
    , CASE WHEN output_value = source_value THEN 'PASS' ELSE 'FAIL' END                 AS status
FROM checks