-- Counting 1 to N

with recursive cte as (
	select 1 as n
	union all
	select n + 1 from cte where n < 10
)
select * from cte;

-- Pairs of number like [(0, 1), (1, 2), (3, 4), (5, 6), (7, 8), (9, 10)]

WITH RECURSIVE pairs AS (
    SELECT 0 AS first_number, 1 AS second_number
    UNION ALL
    SELECT first_number + 2, second_number + 2
    FROM pairs
    WHERE first_number + 2 <= 10
)
SELECT * from pairs;

-- Classical example of employee manager finding recursively

WITH RECURSIVE cte AS (
    -- Anchor member: Select top-level managers (where manager_id is NULL)
    SELECT
		employee_id, name, manager_id
    FROM
		Employees
    WHERE
		manager_id IS NULL -- starting point with root node
    
    UNION ALL
    
    -- Recursive member: Join with Employees table to find subsequent managers
    SELECT
		e.employee_id, e.name, e.manager_id
    FROM
		Employees e
    JOIN
		cte c
	ON
		e.employee_id = c.manager_id
)
SELECT * FROM cte;
