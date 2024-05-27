WITH RECURSIVE ManagerHierarchy AS (
    -- Anchor member: Select top-level managers (where manager_id is NULL)
    SELECT
		id, name, manager_id, 0 AS level
    FROM
		Employees
    WHERE
		manager_id IS NULL
    
    UNION ALL
    
    -- Recursive member: Join with Employees table to find subsequent managers
    SELECT
		e.id, e.name,
		e.manager_id, 
		mh.level + 1 AS level
    FROM
		Employees e
    JOIN
		ManagerHierarchy mh
	ON
		e.manager_id = mh.id
)
-- Final query: Select from the CTE to retrieve all levels of managers
SELECT * FROM ManagerHierarchy
ORDER BY level, id;




with recursive cte as (
	select 1 as n
	union all
	select n + 1 from cte where n < 10
)
select * from cte;