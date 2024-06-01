-- https://platform.stratascratch.com/coding/10322-finding-user-purchases?code_type=1

select
    a.user_id 
from
    amazon_transactions a 
join
    amazon_transactions b 
on
    a.user_id=b.user_id and
    a.id != b.id and
    ABS(a.created_at - b.created_at) <= 7
group by
    a.user_id
order by
    a.user_id
