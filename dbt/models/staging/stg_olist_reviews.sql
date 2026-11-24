SELECT 
    review_id,
    order_id,
    review_score,
    -- Replace line breaks with spaces to avoid dashboard/CSV export issues
    REPLACE(REPLACE(review_comment_title, '\n', ' '), '\r', ' ') AS review_title,
    REPLACE(REPLACE(review_comment_message, '\n', ' '), '\r', ' ') AS review_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_created_at,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answered_at
FROM {{ source('olist', 'order_reviews_dataset') }}