/*

The cloud storage company would like to design a data model to capture all critical data elements and answer the following questions. 

Questions -  

Track how many files are Shared and % of Shared Files in a week.

what file type is shared more frequently ?

How many files had more than one owner at a given time?

Total File Actions by Content Categories.

File is shared among multiple people

One to record upload/download and the other to record shared assets

How to record file ownership transfer

Find people who only upload photos

*/

Dim_Date
- date_id
- timestamp
- day
- month
- Quarter
- year

Dim_user
- user_id
- date_id
- user_name
- user_email
- user_phone

Dim_Plan
- plan_id
- plan_name (lite, pro, enterprise)
- plan_price
- plan_start_date (date_id)
- plan_end_date (date_id)

Dim_Subscriptions
- subscription_id
- user_id
- plan_id
- subscription_type (monthly, yearly)
- subscription_start_date (date_id)
- subscription_end_date (date_id)
- isActive

Fact_File
- file_id pk
- user_id pk
- file_name
- file_type (video, audio, image, document)
- file_size
- IsFileShared (True, False)
- file_upload_date (date_id)
- file_upload_starttimestamp (date_id)
- file_upload_completetimestamp (date_id)
- file_status (Completed, Cancelled, Progress, Completed)
- UNIQUE(file_id, user_id)

Fact_Shared_Files
- file_id
- user_id
- shared_user_id
- share_date (date_id)
- share_type (email, link, social_media)
- access_type (view, edit, owner)

Fact_Logs
- action_id
- date_id
- file_id
- user_id
- action_type (upload, download, share, delete)



-- 1) Track how many files are Shared and % of Shared Files in a week.
select count(file_id) from Fact_Logs group by date_id, action_type having action_type = 'share';


-- 2) what file type is shared more frequently ?
select file_id, count(file_id) over(partition by file_id order by file_id) from Fact_Logs

-- 3) How many files had more than one owner at a given time?

-- 4) Total File Actions by Content Categories.

-- 5) File is shared among multiple people

-- 6) One to record upload/download and the other to record shared assets

-- 7) How to record file ownership transfer

-- 8) Find people who only upload photos



