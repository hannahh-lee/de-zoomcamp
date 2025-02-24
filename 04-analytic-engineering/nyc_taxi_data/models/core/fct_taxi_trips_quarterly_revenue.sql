{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *, 
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
), 
yellow_tripdata as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 
trips_unioned as (
    select * from green_tripdata
    union all 
    select * from yellow_tripdata
)
    select 
    -- year
        EXTRACT(YEAR FROM trips_unioned.pickup_datetime) as year, 
    -- quarter 
        CEIL(EXTRACT(MONTH FROM trips_unioned.pickup_datetime) / 3.0) as quarter,

    service_type, 

    -- Revenue calculation 

    sum(trips_unioned.total_amount) as revenue_total_amount,

    -- Additional calculations

    from trips_unioned
    where EXTRACT(YEAR FROM trips_unioned.pickup_datetime) in (2019,2020)
    group by 1,2,3