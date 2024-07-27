-- Daily Active Users (DAU)

SELECT
    activity_date,
    COUNT(DISTINCT user_id) AS dau
FROM
    user_activity_log
GROUP BY
    activity_date
ORDER BY
    activity_date;


-- Weekly Active Users (WAU)	

SELECT
    DATE_TRUNC('week', activity_timestamp) AS week_start,
    COUNT(DISTINCT user_id) AS wau
FROM
    user_activity_log
GROUP BY
    week_start
ORDER BY
    week_start;


-- Monthly Active Users (MAU)

SELECT
    DATE_TRUNC('month', activity_timestamp) AS month_start,
    COUNT(DISTINCT user_id) AS mau
FROM
    user_activity_log
GROUP BY
    month_start
ORDER BY
    month_start;


-- User Retention

WITH first_week AS (
    SELECT
        user_id,
        MIN(DATE(activity_timestamp)) AS first_week
    FROM
        user_activity_log
    GROUP BY
        user_id
),
retention AS (
    SELECT
        f.first_week,
        DATE_TRUNC('week', u.activity_timestamp) AS activity_week,
        COUNT(DISTINCT u.user_id) AS retained_users
    FROM
        first_week f
    LEFT JOIN
        user_activity_log u
    ON
        f.user_id = u.user_id
        AND DATE_TRUNC('week', u.activity_timestamp) > f.first_week
    GROUP BY
        f.first_week, activity_week
)
SELECT
    first_week,
    activity_week,
    retained_users,
    ROUND((retained_users::DECIMAL / COUNT(DISTINCT user_id) OVER (PARTITION BY first_week))*100, 2) AS retention_rate
FROM
    retention
ORDER BY
    first_week, activity_week;


-- User Churn Rate

WITH user_activity AS (
    SELECT
        user_id,
        MAX(DATE(activity_timestamp)) AS last_active_date
    FROM
        user_activity_log
    GROUP BY
        user_id
),
churned_users AS (
    SELECT
        user_id
    FROM
        user_activity
    WHERE
        last_active_date < CURRENT_DATE - INTERVAL '30 days'
)
SELECT
    COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM users) * 100 AS churn_rate
FROM
    churned_users;

-- User Engagement

SELECT
    DATE(activity_timestamp) AS activity_date,
    COUNT(*) AS total_engagements,
    AVG(engagement_count) AS avg_engagements_per_user
FROM (
    SELECT
        user_id,
        DATE(activity_timestamp) AS activity_date,
        COUNT(*) AS engagement_count
    FROM
        user_activity_log
    GROUP BY
        user_id, activity_date
) sub
GROUP BY
    activity_date
ORDER BY
    activity_date;


-- Conversion Rate

SELECT
    COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM users) * 100 AS conversion_rate
FROM
    user_premium_subscriptions
WHERE
    subscription_start_date >= CURRENT_DATE - INTERVAL '30 days';


-- Revenue Metrics

SELECT
    DATE(payment_date) AS payment_date,
    SUM(amount) AS daily_revenue
FROM
    user_payments
GROUP BY
    payment_date
ORDER BY
    payment_date

-- Customer Acquisition Cost (CAC)

SELECT
    SUM(marketing_expense) / COUNT(DISTINCT user_id) AS cac
FROM
    marketing_expenses, users
WHERE
    signup_date >= marketing_start_date
    AND signup_date <= marketing_end_date;


-- Lifetime Value (LTV)

with total_revenue as (
	select
		user_id, sum(amount) sm
	from
		user_payments
	group by user_id
),
life_span as (
	select
		user_id, MAX(payment_date) - MIN(payment_date) AS lifetime_days
	from
		user_payments
	group by user_id
)
select
	round(avg(sm), 2) avg_lifetime_value,
	round(avg(lifetime_days), 2) avg_user_lifetime 
from
	total_revenue a
join
	life_span b 
on
	a.user_id=b.user_id