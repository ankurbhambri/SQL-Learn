/*

Given a log table (user_id, date, send_on_ios, send_on_android)

    - Find out how many times each user signed in a day?
    - How many messages were sent?
    - First sign-in date?
    - How many messages were sent since the first sign-in date?
    - Whether the user is active today?

*/

-- 1) Sessionisation for login if no events are there.

with cte as (
	select
		user_id,
		event_time,
		case when extract(epoch from (event_time - lag(event_time) over(partition by user_id order by event_time))) >= 30 * 60 then 1 else 0 end as session_diff
	from user_sessions
)
, session_groups as (
	select user_id, event_time, sum(session_diff) over(partition by user_id order by event_time) diff from cte
)
select user_id, count(distinct diff) from session_groups group by user_id order by 1


-- 2) How many messages were sent?

select user_id, count(1) from user_sessions WHERE event_type = 'message_sent' group by user_id, event_time

-- 3) First sign-in date?
select user_id, min(event_time) from user_sessions group by user_id, event_time

-- 4) How many messages were sent since the first sign-in date?

-- 5) Whether the user is active today?

select distinct user_id from user_sessions where date = CURRENT_DATE()

s