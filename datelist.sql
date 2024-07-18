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
WHERE active_date_list && ARRAY(SELECT generate_series(current_date - interval '7 day', current_date - interval '1 day', '1 day'))::date[];


-- Another approach - Bitwise

/*

CREATE TABLE user_adl (
    userid BIGINT,
    activity_date DATE
);

INSERT INTO user_adl (userid, activity_date) VALUES
(456, '2024-07-07'),
(123, '2024-07-07'),
(123, '2024-07-10'),
(456, '2024-07-11'),
(123, '2024-07-12'),
(456, '2024-07-21'),
(123, '2024-07-21'),
(123, '2024-07-22');

CREATE TABLE activity_date_int_table (
    userid BIGINT PRIMARY KEY,
    activity_date_int BIGINT
);

*/

WITH date_bits AS (
    SELECT
        userid,
        -- Calculate the bit position from current_date (2 ^ day) (left bit wise).
        -- Then, BIT_OR to combine list of bitmask values.
        BIT_OR(1 << (current_date - activity_date)) AS activity_date_int
    FROM user_adl
    GROUP BY userid
	order by 2
)
INSERT INTO activity_date_int_table (userid, activity_date_int)
SELECT userid, activity_date_int
FROM date_bits
ON CONFLICT (userid)
-- here again BIT_OR from previous day value to new value
DO UPDATE SET activity_date_int = activity_date_int_table.activity_date_int | EXCLUDED.activity_date_int;

-- Way to check whether that day from current day active or not, while checking the bit is active or not (right bit wise)
select userid, (activity_date_int >> 1) & 1 from activity_date_int_table

-- Testing....
UPDATE activity_date_int_table
SET activity_date_int = activity_date_int | (1 << (CURRENT_DATE - '2024-07-22'::date))
WHERE userid = 456;

with cte as (select generate_series(current_date - interval '7 day', current_date - interval '1 day', '1 day') rg)
select
	userid, rg,
	(activity_date_int >> (CURRENT_DATE - rg::date)) & 1 as active
from cte cross join activity_date_int_table
group by 1,2
order by rg desc