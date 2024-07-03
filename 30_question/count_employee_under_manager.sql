select m.name manager_name, count(1) no_of_employees
from employees e
join employees m on e.manager_id=m.id
group by 1
order by 2 desc, 1 asc