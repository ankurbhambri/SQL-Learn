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
