
-- Employee Table
-- - id
-- - first_name
-- - last_name
-- - salary
-- - dept_id


-- Departement
-- - id
-- - name


-- Find top 3 dept , atleast 10 employees and rank them acc to % employees making 100000 in salary

-- Output - %perc(10000000), deptname, nos_of_employees

with cte as (
    select e.*, d.name as dept_name rank() partition_by(d.dept_id order by e.salary desc) rnk
    from employee e join Departement d on e.dept_id = d.dept_id
)
select
    (count(case when salary >= 100000 then 1 else 0 end) * 100.0) / count(id) as '%perc_salary',
    dept_name,
    count(case when salary >= 100000 then 1 else 0 end) as no_of_employees
from cte group by dept_id having rnk <= 3 and count(id) >= 10 order by '%perc_salary' desc

