/*
CREATE TABLE user_activity (
    user_id INT,
    activity_date DATE
    -- PRIMARY KEY (user_id)
);

INSERT INTO user_activity (user_id, activity_date) VALUES
(1, '2024-07-01'),
(1, '2024-06-20'),
(1, '2024-06-11'),
(1, '2024-07-14'),	
(1, '2024-07-15'),		
(2, '2024-07-10'),
(2, '2024-07-01'),
(2, '2024-06-30'),
(3, '2024-06-01'),
(3, '2024-05-20'),
(3, '2024-05-15'),
(4, '2024-07-12'),
(4, '2024-07-11'),
(4, '2024-07-10'),
(5, '2024-07-01'),
(5, '2024-06-20'),
(5, '2024-06-18'),
(6, '2024-06-05'),
(6, '2024-05-28'),
(6, '2024-05-20'),
(7, '2024-07-13'),
(7, '2024-07-10'),
(7, '2024-06-30'),
(8, '2024-06-29'),
(8, '2024-06-28'),
(8, '2024-06-27'),
(9, '2024-07-12'),
(9, '2024-07-10'),
(9, '2024-07-05'),
(10, '2024-06-15'),
(10, '2024-06-01'),
(10, '2024-05-15'),
(1, '2024-07-13'),
(1, '2024-07-12'),
(1, '2024-07-10'),
(2, '2024-06-15'),
(2, '2024-06-14'),
(2, '2024-06-13'),
(3, '2024-07-11'),
(3, '2024-07-09'),
(3, '2024-07-07'),
(4, '2024-06-20'),
(4, '2024-06-18'),
(4, '2024-06-16'),
(5, '2024-07-13'),
(5, '2024-07-12'),
(5, '2024-07-12'),
(5, '2024-07-11'),
(6, '2024-07-10'),
(6, '2024-07-09'),
(6, '2024-07-08'),
(7, '2024-06-20'),
(7, '2024-06-18'),
(7, '2024-06-16');

*/

-- Simple scenario 
-- a) Find out the users who have no activity in the system for last 15 days as Churn users
-- b) Users who have activity in our system from last 7 days is active or active users

with churn_users as (
	select user_id, max(activity_date) from user_activity group by user_id having max(activity_date) <= current_date - interval '15 days'
), retention_users as (
	select user_id, activity_date from user_activity where activity_date >=  current_date - interval '7 days'
)
select 'churn_users', count(1) from churn_users
union all 
select 'retention_users', count(1) from retention_users

-- Let's say atleat 3 activity is required to consider active user
select user_id, STRING_AGG(distinct activity_date::varchar, ' , ') 
from user_activity 
where activity_date >=  current_date - interval '7 days' 
group by user_id having count(1) >= 3 
order by 1


-- One mistake that we did here,

/*

The week window always begins on Monday, rather than having a rolling last-7-days. 
The week starts every week on Monday. If it is currently Wednesday, 
the maximum Lness for a user this week is 3, and tomorrow it is 4. 
Likewise, you will only see 7’s on Sunday.
	
How we can see historically and how the Lness was in prior weeks for users.

*/

SELECT 
	user_id,
	DATE_TRUNC('week', activity_date) AS week_start,
	COUNT(DISTINCT activity_date) AS Lness
FROM 
	user_activity
GROUP BY 1, 2
having COUNT(DISTINCT activity_date) >= 3


-- Lets do this one,
/*

Weekly Active Users: Users who have logged in at least once in a given week.
Average Lness: Average number of logins per active user per week.
Churn Analysis: Identifying users who were active in previous weeks but have not been active recently.

*/
WITH weekly_activity AS (
    SELECT 
        user_id,
        DATE_TRUNC('week', activity_date) AS week_start,
        COUNT(DISTINCT activity_date) AS Lness,
        COUNT(DISTINCT CASE WHEN activity_date >= CURRENT_DATE - INTERVAL '7 days' THEN activity_date END) AS is_active_current_week
    FROM 
        user_activity
    WHERE 
        activity_date >= CURRENT_DATE - INTERVAL '56 days'  -- Analyzing activity over the last 8 weeks
    GROUP BY 
        user_id, DATE_TRUNC('week', activity_date)
),
weekly_summary AS (
    SELECT 
        week_start,
        COUNT(DISTINCT user_id) AS weekly_active_users,
        AVG(Lness) AS average_Lness
    FROM 
        weekly_activity
    GROUP BY 
        week_start
),
churn_analysis AS (
    SELECT 
        user_id,
        MAX(week_start) AS last_active_week
    FROM 
        weekly_activity
    GROUP BY 
        user_id
    HAVING 
        MAX(week_start) < CURRENT_DATE - INTERVAL '7 days'
)
SELECT 
    ws.week_start,
    COALESCE(ws.weekly_active_users, 0) AS weekly_active_users,
    COALESCE(ws.average_Lness, 0) AS average_Lness,
    COUNT(ca.user_id) AS churned_users
FROM 
    weekly_summary ws
LEFT JOIN 
    churn_analysis ca ON ws.week_start = ca.last_active_week
GROUP BY 
    ws.week_start, ws.weekly_active_users, ws.average_Lness
ORDER BY 
    ws.week_start DESC;


