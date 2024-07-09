/*
drop table user_activity_log

CREATE TABLE user_activity_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    activity_time TIMESTAMP
);

INSERT INTO user_activity_log (user_id, activity_time) VALUES
-- Week 1
(1, '2024-06-15 10:00:00'),
(1, '2024-06-24 10:00:00'),
(1, '2024-06-24 12:00:00'),
(1, '2024-06-25 08:30:00'),
(1, '2024-06-26 08:30:00'),
(1, '2024-06-26 09:30:00'),
(1, '2024-06-27 09:30:00'),
(2, '2024-06-24 09:15:00'),
(2, '2024-06-25 10:45:00'),
(3, '2024-06-24 11:00:00'),
(3, '2024-06-26 14:20:00'),
(3, '2024-06-26 16:00:00'),
(4, '2024-06-25 07:50:00'),
(4, '2024-06-25 09:00:00'),

-- Week 2
(5, '2024-07-01 10:10:00'),
(5, '2024-07-01 12:00:00'),
(5, '2024-07-02 18:45:00'),
(6, '2024-07-02 09:30:00'),
(6, '2024-07-02 11:45:00'),
(7, '2024-07-01 08:20:00'),
(7, '2024-07-03 10:30:00'),
(8, '2024-07-03 12:15:00'),
(8, '2024-07-03 17:00:00'),

-- Week 3
(1, '2024-07-08 10:00:00'),
(1, '2024-07-08 12:00:00'),
(1, '2024-07-09 08:30:00'),
(2, '2024-07-08 09:15:00'),
(2, '2024-07-09 10:45:00'),
(3, '2024-07-08 11:00:00'),
(3, '2024-07-10 14:20:00'),
(3, '2024-07-10 16:00:00'),
(4, '2024-07-09 07:50:00'),
(4, '2024-07-09 09:00:00'),

-- Week 4
(5, '2024-07-15 10:10:00'),
(5, '2024-07-15 12:00:00'),
(5, '2024-07-16 18:45:00'),
(6, '2024-07-16 09:30:00'),
(6, '2024-07-16 11:45:00'),
(7, '2024-07-15 08:20:00'),
(7, '2024-07-17 10:30:00'),
(8, '2024-07-17 12:15:00'),
(8, '2024-07-17 17:00:00');

*/

/* 
Which says for every user, give me all of the events from the last 7 days, 
and then extract the number of days old each event is, 
and then count the number of distinct number of days there are. 
But this was a mistake because I misunderstood two things:

The week window always begins on Monday, rather than having a rolling last-7-days. 
The week starts every week on Monday. If it is currently Wednesday, 
the maximum Lness for a user this week is 3, and tomorrow it is 4. 
Likewise, you will only see 7’s on Sunday. I want to see historically how the Lness was in prior weeks.
*/

SELECT
    user_id,
    COUNT(DISTINCT EXTRACT(DAYS FROM CURRENT_TIMESTAMP - activity_time))
 FROM user_activity_log
WHERE activity_time > CURRENT_TIMESTAMP - INTERVAL '7 days'
GROUP BY user_id


/* Which says _for every combination of user_id and iso-week from the activity_time (forget about the day of week and time), 
convert the activity_time to just the day of the week, 
and tell me how many distinct days of week there are for every combination of the first two things I queried. 
*/

select
	user_id,
	TO_DATE(To_char(activity_time, 'IYYY-"W"IW'), 'IYYY-"W"IW') as iso_week,
	COUNT(DISTINCT TO_CHAR(activity_time, 'ID')) AS lness
from
	user_activity_log
group by 1, 2
order by 2
