/*
	For the given friends, find the no of mutual friends

-- Create the table
CREATE TABLE friendships (
    FRIEND1 VARCHAR(50),
    FRIEND2 VARCHAR(50)
);

-- Insert data into the table
INSERT INTO friendships (FRIEND1, FRIEND2)
VALUES
    ('Jason', 'Mary'),
    ('Mike', 'Mary'),
    ('Mike', 'Jason'),
    ('Susan', 'Jason'),
    ('John', 'Mary'),
    ('Susan', 'Mary');

*/

-- WITH tmp AS (
-- SELECT user_id, friend_id FROM Friendship
-- UNION ALL
-- SELECT friend_id, user_id FROM Friendship
-- )
-- SELECT
-- 	ab.user_id
-- 	,ab.friend_id
-- 	,COUNT(*) AS common_friend
-- FROM tmp AS ab
-- JOIN tmp AS af
-- 	ON ab.user_id = af.user_id
-- JOIN tmp AS bf
-- 	ON ab.friend_id = bf.user_id
-- 	AND bf.friend_id = af.friend_id
-- GROUP BY ab.user_id, ab.friend_id
-- HAVING common_friend >= 3
-- ORDER BY common_friend DESC;


select * from friendships

with cte as (
	select FRIEND1, FRIEND2 from friendships
	union all
	select FRIEND2, FRIEND1 from friendships
)
select a.FRIEND1 a, a.FRIEND2 b, COUNT(*) AS common_friend
from cte a 
join cte b on a.FRIEND1=b.FRIEND1
join cte c on a.FRIEND2=c.FRIEND1 and c.FRIEND2=b.FRIEND2
group by 1, 2
order by 3 desc
