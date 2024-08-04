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
CREATE TABLE user_activity_int (
    userid BIGINT,
    active_dt DATE
);

CREATE TABLE user_activity_int (
    userid BIGINT,
    active_dt_int BIGINT
);

INSERT INTO user_activity (userid, active_dt) VALUES
(123, '2024-07-31'),
(456, '2024-07-31'),
(123, '2024-08-01'),
(456, '2024-08-01'),
(123, '2024-07-25'),
(123, '2024-07-26'),
(456, '2024-07-21'),
(123, '2024-07-22'),
(456, '2024-08-04'),
(456, '2024-08-02'),
(123, '2024-08-04');

*/

insert into user_activity_int(userid, active_dt_int)
select
	userid,
	BIT_OR(1 << (current_date - active_dt)) active_dt_int
from user_activity group by userid

select * from user_activity_int
	
-- User active on _th day, calculating diff using current date
select userid, current_date - active_dt from user_activity order by 1, 2

-- checking which user is active on 2nd day
select userid, (active_dt_int >> 2) & 1 from user_activity_int


-- custome function to count active bits in a integer
CREATE OR REPLACE FUNCTION bit_counts(num BIGINT) RETURNS INT AS $$
DECLARE
    count INT := 0;
BEGIN
    WHILE num > 0 LOOP
        count := count + (num & 1);
        num := num >> 1;
    END LOOP;
    RETURN count;
END;
$$ LANGUAGE plpgsql;
	
-- To calculate last 7 days activity Lness7 
-- Here, left shift ((1 << 7) - 1) will give 128 - 1 = 127
-- and last we are doing bitwise_and where only 1, 1 will give 1 else 0
-- once done count 1 as active days for a user
select userid, bit_counts(active_dt_int & (1 << 7) - 1) from user_activity_int
