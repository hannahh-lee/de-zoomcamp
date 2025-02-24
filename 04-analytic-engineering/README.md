# Module 4 Homework 

## Build the staging models for green/yellow taxi data, and the dimension/fact for taxi_trips joining with dim_zones.

Set up python virtual env and go into the created directory. 
```bash
python -m venv my-project
cd my-project
```

Activate the environment 
```bash 
source my-project/bin/activate
```

Install dbt-core and the bigquery adapter. Verify dbt installation.
```bash
pip install dbt-core dbt-bigquery
dbt --version
```

Create a new dbt project. Initizialize a new directory structure for your dbt project and sets up the necessary files.
```bash 
dbt init nyc_taxi_data
```

Update profile.yml config to set up db connection to BigQuery. Check that the db connection is successful. 
```bash
dbt debug
```

Create `schema.yml` model. 

Create the `stg_green_tripdata.sql` model. 

Add a dbt macro that returns a description for a `payment_type` based on its integer value under the macros folder in the project. 

Create a `packages.yml` in the dbt project directory, where the `dbt_project.yml` is located, for the packages utilized in this project.

Run the dependencies. This will create a new folder dbt_packages.
```bash
dbt deps
```

Run dbt compile to compile the models and see the resulting SQL without running it. 
```bash 
dbt compile
```

Build a single dbt model without running the entire project. 
```bash
dbt build --select my_model_name
```


### Question 1: Understanding dbt model resolution

Given the following `sources.yaml`
```yaml
version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi
```

with the following env variables setup where `dbt` runs:
```shell
export DBT_BIGQUERY_PROJECT=myproject
export DBT_BIGQUERY_DATASET=my_nyc_tripdata
```

The following .sql model will compile to:
```sql
select * 
from {{ source('raw_nyc_tripdata', 'ext_green_taxi' ) }}
```

### Question 2: 

Say you have to modify the following dbt_model (`fct_recent_taxi_trips.sql`) to enable Analytics Engineers to dynamically control the date range. 

- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

```sql
select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY
```

To ensure command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value, we would have to:

- Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY`

### Question 3:

Considering the data lineage below and that taxi_zone_lookup is the only materialization build (from a .csv seed file):

![image](./homework_q2.png)

The option that does **NOT** apply for materializing `fct_taxi_monthly_zone_revenue` is 

- `dbt run --select models/staging/+`

### Question 4: 

Consider you're dealing with sensitive data (e.g.: [PII](https://en.wikipedia.org/wiki/Personal_data)), that is **only available to your team and very selected few individuals**, in the `raw layer` of your DWH (e.g: a specific BigQuery dataset or PostgreSQL schema), 

 - Among other things, you decide to obfuscate/masquerade that data through your staging models, and make it available in a different schema (a `staging layer`) for other Data/Analytics Engineers to explore

- And **optionally**, yet  another layer (`service layer`), where you'll build your dimension (`dim_`) and fact (`fct_`) tables (assuming the [Star Schema dimensional modeling](https://www.databricks.com/glossary/star-schema)) for Dashboarding and for Tech Product Owners/Managers

You decide to make a macro to wrap a logic around it:

```sql
{% macro resolve_schema_for(model_type) -%}

    {%- set target_env_var = 'DBT_BIGQUERY_TARGET_DATASET'  -%}
    {%- set stging_env_var = 'DBT_BIGQUERY_STAGING_DATASET' -%}

    {%- if model_type == 'core' -%} {{- env_var(target_env_var) -}}
    {%- else -%}                    {{- env_var(stging_env_var, env_var(target_env_var)) -}}
    {%- endif -%}

{%- endmacro %}
```

And use on your staging, dim_ and fact_ models as:
```sql
{{ config(
    schema=resolve_schema_for('core'), 
) }}
```

That all being said, regarding macro above, **the following statements are true to the models using it**:
- Setting a value for  `DBT_BIGQUERY_TARGET_DATASET` env var is mandatory, or it'll fail to compile
- When using `core`, it materializes in the dataset defined in `DBT_BIGQUERY_TARGET_DATASET`
- When using `stg`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`
- When using `staging`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`

Setting a value for `DBT_BIGQUERY_STAGING_DATASET` env var is not mandatory.

### Question 5:

Create a new model `fct_taxi_trips_quarterly_revenue.sql`. Compute the Quarterly Revenues for each year for based on `total_amount`.

Run the new model:
```bash
dbt run --select fct_taxi_trips_quarterly_revenue.sql --vars '{is_test_run: false}'
```

Compute the Quarterly YoY (Year-over-Year) revenue growth:
```sql
SELECT 
    year,
    CAST(quarter AS INT64) AS quarter,
    service_type,
    revenue_total_amount,
    LAG(revenue_total_amount) OVER (PARTITION BY service_type, CAST(quarter AS INT64) ORDER BY year) AS prev_year_revenue,
    (revenue_total_amount - LAG(revenue_total_amount) OVER (PARTITION BY service_type, CAST(quarter AS INT64) ORDER BY year)) / 
    NULLIF(LAG(revenue_total_amount) OVER (PARTITION BY service_type, CAST(quarter AS INT64) ORDER BY year), 0) AS yoy_growth
FROM `mod4_trips_data.fct_taxi_trips_quarterly_revenue`
```

Considering the YoY growth in 2020, the following were were the best and worst quarters by service_type:
- green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}

### Question 6: P97/P95/P90 Taxi Monthly Fare

Build the new model `fct_taxi_trips_monthly_fare_p95.sql`.
```bash
dbt build --select +fct_taxi_trips_monthly_fare_p95.sql+ --vars '{is_test_run: false}'
```
The values of `p97`, `p95`, `p90` for Green Taxi and Yellow Taxi, in April 2020 are:
- green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}

### Question 7: Top #Nth longest P90 travel time Location for FHV

Create a staging model for FHV data, filtering out entries where `dispatching_base_num` is null. 
```bash
dbt build --select +stg_fhv_data.sql+ --vars '{is_test_run: false}'
```

Create a core model for FHV Data (`dim_fhv_trips.sql`) joining with dim_zones, including new dimensions `year` and `month` based on `pickup_datetime` to facilitate filtering for querying. 
```bash
dbt build --select +dim_fhv_trips.sql+ --vars '{is_test_run: false}'
```

Create a new model `fct_fhv_monthly_zone_traveltime_p90.sql`. Include `trip_duration` calculation based on a timestamp_diff in seconds between `dropoff_datetime` and `pickup_datetime`. Include the calculation of a continuous `p90` of `trip_duration`, partitioning by year, month, `pickup_location_id`, and `dropoff_location_id`. 
```bash
dbt build --select +fct_fhv_monthly_zone_traveltime_p90.sql+ --vars '{is_test_run: false}'
```

For the Trips that **respectively** started from `Newark Airport`, `SoHo`, and `Yorkville East`, in November 2019, the **dropoff_zones** with the 2nd longest p90 `trip_duration` are:
- LaGuardia Airport, Chinatown, Garment District
