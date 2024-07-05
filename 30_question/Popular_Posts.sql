-- https://platform.stratascratch.com/coding/2073-popular-posts?code_type=1

with cte as (
    select 
        a.session_id,
        (perc_viewed/100) * EXTRACT(EPOCH FROM (a.session_endtime - a.session_starttime)) AS perc_per_second,
        post_id
    from user_sessions a 
    join post_views p 
    on a.session_id=p.session_id
)
select post_id, sum(perc_per_second) from cte group by post_id
having sum(perc_per_second) >= 5