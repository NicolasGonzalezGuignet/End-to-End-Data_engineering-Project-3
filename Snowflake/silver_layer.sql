create or replace dynamic table citybikes.silver.clean_citybikes_acumulatted
target_lag= '30 minutes'
warehouse= 'COMPUTE_WH'
refresh_mode=incremental
initialize=on_create
as
select
    DATE_TRUNC('MINUTE', processed_at) AS processed_at,
    f.value:id::string as id_station,
    JSON_DATA:network:id::string as id_network,
    JSON_DATA:network:location:city::string as city,
    JSON_DATA:network:location:country::string as country,
    f.value:name::string as name_station,
    f.value:latitude::float as latitude,
    f.value:longitude::float as longitude,
    f.value:free_bikes::integer as free_bikes,
    f.value:empty_slots::integer as empty_slots,
    f.value:extra:slots::integer as total_slots,
    f.value:extra:normal_bikes::integer as normal_bikes,
    f.value:extra:address::string as address,
    to_timestamp(f.value:extra:last_updated::string) as last_updated,
    f.value:extra:renting::boolean as renting,
    f.value:extra:returning::boolean as returning,
    ARRAY_TO_STRING(f.value:extra:payment, '/') AS payment_methods
from citybikes.raw.raw_json_data,
lateral flatten(input => JSON_DATA:network:stations) f;



CREATE OR REPLACE DYNAMIC TABLE citybikes.silver.clean_citybikes
  TARGET_LAG = '30 minutes'
  WAREHOUSE = 'COMPUTE_WH'
  REFRESH_MODE = incremental
  INITIALIZE = on_create
AS
WITH latest_raw AS (
    SELECT *
    FROM citybikes.raw.raw_json_data
    QUALIFY ROW_NUMBER() OVER (ORDER BY processed_at DESC) = 1
)
SELECT
    DATE_TRUNC('MINUTE', processed_at) AS processed_at,
    f.value:id::string as id_station,
    JSON_DATA:network:id::string as id_network,
    JSON_DATA:network:location:city::string as city,
    JSON_DATA:network:location:country::string as country,
    f.value:name::string as name_station,
    f.value:latitude::float as latitude,
    f.value:longitude::float as longitude,
    f.value:free_bikes::integer as free_bikes,
    f.value:empty_slots::integer as empty_slots,
    f.value:extra:slots::integer as total_slots,
    f.value:extra:normal_bikes::integer as normal_bikes,
    f.value:extra:address::string as address,
    to_timestamp(f.value:extra:last_updated::string) as last_updated,
    f.value:extra:renting::boolean as renting,
    f.value:extra:returning::boolean as returning,
    ARRAY_TO_STRING(f.value:extra:payment, '/') AS payment_methods
FROM latest_raw,
     LATERAL FLATTEN(input => JSON_DATA:network:stations) f;



