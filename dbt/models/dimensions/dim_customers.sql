WITH customers AS (
    SELECT * FROM {{ ref('stg_olist_customers') }}
),
geo AS (
    SELECT * FROM {{ ref('stg_olist_geolocation') }}
)
SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.zip_code,
    c.city,
    c.state,
    g.latitude,
    g.longitude
FROM customers c
LEFT JOIN geo g 
    ON c.zip_code = g.zip_code