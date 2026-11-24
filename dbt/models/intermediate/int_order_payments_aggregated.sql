WITH payments AS (
    SELECT * FROM {{ ref('stg_olist_order_payments') }}
)
SELECT 
    order_id,
    SUM(payment_value) AS total_payment_value,
    MAX(payment_installments) AS max_installments,
    COUNT(DISTINCT payment_type) AS distinct_payment_methods
FROM payments
GROUP BY order_id