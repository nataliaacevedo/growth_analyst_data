SELECT 
    week_start
    , channel
    , CASE WHEN sessions < product_views      THEN 'product_views funnel wrong'  ELSE 'No errors' END as product_views_check
    , CASE WHEN product_views < add_to_carts  THEN 'add_to_carts funnel wrong'   ELSE 'No errors' END as add_to_carts_check
    , CASE WHEN add_to_carts < checkouts      THEN 'checkouts funnel wrong'      ELSE 'No errors' END as checkouts_check
    , CASE WHEN checkouts < purchases         THEN 'purchases funnel wrong'      ELSE 'No errors' END as purchases_check

FROM session_funnel