-- DIMENSIONS TABLES
CREATE OR REPLACE TRANSIENT TABLE citybikes.gold.dim_datetime AS
WITH minutes AS (
  SELECT 
    SEQ4() AS minute_offset,
    DATEADD(MINUTE, SEQ4(), '2025-06-01 00:00:00') AS datetime
  FROM TABLE(GENERATOR(ROWCOUNT => 306061))  -- Número de minutos desde 2025-06-01 00:00 hasta 2025-12-31 23:00
)
SELECT
  ROW_NUMBER() OVER (ORDER BY datetime) AS date_key,
  datetime,
  EXTRACT(MINUTE FROM datetime) AS minute,
  EXTRACT(HOUR FROM datetime) AS hour,
  EXTRACT(DAY FROM datetime) AS day,
  EXTRACT(MONTH FROM datetime) AS month,
  TRIM(TO_CHAR(datetime, 'Month')) AS month_name,
  EXTRACT(YEAR FROM datetime) AS year,
  EXTRACT(QUARTER FROM datetime) AS quarter,
  EXTRACT(WEEK FROM datetime) AS week,
  EXTRACT(DAYOFWEEK FROM datetime) AS day_of_week,
  CASE WHEN DAYOFWEEK(datetime) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
  CASE
    WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Summer'
    WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Autumn'
    WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Winter'
    WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Spring'
  END AS season,
  CASE WHEN TO_CHAR(datetime, 'HH24:MI:SS') = '00:00:00' THEN TRUE ELSE FALSE END AS midnight
FROM minutes
WHERE datetime <= '2025-12-31 23:00:00';



CREATE OR REPLACE transient TABLE citybikes.gold.dim_station(
  station_key INT AUTOINCREMENT PRIMARY KEY,
  station_id STRING,
  station_name STRING,
  lat float,
  lon float,
  address STRING
);
INSERT INTO citybikes.gold.dim_station (station_id,station_name,lat,lon,address)
SELECT ID_STATION,name_station,latitude,longitude,address
FROM citybikes.silver.clean_citybikes_acumulatted
GROUP BY ID_STATION,name_station,latitude,longitude,address;



CREATE OR REPLACE transient TABLE citybikes.gold.dim_network(
  network_key INT AUTOINCREMENT PRIMARY KEY,
  station_name STRING
);
INSERT INTO citybikes.gold.dim_network (station_name)
SELECT id_network
FROM citybikes.silver.clean_citybikes_acumulatted
GROUP BY id_network;


CREATE OR REPLACE transient TABLE citybikes.gold.dim_city(
  city_key INT AUTOINCREMENT PRIMARY KEY,
  city STRING,
  country string
);
INSERT INTO citybikes.gold.dim_city (city,country)
SELECT city,country
FROM citybikes.silver.clean_citybikes_acumulatted
GROUP BY city,country;

-- FACT TABLES

create or replace dynamic table citybikes.gold.fact_table_citybikes
target_lag= '30 minutes'
warehouse= 'COMPUTE_WH'
refresh_mode=incremental
initialize=on_create
as
select
row_number() over (order by c.id_station) as row_key,
d.date_key,
n.network_key,
s.station_key,
ci.city_key,
c.free_bikes,
c.empty_slots,
c.total_slots,
c.normal_bikes,
c.last_updated,
c.renting,
c.returning,
c.payment_methods

from citybikes.silver.clean_citybikes c 
join citybikes.gold.dim_datetime d on c.processed_at = d.datetime -- podria no incluirlo....
join citybikes.gold.dim_network n on  c.id_network = n.station_name
join citybikes.gold.dim_city ci on c.city = ci.city
join citybikes.gold.dim_station s on c.id_station = s.station_id;



create or replace dynamic table citybikes.gold.fact_table_citybikes_accumulatted
target_lag= '30 minutes'
warehouse= 'COMPUTE_WH'
refresh_mode=incremental
initialize=on_create
as
select
row_number() over (order by c.id_station,c.processed_at) as row_key,
d.date_key,
n.network_key,
s.station_key,
ci.city_key,
c.free_bikes,
c.empty_slots,
c.total_slots,
c.normal_bikes,
c.last_updated,
c.renting,
c.returning,
c.payment_methods

from citybikes.silver.clean_citybikes_acumulatted c 
join citybikes.gold.dim_datetime d on c.processed_at = d.datetime
join citybikes.gold.dim_network n on  c.id_network = n.station_name
join citybikes.gold.dim_city ci on c.city = ci.city
join citybikes.gold.dim_station s on c.id_station = s.station_id;






