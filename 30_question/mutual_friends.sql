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

with cte as (
	select FRIEND1, FRIEND2 from friendships
	union all
	select FRIEND2, FRIEND1 from friendships
),
cte2 as (
	select FRIEND1, string_agg(FRIEND2, ',') agg from cte group by FRIEND1
),
cte3 as (
	select
		f.FRIEND1, c.agg f1, f.FRIEND2, c2.agg f2
	from friendships f 
	left join cte2 c on f.FRIEND1=c.FRIEND1	
	left join cte2 c2 on f.FRIEND2=c2.FRIEND1
)
	-- select * from cte3
select FRIEND1, FRIEND2, string_to_array(f1, ',') && string_to_array(f2, ',') from cte3

