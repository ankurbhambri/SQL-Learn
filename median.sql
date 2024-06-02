-- median (odd set of numbers) = ((n+1)/2)th term
-- median (even set of numbers) = ((n/2)th term + ((n/2)+1)th term)/2

with cte as (
    select student_id, sat_writing, rank() over(order by sat_writing) rn
    from sat_scores
),
cte2 as (
    select 
    case 
        when
            (count(*) % 2) = 0 then (count(*) / 2) + (count(*) / 2) + 1 -- even median
        else
            (count(*) + 1 ) / 2 end as cn -- odd median
    from cte
)
select cte.student_id, cte2.cn
from cte, cte2
where cte.rn=cte2.cn
order by cte.student_id