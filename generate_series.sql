/* 
Input

id | item | count 
----+------+-------
  1 | NYC  |     2
  2 | KYC  |     1
  3 | PYC  |     4

Output

id | item 
----+------
  1 | NYC
  1 | NYC
  2 | KYC
  3 | PYC
  3 | PYC
  3 | PYC
  3 | PYC

*/

CREATE TABLE item_counts (
    id  INT,
    item VARCHAR(3),
    count INT
);

INSERT INTO item_counts (id, item, count) VALUES
(1, 'NYC', 2),
(2, 'KYC', 1),
(3, 'PYC', 4);

-- Recursively
with recursive cte as (
  select id, item, count, 1 as start
  from item_counts
  union all
  select id, item, count, 1 + start
  from cte
  where start < count
)
select id, item from cte order by id;

-- Using window function
select id, item, generate_series(1, count) from item_counts;
