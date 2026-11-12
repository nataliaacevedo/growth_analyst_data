SELECT
    sessions.week_start                                                         AS session_week
    , sessions.channel
    , COUNT(orders.order_id)                                                    AS paid_orders
    , COUNT(DISTINCT orders.session_id)                                         AS purchasing_sessions
    , COUNT(orders.order_id) - COUNT(DISTINCT orders.session_id)                AS extra_orders_same_session
    , SUM(CASE WHEN orders.week_start <> sessions.week_start THEN 1 ELSE 0 END) AS orders_paid_in_other_week
FROM orders
    INNER JOIN sessions USING (session_id)
GROUP BY 1,2