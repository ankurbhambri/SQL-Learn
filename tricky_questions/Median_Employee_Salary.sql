with cte as (
  select *,
  row_number() over(partition by company order by salary desc) rw,
  count(1) over(partition by company order by salary desc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as scn
 from salaries
), even_odd as (
  SELECT *
  FROM cte
  WHERE scn % 2 = 0 AND rw IN (scn / 2, (scn / 2) + 1)
  union all
  SELECT *
  FROM cte
  WHERE scn % 2 <> 0 and rw = (scn + 1) / 2
)
SELECT id, company, salary FROM even_odd group by company, salary, id
