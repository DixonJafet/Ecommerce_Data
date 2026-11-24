WITH products AS (
    SELECT * FROM {{ ref('stg_olist_products') }}
)
SELECT 
    product_id,
    product_category,
    name_length,
    description_length,
    photos_qty,
    weight_g,
    -- Calculate volume in cubic centimeters
    (length_cm * height_cm * width_cm) AS volume_cm3
FROM products