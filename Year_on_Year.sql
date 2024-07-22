-- window function to calculate a rolling average. For simplicity, let's use a 7-day rolling average.

-- DAU YoY Growth Rate

/*
CREATE TABLE user_activity (
    user_id INT,
    activity_date DATE
);

-- Sample data for January 2024
INSERT INTO user_activity (user_id, activity_date) VALUES
(1, '2024-01-01'), (2, '2024-01-01'), (3, '2024-01-01'),
(1, '2024-01-02'), (2, '2024-01-02'), (4, '2024-01-02'),
(1, '2024-01-03'), (3, '2024-01-03'), (4, '2024-01-03'),
(2, '2024-01-04'), (3, '2024-01-04'), (5, '2024-01-04'),
(1, '2024-01-05'), (2, '2024-01-05'), (5, '2024-01-05'),
(3, '2024-01-06'), (4, '2024-01-06'), (5, '2024-01-06'),
(1, '2024-01-07'), (2, '2024-01-07'), (3, '2024-01-07');

-- Sample data for January 2023
INSERT INTO user_activity (user_id, activity_date) VALUES
(1, '2023-01-01'), (2, '2023-01-01'),
(1, '2023-01-02'), (3, '2023-01-02'),
(2, '2023-01-03'), (4, '2023-01-03'),
(1, '2023-01-04'), (3, '2023-01-04'),
(2, '2023-01-05'), (4, '2023-01-05'),
(1, '2023-01-06'), (3, '2023-01-06'),
(2, '2023-01-07'), (4, '2023-01-07');

*/


WITH daily_dau AS (
    SELECT 
        activity_date,
        COUNT(DISTINCT user_id) AS daily_active_users
    FROM 
        user_activity
    GROUP BY 
        activity_date
),
yoy_growth AS (
    SELECT
        current_year.activity_date,
        current_year.daily_active_users,
        previous_year.daily_active_users AS previous_year_daily_active_users,
        (current_year.daily_active_users::FLOAT / previous_year.daily_active_users - 1) * 100 AS yoy_growth_rate
    FROM 
        daily_dau current_year
    LEFT JOIN 
        daily_dau previous_year 
    ON 
        current_year.activity_date = previous_year.activity_date + INTERVAL '1 year'
)
SELECT
    activity_date,
    daily_active_users,
    yoy_growth_rate,
    AVG(yoy_growth_rate) OVER (
        ORDER BY activity_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_yoy_growth_rate
FROM 
    yoy_growth
ORDER BY 
    activity_date;

-- MAU YoY Growth Rate

with mau as(
	select
		date_trunc('month', activity_date) activity_date,
		count(DISTINCT user_id) cn
	from
		user_activity
	group by
		date_trunc('month', activity_date)
	order by 1
),
mau_yoy_growth as(
	select
		a.cn mau, a.activity_date,
		round(((a.cn - b.cn) * 100.0 / b.cn), 2) mau_yoy
	from
		mau a join mau b on a.activity_date = b.activity_date + interval '1 year'
)
select
	activity_date, mau, mau_yoy,
	round(avg(mau_yoy) over(order by activity_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) r_yoy
from
	mau_yoy_growth




/*

CREATE TABLE revenue (
    transaction_date DATE,
    total_revenue NUMERIC
);

-- Sample data for 2023 and 2024
INSERT INTO revenue (transaction_date, total_revenue) VALUES
('2023-01-01', 1000), ('2023-01-02', 1100), ('2023-01-03', 1050), 
('2023-01-04', 1200), ('2023-01-05', 1250), ('2023-01-06', 1300), 
('2023-01-07', 1400), ('2023-02-01', 1500), ('2023-02-02', 1600),
('2023-02-03', 1700), ('2023-02-04', 1800), ('2023-02-05', 1900),
('2024-01-01', 2000), ('2024-01-02', 2200), ('2024-01-03', 2100), 
('2024-01-04', 2400), ('2024-01-05', 2500), ('2024-01-06', 2600), 
('2024-01-07', 2800), ('2024-02-01', 3000), ('2024-02-02', 3200),
('2024-02-03', 3400), ('2024-02-04', 3600), ('2024-02-05', 3800);
*/

with dau as (select distinct transaction_date, sum(total_revenue) sm from revenue group by transaction_date order by transaction_date),
dau_yoy_revenue as (
	select a.transaction_date, ((a.sm - b.sm) * 100.0) / b.sm from dau a join dau b on a.transaction_date=b.transaction_date + interval '1 year'
)
select * from dau_yoy_revenue

