WITH items AS (
    SELECT * FROM {{ ref('stg_olist_order_items') }}
)
SELECT 
    order_id,
    COUNT(order_item_id) AS total_items_in_order,
    COUNT(DISTINCT product_id) AS unique_products_in_order,
    SUM(price) AS total_product_revenue,
    SUM(freight_value) AS total_freight_revenue
FROM items
GROUP BY order_id