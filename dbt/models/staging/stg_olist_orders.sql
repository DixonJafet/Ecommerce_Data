WITH raw_orders AS (
    SELECT * FROM {{ source('olist', 'orders_dataset') }}
)
SELECT 
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_at,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_shipped_at,
    -- Fix "time travel" anomalies by nullifying delivery dates that occur before purchase
    CASE 
        WHEN CAST(order_delivered_customer_date AS TIMESTAMP) < CAST(order_purchase_timestamp AS TIMESTAMP) THEN NULL 
        ELSE CAST(order_delivered_customer_date AS TIMESTAMP) 
    END AS order_delivered_at,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_at
FROM raw_orders