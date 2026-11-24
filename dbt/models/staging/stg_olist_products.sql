WITH raw_products AS (
    SELECT * FROM {{ source('olist', 'products_dataset') }}
),
translations AS (
    SELECT * FROM {{ source('olist', 'product_category_name_translation') }}
)
SELECT 
    p.product_id,
    COALESCE(t.product_category_name_english, 'Unknown Category') AS product_category,
    p.product_name_lenght AS name_length,
    p.product_description_lenght AS description_length,
    p.product_photos_qty AS photos_qty,
    p.product_weight_g AS weight_g,
    p.product_length_cm AS length_cm,
    p.product_height_cm AS height_cm,
    p.product_width_cm AS width_cm
FROM raw_products p
LEFT JOIN translations t 
    ON p.product_category_name = t.product_category_name


    