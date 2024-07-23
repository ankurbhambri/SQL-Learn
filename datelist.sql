-- One approach concatenate the complete list into one row, cummulate it

/*
CREATE TABLE user_activity1 (
    userid BIGINT,
    active_dt DATE
);
	
CREATE TABLE active_user_datelist (
    userid BIGINT PRIMARY KEY,
    active_date_list DATE[]
);

INSERT INTO user_activity1 (userid, active_dt) VALUES
(123, '2022-07-10'),
(456, '2022-07-11'),
(123, '2022-07-12'),
(456, '2022-07-13'),
(123, '2022-07-13'),
(123, '2023-07-10'),
(456, '2023-07-11'),
(123, '2023-07-12'),
(456, '2023-07-07'),
(123, '2023-07-07'),
(123, '2024-07-23'),
(456, '2024-07-23'),
(123, '2024-07-22'),
(456, '2024-07-21'),
(123, '2024-07-21');
*/

insert into active_user_datelist (userid, active_date_list)
select
	userid,
	ARRAY_AGG(active_dt order by active_dt) as active_date_list
from
	user_activity1
group by userid
ON conflict(userid)
DO UPDATE SET
active_date_list = (
	SELECT ARRAY_AGG(DISTINCT d ORDER BY d)
	FROM (
		SELECT UNNEST(active_user_datelist.active_date_list) AS d
		UNION ALL
		SELECT UNNEST(EXCLUDED.active_date_list) AS d
	) AS dates
)

-- Daily active user just one row hit
	
SELECT COUNT(DISTINCT userid) AS dau
FROM active_user_datelist
WHERE current_date = ANY(active_date_list)

-- Weekly active users just one row hit for every users

SELECT COUNT(DISTINCT userid) AS wau
FROM active_user_datelist
WHERE active_date_list && ARRAY[
	CURRENT_DATE,
	CURRENT_DATE - INTERVAL '1 day',
	CURRENT_DATE - INTERVAL '2 days',
	CURRENT_DATE - INTERVAL '3 days',
	CURRENT_DATE - INTERVAL '4 days',
	CURRENT_DATE - INTERVAL '5 days',
	CURRENT_DATE - INTERVAL '6 days'
]::DATE[];