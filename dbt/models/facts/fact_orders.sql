WITH orders AS (
    SELECT * FROM {{ ref('stg_olist_orders') }}
),
items_agg AS (
    SELECT * FROM {{ ref('int_order_items_aggregated') }}
),
payments_agg AS (
    SELECT * FROM {{ ref('int_order_payments_aggregated') }}
),
reviews AS (
    -- Take the max review score if a user submitted multiple for one order
    SELECT order_id, MAX(review_score) AS max_review_score 
    FROM {{ ref('stg_olist_reviews') }}
    GROUP BY order_id
)
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    CAST(o.order_purchase_at AS DATE) AS order_purchase_date,
    CAST(o.order_delivered_at AS DATE) AS order_delivered_date,
    -- Logistics metric: Actual time to delivery in days
    DATEDIFF(DAY, o.order_purchase_at, o.order_delivered_at) AS days_to_delivery,
    
    COALESCE(i.total_items_in_order, 0) AS total_items,
    COALESCE(i.total_product_revenue, 0) AS total_product_revenue,
    COALESCE(i.total_freight_revenue, 0) AS total_freight_revenue,
    
    COALESCE(p.total_payment_value, 0) AS total_payment_value,
    
    r.max_review_score AS review_score
FROM orders o
LEFT JOIN items_agg i ON o.order_id = i.order_id
LEFT JOIN payments_agg p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id