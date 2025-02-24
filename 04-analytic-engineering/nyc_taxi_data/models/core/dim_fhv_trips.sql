{{
    config(
        materialized='table'
    )
}}

with fhv_trip_data as (
    select *,
    from {{ ref('stg_fhv_data') }}
),  
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select fhv_trip_data.fhv_trip_id, fhv_trip_data.pickup_datetime, fhv_trip_data.dropoff_datetime, pickup_locationid, dropoff_locationid,
pickup_zone.zone as pickup_zone, dropoff_zone.zone as dropoff_zone,
EXTRACT(YEAR FROM fhv_trip_data.pickup_datetime) AS year_pickup,
EXTRACT(MONTH FROM fhv_trip_data.pickup_datetime) AS month_pickup
from fhv_trip_data
inner join dim_zones as pickup_zone
on fhv_trip_data.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_trip_data.dropoff_locationid = dropoff_zone.locationid