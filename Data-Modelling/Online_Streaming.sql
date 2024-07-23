/*

Model the video streaming platform to answer common Questions

Questions -

How many users stream Daily/Monthly

Average viewing per user

Users who viewed certain content

Users who watched certain content on release date.

*/

Dim_Date
- date_id
- date
- day
- month
- year
- day_of_week
- week_of_year

Dim_user
- user_id
- date_id (fk)
- user_name
- user_phone
- user_email

Dim_Plan
- plan_id
- plan_name (lite, pro, enterprise)
- plan_price
- plan_start_date (date_id) (fk)
- plan_end_date (date_id) (fk)

Dim_Subscriptions
- subscription_id
- user_id (fk)
- plan_id (fk)
- subscription_type (monthly, yearly)
- subscription_start_date (date_id) (fk)
- subscription_end_date (date_id) (fk)
- isActive (true, false)


Dim_Content
- content_id
- content_name
- content_type (video, audio, image, document)
- content_category
- content_release_date (date_id)
- Genre

Fact_Streaming
- streaming_id
- user_id (fk)
- content_id (fk)
- subscription_id (fk)
- streaming_date (date_id)
- playback_start
- playback_end
- session_time
- pause_time

-- 1) How many users stream Daily/Monthly
with dau as (select count(user_id) dau_active_user from Fact_Streaming group by streaming_date),
wau as (select EXTRACT(week from streaming_date), count(user_id) wau_active_user from Fact_Streaming group by 1)
wau as (select EXTRACT(month from streaming_date), count(user_id) mau_active_user from Fact_Streaming group by 1)
select * from dau, wau, mau;

-- 2) Average viewing per user
select user_id, avg(streaming_duration) avg_viewing_duration from Fact_Streaming group by user_id;

-- 3) Users who viewed certain content
select user_id, count(user_id) from Fact_Streaming where content_name='Toy story2' group by user_id;

-- 4) Users who watched certain content on release date.
select a.user_id, count(1) from Fact_Streaming a join Dim_Content b on a.content_id=b.content_id where a.streaming_date = b.content_release_date group by a.user_id;
