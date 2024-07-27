/*

-- Create the active_users_daily table
CREATE TABLE active_users_daily (
    user_id INT,
    is_active_today INT,
    num_likes INT,
    num_comments INT,
    num_shares INT,
    snapshot_date DATE,
    PRIMARY KEY (user_id, snapshot_date)
);

-- Create the active_users_cumulated table
CREATE TABLE active_users_cumulated (
    user_id INT PRIMARY KEY,
    activity_array INT[],
    like_array INT[],
    comment_array INT[],
    share_array INT[],
    snapshot_date DATE
);

-- Insert sample data into active_users_daily
INSERT INTO active_users_daily (user_id, is_active_today, num_likes, num_comments, num_shares, snapshot_date)
VALUES
    (1, 1, 5, 2, 1, CURRENT_DATE),
    (2, 1, 3, 0, 2, CURRENT_DATE),
    (3, 0, 1, 3, 1, CURRENT_DATE),
    (1, 1, 2, 1, 0, CURRENT_DATE - INTERVAL '1 day'),
    (2, 0, 0, 1, 1, CURRENT_DATE - INTERVAL '1 day'),
    (3, 1, 4, 1, 2, CURRENT_DATE - INTERVAL '1 day');

-- Insert sample data into active_users_cumulated
INSERT INTO active_users_cumulated (user_id, activity_array, like_array, comment_array, share_array, snapshot_date)
VALUES
    (1, ARRAY[1, 2], ARRAY[4, 3], ARRAY[1, 1], ARRAY[0, 1], CURRENT_DATE - INTERVAL '2 days'),
    (2, ARRAY[0, 1], ARRAY[2, 0], ARRAY[2, 0], ARRAY[1, 1], CURRENT_DATE - INTERVAL '2 days');


*/

-- in postgresql, array index starts from 1 and we want to remove the first element from the array which is the oldest value.
-- Old at front and New at rear.


WITH yesterday AS (
    SELECT * 
    FROM active_users_cumulated
    WHERE snapshot_date = CURRENT_DATE - INTERVAL '2 day'
),
today AS (
    SELECT * 
    FROM active_users_daily
    WHERE snapshot_date = CURRENT_DATE
),
combined AS (
    SELECT
        COALESCE(y.user_id, t.user_id) AS user_id,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.activity_array) < 30 THEN
                    ARRAY[COALESCE(t.is_active_today, 0)] || y.activity_array
                ELSE
                    ARRAY[COALESCE(t.is_active_today, 0)] || y.activity_array[2: 30]
            END,
            ARRAY[t.is_active_today]
        ) AS activity_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.like_array) < 30 THEN
                    ARRAY[COALESCE(t.num_likes, 0)] || y.like_array
                ELSE
                    ARRAY[COALESCE(t.num_likes, 0)] || y.like_array[2: 30]
            END,
            ARRAY[t.num_likes]
        ) AS like_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.comment_array) < 30 THEN
                    ARRAY[COALESCE(t.num_comments, 0)] || y.comment_array
                ELSE
                    ARRAY[COALESCE(t.num_comments, 0)] || y.comment_array[2: 30]
            END,
            ARRAY[t.num_comments]
        ) AS comment_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.share_array) < 30 THEN
                    ARRAY[COALESCE(t.num_shares, 0)] || y.share_array
                ELSE
                    ARRAY[COALESCE(t.num_shares, 0)] || y.share_array[2: 30]
            END,
            ARRAY[t.num_shares]
        ) AS share_array,
        t.snapshot_date
    FROM yesterday y
    FULL OUTER JOIN today t
    ON y.user_id = t.user_id
)
-- Upsert into the cumulative table
INSERT INTO active_users_cumulated (user_id, activity_array, like_array, comment_array, share_array, snapshot_date)
SELECT
    user_id,
    activity_array,
    like_array,
    comment_array,
    share_array,
    snapshot_date
FROM combined
ON CONFLICT (user_id) 
DO UPDATE SET
    activity_array = EXCLUDED.activity_array,
    like_array = EXCLUDED.like_array,
    comment_array = EXCLUDED.comment_array,
    share_array = EXCLUDED.share_array,
    snapshot_date = EXCLUDED.snapshot_date;