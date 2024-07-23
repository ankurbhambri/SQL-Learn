"""



Q1) The interviewer shared the below sample data logs.

Given below sample data

m0	p0	start	0.712
m0	p1	start	0.841
m0	p2	start	1.523
m0	p2	end	1.966
m0	p1	start	2.856
m0	p2	start	3.347
m0	p2	end	3.567
m0	p1	start	3.800
m0	p2	start	4.618
m0	p2	end	5.497
m0	p1	start	5.961
m0	p2	start	6.324
m0	p2	end	6.673
m0	p1	end	7.233
m0	p1	end	7.533
m0	p1	end	7.933
m0	p1	end	8.333
m0	p0	end	9.933

a row m1:p1:start:2.984 means, machine m1 starts process p1 at timestamp 2.984.

Goal:

Design a table schema for this data to be used by data scientist to query metrics such as process with max average elapsed time and they can plot each process.
Design a ETL in python to load data to above data model/table.

Follow-up

How to optimize process to parse the file and load to table. Can it be done with constant memory.
There can be multiple machine m0..mN, each machine can have millions of process entries. How you will scale.

"""

from pyspark.sql import SparkSession  # type: ignore

# Create a SparkSession
spark = SparkSession.builder.getOrCreate()

spark.conf.set(
    "fs.azure.account.key.<your-storage-account-name>.blob.core.windows.net",
    "<your-storage-account-key>",
)

# Define the path to your Delta table in Azure Blob Storage
delta_path = "hdfs://<your-container-name>@<your-storage-account-name>.blob.core.windows.net/<path-to-delta-table>"

# Read the Delta table
delta_df = (
    spark.read.format("delta").load(delta_path)
    # .where("partition_column == 'machines'")
)

delta_df.createOrReplaceTempView("raw_table_machines")

result_df = spark.sql(
    """
    SELECT * 
    FROM raw_table_machines
"""
)

result_df.write.format("delta").partitionBy("partition_column").mode("overwrite").save(
    "path/to/delta/table"
)


"""
Question 2:

You have to write a query that functions as the SELECT portion of a daily load job into an aggregate table. 

You have to use both the demoralised and prior snapshots from aggregate table to solve this. 

Hint: full outer join. Know case statements and aggregations (duh)

"""

"""
-- Define the query to Aggregate daily sales data

    WITH current_day_raw_sales_data AS (
        SELECT 
            date,
            product_id,
            SUM(sales_amount) AS total_sales
        FROM raw_sales_data_daily -- Assuming we're processing data from today's partition
        GROUP BY date, product_id
    ),
    previous_day_snapshot_agg_table AS (
        SELECT 
            date,
            product_id,
            total_sales
        FROM daily_aggregate_snapshot
        WHERE date = CURRENT_DATE - INTERVAL '1 day' -- Previous day's snapshot
    )
    -- Insert the result into the aggregate table
    INSERT INTO daily_aggregate_snapshot (date, product_id, total_sales)
    SELECT 
        COALESCE(d.date, s.date) AS date,
        COALESCE(d.product_id, s.product_id) AS product_id,
        -- Calculate total sales by combining current day's sales and previous snapshot
        COALESCE(d.total_sales, 0) + COALESCE(s.total_sales, 0) AS total_sales
    FROM current_day_raw_sales_data d
    FULL OUTER JOIN previous_day_snapshot_agg_table s
    ON d.product_id = s.product_id
    AND d.date = s.date;  
    
    -- In case date matches with previous day's snapshot which is not possible then merge will be done else aggregation will be done on daily data.

"""


"""
-- Insert into the Cumulative table with aggregation

WITH yesterday AS (
    SELECT * 
    FROM active_users_cumulated
    WHERE snapshot_date = CURRENT_DATE - INTERVAL '1 day'
),
today AS (
    SELECT * 
    FROM active_users_daily
    WHERE snapshot_date = CURRENT_DATE
),
combined AS (
    SELECT
        COALESCE(y.user_id, t.user_id) AS user_id,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.activity_array) < 30 THEN
                    ARRAY[COALESCE(t.is_active_today, 0)] || y.activity_array
                ELSE
                    ARRAY[COALESCE(t.is_active_today, 0)] || SLICE(y.activity_array, -1, 29)
            END,
            ARRAY[t.is_active_today]
        ) AS activity_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.like_array) < 30 THEN
                    ARRAY[COALESCE(t.num_likes, 0)] || y.like_array
                ELSE
                    ARRAY[COALESCE(t.num_likes, 0)] || SLICE(y.like_array, -1, 29)
            END,
            ARRAY[t.num_likes]
        ) AS like_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.comment_array) < 30 THEN
                    ARRAY[COALESCE(t.num_comments, 0)] || y.comment_array
                ELSE
                    ARRAY[COALESCE(t.num_comments, 0)] || SLICE(y.comment_array, -1, 29)
            END,
            ARRAY[t.num_comments]
        ) AS comment_array,
        COALESCE(
            CASE 
                WHEN CARDINALITY(y.share_array) < 30 THEN
                    ARRAY[COALESCE(t.num_shares, 0)] || y.share_array
                ELSE
                    ARRAY[COALESCE(t.num_shares, 0)] || SLICE(y.share_array, -1, 29)
            END,
            ARRAY[t.num_shares]
        ) AS share_array,
        t.snapshot_date
    FROM yesterday y
    FULL OUTER JOIN today t
    ON y.user_id = t.user_id
)
-- Upsert into the cumulative table
INSERT INTO active_users_cumulated (user_id, activity_array, like_array, comment_array, share_array, snapshot_date)
SELECT
    user_id,
    activity_array,
    like_array,
    comment_array,
    share_array,
    snapshot_date
FROM combined
ON CONFLICT (user_id) 
DO UPDATE SET
    activity_array = EXCLUDED.activity_array,
    like_array = EXCLUDED.like_array,
    comment_array = EXCLUDED.comment_array,
    share_array = EXCLUDED.share_array,
    snapshot_date = EXCLUDED.snapshot_date;

"""
