-- https://platform.stratascratch.com/coding/514-marketing-campaign-success-advanced?code_type=1

/*

You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. 
Find the number of users that made additional in-app purchases due to the success of the marketing campaign.


The marketing campaign doesn't start until one day after the initial in-app purchase so users that only made one or multiple purchases on the first day do not count, 
nor do we count users that over time purchase only the products they purchased on the first day.

*/

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