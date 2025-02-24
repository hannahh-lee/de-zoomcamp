{{ config(materialized='table') }}

WITH valid_trips AS (
    SELECT *,
    TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS seconds_difference
    FROM {{ ref('dim_fhv_trips') }}
),

percentiles AS (
    SELECT 
        year_pickup,
        month_pickup,
        pickup_zone,
        dropoff_zone,
        PERCENTILE_CONT(seconds_difference, .90) OVER (PARTITION BY year_pickup, month_pickup, pickup_locationid, dropoff_locationid) AS p90,
    FROM valid_trips
)

SELECT distinct year_pickup as year, month_pickup as month, pickup_zone, dropoff_zone, p90 as trip_duration
FROM percentiles
WHERE month_pickup = 11 AND year_pickup = 2019 and pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
order by 5 desc