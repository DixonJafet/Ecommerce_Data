WITH items AS (
    SELECT * FROM {{ ref('stg_olist_order_items') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_olist_orders') }}
)
SELECT 
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    o.customer_id,
    CAST(o.order_purchase_at AS DATE) as order_purchase_at,
    i.price,
    i.freight_value,
    CAST(i.shipping_limit_at AS DATE) as shipping_limit_at
FROM items i
LEFT JOIN orders o 
    ON i.order_id = o.order_id