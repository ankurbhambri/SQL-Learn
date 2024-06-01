-- https://platform.stratascratch.com/coding/10297-comments-distribution
  
with cte as (
    select a.id, count(1) as comments_count 
    from fb_users a
    join fb_comments b 
    on a.id=b.user_id 
    where
        (a.joined_at between '2018-01-01' and '2020-01-01') and
        (b.created_at between '2020-01-01' and '2020-01-31')
    group by a.id
) 
select cm, count(1) from cte group by comments_count order by comments_count;
