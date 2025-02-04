# Module 3 - Data Warehouse

## BigQuery Setup 

Upload the files manually into a BigQuery bucket and create a new dataset. 

Run the following query to create a table in the dataset. Make sure the URI correctly points to the location of the Parquet files in Google Cloud Storage.

```sql
CREATE OR REPLACE EXTERNAL TABLE abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_external
OPTIONS(
  FORMAT='PARQUET',
  URIS=['gs://abiding-kingdom-447001-e7-nytaxi/yellow-taxi-2024/*']
```

Create a (regular/materialized) table in BQ using the Yellow Taxi Trip Records (do not partition or cluster this table).

```sql
CREATE OR REPLACE TABLE abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned AS
SELECT * FROM abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_external;
```

## Question 1

The count of records for the 2024 Yellow Taxi Data is 20,332,093. 

```sql 
SELECT count(*) FROM `abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned` 
```

## Question 2 

The estimated amount of data that will be read when this query is executed on the external table is 0 MB for and 155.12 MB for the materialized table.

```sql 
SELECT count(distinct PULocationID) FROM `abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_external`

SELECT count(distinct PULocationID) FROM `abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned`
```

## Question 3 

The estimated number of Bytes is different when retrieving data from one column vs. retriving data from two columns, because BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

```sql
SELECT PULocationID, DOLocationID FROM `abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned`
```

## Question 4 

There are 8,333 records with a fare_amount of 0. 

```sql 
SELECT count(*) FROM `abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned`
where fare_amount = 0.0
```

## Question 5 

If my query will always filter based on `tpep_dropoff_datetime` and order the results by `VendorID`, the best strategy to make an optimized table in BigQuery is to partition by `tpep_dropoff_datetime` and cluster on `VendorID`.

```sql
CREATE OR REPLACE TABLE abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_partitioned
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned;
```

## Question 6 

To retrieve the distinct VendorIDs between `tpep_dropoff_datetime` 03/01/2024 and 03/15/2024 (inclusive):

```sql
select distinct VendorID from abiding-kingdom-447001-e7.2024_yellow_taxi.yellow_taxi_2024_non_partitioned
where date(tpep_dropoff_datetime) >= '2024-03-01'
and date(tpep_dropoff_datetime) <= '2024-03-15'
```

The estimated bytes processed is 310.24 MB for the non-partitioned table and 26.84 MB for the partitioned table.

## Question 7 

The data stored in the external table that was created is in the Google Cloud Provider bucket. 

## Question 8

False, it is not best practice in big query to always cluster your data. 






