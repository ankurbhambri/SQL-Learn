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
- date
- day
- week
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

Dim_File
- file_id pk
- user_id pk
- file_name
- file_type (video, audio, image, document)
- file_size
- file_upload_date (date_id)
- file_upload_starttimestamp (date_id)
- file_upload_completetimestamp (date_id)
- file_status (Completed, Cancelled, Progress, Completed)
- UNIQUE(file_id, user_id)


Fact_Files_Logs
- file_id
- owner_user_id
- date_id
- shared_user_id null
- is_owner_shared (true, false)
- share_date (date_id)
- clicked_via (email, link, social_media) null
- access_type (view, edit)
- onwer_ship_transfer (true, false)
- IsFileDownloadable (true, false)



-- 1) Track how many files are Shared and % of Shared Files in a week.
with shared_files as (
    select count(file_id) dc, date_id from Fact_Files_Logs where is_shared = true group by file_id, date_id
)
select b.week, sum(a.dc) from shared_files a join Dim_Date b on a.date_id = b.date_id group by b.week



-- 2) what file type is shared more frequently ?

WITH shared_files AS (
    SELECT 
        f.file_type, 
        COUNT(fl.file_id) AS share_count
    FROM 
        Fact_File f
    JOIN 
        Fact_Files_Logs fl ON f.file_id = fl.file_id
    WHERE 
        fl.is_shared = TRUE
    GROUP BY 
        f.file_type
),
ranked_shared_files AS (
    SELECT 
        file_type, 
        share_count,
        RANK() OVER (ORDER BY share_count DESC) AS rnk
    FROM 
        shared_files
)
SELECT 
    file_type,
    share_count,
    rnk
FROM 
    ranked_shared_files;

-- 3) How many files had more than one owner at a given time?

select file_id, count(1) Fact_Files_Logs where is_shared = true and access_type = editor group by 1 having count(1) > 1

-- 4) Total File Actions by Content Categories.

-- 5) File is shared among multiple people

select file, count(1) from Fact_Files_Logs where owner_id is not null and shared_user_id is not null group by file_id

-- 6) One to record upload/download and the other to record shared assets

-- 7) How to record file ownership transfer

-- 8) Find people who only upload photos



