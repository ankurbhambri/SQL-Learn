/*

CREATE TABLE user_activity (
    userid BIGINT,
    active_dt DATE
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
	
CREATE TABLE active_user_datelist (
    userid BIGINT PRIMARY KEY,
    active_date_list DATE[]
);

CREATE TABLE user_activity_int (
    userid BIGINT,
    active_dt_int BIGINT
);

*/


/*
    ###### ###### ###### ###### ###### ######
    First approach concatenate the complete list into one row, cummulate it
    ###### ###### ###### ###### ###### ######
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


/*

###### ###### ###### ###### ###### ######
Another approach - Bitwise operation
###### ###### ###### ###### ######## ######

Prequesites
1. 1 << number is equivalent to 2 ^ n this is called left bitwise operator

*/

/*
    BIT_OR(1 << (current_date - active_dt)) AS active_dt_int:

    1 << (current_date - active_dt): This part calculates a bitmask where active_dt (activity date) is shifted left by the 
    difference in days between the current date and active_dt. This creates a binary value where only the bit corresponding to active_dt is set to 1

    For example userid = 1:

        For active_dt = 2024-07-31:
        current_date - active_dt = 2024-08-04 - 2024-07-31 = 4 days
        1 << 4 = 00010000 (binary) which is 16 (decimal)

        For active_dt = 2024-08-01:
        current_date - active_dt = 2024-08-04 - 2024-08-01 = 3 days
        1 << 3 = 00001000 (binary) which is 8 (decimal)

        For active_dt = 2024-08-03:
        current_date - active_dt = 2024-08-04 - 2024-08-03 = 1 day
        1 << 1 = 00000010 (binary) which is 2 (decimal)

        Combine bitmasks using - BIT_OR (16 | 8 | 2) = 26 (binary 00011010)

        Finally, Will save the 26 for this user = 1, in our db to query for the nth day user is active or not

*/


insert into user_activity_int(userid, active_dt_int)
select
	userid,
	BIT_OR(1 << (current_date - active_dt)) active_dt_int
from user_activity group by userid
	
-- To check, user is active on _th day, calculating diff using current date.
select userid, current_date - active_dt from user_activity order by 1, 2

-- Checking whether user is active on 2nd day or not.
select userid, (active_dt_int >> 2) & 1 from user_activity_int


-- Custom function to count active bits in an integer

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


/*
    To calculate user activity over the last 7 days (Lness7):

    We use a bitwise operation to check if the user was active on each of the last 7 days.
    Here's a step-by-step breakdown of the approach:

    1. Calculate the bitmask for the last 7 days:
        We use a bit shift operation to create a bitmask where the last 7 bits are set to 1.
        The expression (1 << 7) - 1 shifts the binary value 1 seven places to the left, 
        then subtracts 1 to set the last 7 bits to 1. This results in a bitmask of 1111111 (binary), or 127 (decimal).

    2. Apply the bitwise AND operation:
        By performing a bitwise AND between the user's activity bitmask and the 7-day bitmask, 
        we isolate the bits representing activity within the last 7 days.

    3. Count the number of active days:
        Count the number of 1s in the result of the bitwise AND operation to determine how many days the user was active in the last 7 days.

    4. By subtracting 1 from 128, you turn the binary number 10000000 into 01111111. 

*/

select 
    userid, 
    bit_counts(active_dt_int & (1 << 7) - 1) as active_days_last_7 
from user_activity_int
