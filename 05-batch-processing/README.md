# Module 5 Coursework 

## Q1: Install Spark and PySpark 

Create a local spark session and execute spark.version.

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()

spark.version
```

Output is `3.5.4`.

## Q2: Yellow October 2024 
Read the October 2024 Yellow into a Spark Dataframe. 
Repartition the Dataframe to 4 partitions and save it to parquet. 

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-10.parquet
```

```python
df = spark.read.parquet('yellow_tripdata_2024-10.parquet')
df = df.repartition(4)
df.write.parquet('05-homework/',  mode="overwrite")
```

The resulting created files created are ~23.5MB.

## Q3: Count records 
View the Yellow trip data:
```python
df_yellow_data = spark.read.parquet('05-homework/*')
df_yellow_data.show(10)
df_yellow_data.printSchema()
```

Register the DataFrame as a temporary view or table to use SQL queries with DataFrames in Spark. 
```python
df_yellow_data.createOrReplaceTempView('yellow_trips_data_202410')
```

Query the number of taxi trips that occurred on the 15th of October. 
```python 
spark.sql("""
 SELECT count(*) from yellow_trips_data_202410
 where date(tpep_pickup_datetime) = '2024-10-15'
 """).show()
 ```
128,893 yellow taxi trips occurred on Oct 15th, 2024. 

## Q4: Longest trip 
```python
spark.sql("""
 SELECT 
  (UNIX_TIMESTAMP(tpep_dropoff_datetime) - UNIX_TIMESTAMP(tpep_pickup_datetime)) / 3600 AS time_diff
FROM yellow_trips_data_202410
ORDER BY time_diff DESC
LIMIT 10
 """).show()
 ```
 The longest trip in the dataset in hours is 162 hrs. 

 ## Q5: User Interface 
The Spark UI that show's the application's dashboard runs on `localhost:4040`. 

## Q6: Least frequent pickup location zone 
```bash
wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv
```
Register the DataFrame for taxi zones as a temporary view or table to use SQL queries with DataFrames in Spark. 
```python
df_taxizone = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv('taxi_zone/*')
df_taxizone.createOrReplaceTempView('taxi_zones')
```

View the schema (structure) of the DataFrame:
```python
df_yellow_data.schema
```

Find frequency of PULocation ID in the Yellow Taxi Dataset
```python
df_freq = spark.sql("""
 SELECT PULocationID as LocationID,
  CAST(count(PULocationID) as INT) as frequency
FROM yellow_trips_data_202410
GROUP BY 1
ORDER BY 2 ASC
LIMIT 10
 """)
 ```

 View the schema (structure) of the DataFrame to confirm data types for the `LocationID` column that will be used for joining:
```python
df_freq.schema
```
 
 Join the two tables on zone 
 ```python 
 df_join = df_taxizone.join(df_freq, on = ['LocationID'], how='left')
 df_join.show()
 df_join.createOrReplaceTempView('join_freq')
```

Query for frequency
```python
spark.sql("""
 SELECT zone, frequency
FROM join_freq
where frequency is not null
ORDER BY 2 asc
 """).show()
 ```


