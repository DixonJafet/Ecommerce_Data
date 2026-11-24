WITH date_spine AS (
    SELECT 
        DATEADD(DAY, SEQ4(), '2016-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 3650)) -- Generates 10 years (3650 days)
)
SELECT 
    date_day AS date,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(DAY FROM date_day) AS day,
    EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (0, 6) THEN TRUE 
        ELSE FALSE 
    END AS is_weekend
FROM date_spine