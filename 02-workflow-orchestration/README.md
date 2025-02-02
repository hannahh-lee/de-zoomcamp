# Module 2 - Workflow Orchestration 

## ETL Pipelines in Kestra: Google Cloud Platform 
In this module, we will build ETL pipelines for Yellow and Green Taxi data from NYC’s Taxi and Limousine Commission (TLC) with Kestra and load it to Google Cloud Platform (GCP). 

Use this [Docker Compose file](postgres/docker-compose.yml) to create a new local Postgres database running in a Docker container. Set up Kestra using this [Docker Compose file](./docker-compose.yml) containing one container for the Kestra server and another for the Postgres database.

```bash
docker compose up -d
```

Kestra flows:

- [01_getting_started_data_pipe.yaml](flows/01_getting_started_data_pipeline.yaml) 
  - Introductory flow to demonstrate a simple data pipeline which extracts data via HTTP REST API, transforms that data in Python, and then queries it using DuckDB. 
- [02_postgres_taxi.yaml](flows/02_postgres_taxi.yaml) 
  - Automates the process of downloading, transforming, and loading NYC taxi data into PostgreSQL. It supports two types of taxi data (yellow and green), handles table creation, staging, and merging of data. The separation of tasks based on the taxi type ensures that the appropriate schema and fields are used for each dataset.
- [02_postgres_taxi_scheduled.yaml](flows/02_postgres_taxi_scheduled.yaml) 
  - Schedules the same pipeline shown above to run daily at 9 AM UTC. 
  - Can backfill the data pipeline to run on historical data with Kestra Schedule triggers through the Kestra UI.  
- [03_postgres_dbt.yaml](flows/03_postgres_dbt.yaml) 
  - Syncs the dbt models from Git to Kestra and runs the `dbt build` command to build the models.
- [04_gcp_kv.yaml](flows/04_gcp_kv.yaml) 
  - Sets up the Google Cloud Platform.
- [05_gcp_setup.yaml](flows/05_gcp_setup.yaml) 
  - Creates the GCS bucket and BigQuery dataset.
- [06_gcp_taxi.yaml](flows/06_gcp_taxi.yaml) 
  - Loads taxi data to BigQuery. 
- [06_gcp_taxi_scheduled.yaml](flows/06_gcp_taxi_scheduled.yaml) 
  - Schedules the same pipeline shown above to run daily at 9 AM UTC for the green dataset and at 10 AM UTC for the yellow dataset. 
  - Can backfill the data pipeline to run on historical data with Kestra Schedule triggers through the Kestra UI
  - *The advantage of processing data in a cloud environment is that the infinity scalable storage and compute allows us to backfill the datasets without the risk of running out of resources on our local machine.  
- [07_gcp_dbt.yaml](flows/07_gcp_dbt.yaml) 
  - Syncs the dbt models from Git to Kestra and runs the `dbt build` command to build the models
  
### Assignment solutions

1. Within the execution for `Yellow` Taxi data for the year `2020` and month `12`: the uncompressed file size (i.e. the output file `yellow_tripdata_2020-12.csv` of the `extract` task) is 128.3 MB.

2. The rendered value of the variable `file` when the inputs `taxi` is set to `green`, `year` is set to `2020`, and `month` is set to `04` during execution is `green_tripdata_2020-04.csv`.

3. There are 24,6478,499 rows for the `Yellow` Taxi data for all CSV files in the year 2020.

4. There are 1,734,051 rows for the `Green` Taxi data for all CSV files in the year 2020.

5. There are 1,925,152 rows for the `Yellow` Taxi data for the March 2021 CSV file.

6. To configure the timezone to New York in a Kestra Schedule trigger, add a `timezone` property set to `America/New_York` in the `Schedule` trigger configuration.