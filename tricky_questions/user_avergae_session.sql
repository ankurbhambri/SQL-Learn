-- https://platform.stratascratch.com/coding/10352-users-by-avg-session-time?code_type=1

with page_load_time as (select
    user_id, timestamp::date, max(timestamp::time) mx
from facebook_web_log where action = 'page_load' group by 1, 2),
page_exit_time as (select
    user_id, timestamp::date, min(timestamp::time ) mn
from facebook_web_log where action = 'page_exit' group by 1, 2)
select 
  a.user_id,
  avg(b.mn - a.mx)
from page_load_time a 
join page_exit_time b 
on a.user_id=b.user_id and a.timestamp=b.timestamp and a.mx < b.mn
group by a.user_id
