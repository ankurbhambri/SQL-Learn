-- Counting 1 to N numbers

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

WITH RECURSIVE employee_hierarchy AS (
    SELECT id, name, manager_id
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.name, e.manager_id
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT id, name, manager_id
FROM employee_hierarchy
ORDER BY id;


-- Count number of employees under a manager

select m.name manager_name, count(1) no_of_employees
from employees e
join employees m on e.manager_id=m.id
group by 1
order by 2 desc, 1 asc