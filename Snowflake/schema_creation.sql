CREATE OR REPLACE DATABASE citybikes;

CREATE OR REPLACE SCHEMA citybikes.landing;
CREATE OR REPLACE SCHEMA citybikes.raw;
CREATE OR REPLACE SCHEMA citybikes.silver;
CREATE OR REPLACE SCHEMA citybikes.gold;

create or replace file format citybikes.landing.json_format
    type = json
    strip_outer_array = true
    IGNORE_UTF8_ERRORS = FALSE;

use schema citybikes.landing;

--podemos realizar consultas rapida para ver si los datos son correctos

SELECT
    t.$1:network:location::variant as company_owner,
    t.$1:network.id::variant as id,
    t.$1:network.name::variant as name,
    t.$1:network:company::variant as company
 
FROM @ext_stg_citybikes/api_data/response_20250612_191806.json (FILE_FORMAT => citybikes.landing.json_format) t;



