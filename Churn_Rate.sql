/*

CREATE TABLE user_activity (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    activity_date DATE NOT NULL,
    activity_description TEXT
);

INSERT INTO user_activity (user_id, activity_date, activity_description) VALUES
(1, '2024-06-25', 'Logged in'),
(2, '2024-06-26', 'Viewed Dashboard'),
(1, '2024-06-27', 'Logged out'),
(3, '2024-06-28', 'Made a purchase'),
(2, '2024-06-29', 'Logged in'),
(1, '2024-07-01', 'Updated Profile'),
(3, '2024-07-02', 'Viewed Dashboard'),
(1, '2024-07-03', 'Logged in'),
(2, '2024-07-04', 'Logged out'),
(3, '2024-07-05', 'Made a purchase'),
(1, '2024-07-06', 'Logged out'),
(2, '2024-07-07', 'Updated Profile'),
(3, '2024-07-08', 'Viewed Dashboard'),
(1, '2024-07-09', 'Logged in'),
(2, '2024-07-10', 'Logged out'),
(3, '2024-07-11', 'Made a purchase'),
(1, '2024-07-12', 'Logged in'),
(2, '2024-07-13', 'Updated Profile'),
(3, '2024-07-14', 'Viewed Dashboard'),
(1, '2024-07-15', 'Logged in');

*/

-- DAU
SELECT activity_date, COUNT(DISTINCT user_id) AS dau
FROM user_activity
GROUP BY activity_date
ORDER BY activity_date;


-- Churn rate based one (# of orders / # logged in users per day)
WITH users_logged_in AS (
    SELECT DISTINCT user_id, activity_date
    FROM user_activity
    WHERE activity_description = 'Logged in'
),
users_made_purchase AS (
    SELECT DISTINCT user_id, activity_date
    FROM user_activity
    WHERE activity_description = 'Made a purchase'
),
users_added_to_cart AS (
    SELECT DISTINCT user_id, activity_date
    FROM user_activity
    WHERE activity_description = 'Added to Cart'
)
SELECT 
    l.activity_date, 
    COUNT(DISTINCT l.user_id) AS logged_in_users,
    COUNT(DISTINCT p.user_id) AS ordered_users,
    COUNT(DISTINCT c.user_id) AS added_to_cart_users,
	(COUNT(DISTINCT p.user_id) * 1.0 / COUNT(DISTINCT l.user_id)) AS churn_rate
FROM 
    users_logged_in l
LEFT JOIN 
    users_made_purchase p 
ON 
    l.user_id = p.user_id AND l.activity_date = p.activity_date
LEFT JOIN 
    users_added_to_cart c 
ON 
    l.user_id = c.user_id AND l.activity_date = c.activity_date
GROUP BY 
    l.activity_date
ORDER BY 
    l.activity_date;


SELECT * FROM pg_catalog.pg_indexes
WHERE schemaname = 'public'

explain analyze SELECT DISTINCT user_id, activity_date
    FROM user_activity
    WHERE activity_description = 'Added to Cart'

create index idx_activity_description on user_activity(activity_description)