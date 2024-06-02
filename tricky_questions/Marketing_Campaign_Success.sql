with cte as (
    select *, 
        rank() over(partition by user_id order by created_at) as rn 
    from marketing_campaign
),
first_day as (
    select * from cte where rn = 1
),
another_day as (
    select * from cte where rn > 1
)
select count(distinct a.user_id) from another_day a 
left join first_day b 
on a.user_id = b.user_id and a.product_id = b.product_id
where b.product_id is null