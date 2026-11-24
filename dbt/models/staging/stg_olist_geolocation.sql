WITH raw_geo AS (
    SELECT * FROM {{ source('olist', 'geolocation_dataset') }}
)
SELECT 
    geolocation_zip_code_prefix AS zip_code,
    geolocation_lat AS latitude,
    geolocation_lng AS longitude,
    geolocation_city AS city,
    geolocation_state AS state
FROM raw_geo
-- Snowflake specific: QUALIFY deduplicates the zip codes, keeping the first geographic point
QUALIFY ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_city) = 1