create or replace table citybikes.raw.raw_json_data(
    json_data variant,
    filename string,
    processed_at timestamp_ntz
);


CREATE OR REPLACE PIPE citybikes_pipe 
AUTO_INGEST=TRUE
AS
COPY INTO citybikes.raw.raw_json_data (json_data, filename, processed_at)
FROM (
    SELECT 
        t.$1 AS json_data,
        METADATA$FILENAME AS filename,
        METADATA$FILE_LAST_MODIFIED AS processed_at
    FROM @ext_stg_citybikes/api_data/ (FILE_FORMAT => citybikes.landing.json_format) t);

show pipes;


--se crea el pipe y luego buscar el arn (show pipes) y crear el evento de notificacion en s3
