{{
    config(
        materialized='view'
    )
}}

select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as fhv_trip_id,
    pickup_datetime, 
    dropOff_datetime as dropoff_datetime, 
    PUlocationID as pickup_locationid,
    DOlocationID as dropoff_locationid, 
    SR_Flag,
    Affiliated_base_number
from {{ source('staging','fhv_data') }}
  where dispatching_base_num is not null 

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}