SELECT
    week_start
    , SUM(spend)                                   AS total_spend
    , SUM(new_customers)                           AS new_customers
    , SUM(spend) / NULLIF(SUM(new_customers), 0)   AS blended_nc_cac
    , SUM(net_revenue)                             AS net_revenue
FROM acquisition_weekly
GROUP BY week_start
ORDER BY week_start