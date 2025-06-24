create storage integration s3_snowflake_si
    type = external_stage
    storage_provider = s3
    storage_aws_role_arn = ''
    enabled = true
    storage_allowed_locations = ('s3://citybikesproject')
    ;

desc storage integration s3_snowflake_si;


CREATE STAGE citybikes.landing.ext_stg_citybikes 
	URL = 's3://citybikesproject/' 
	STORAGE_INTEGRATION = S3_SNOWFLAKE_SI 
	DIRECTORY = ( ENABLE = true );

list @citybikes.landing.ext_stg_citybikes;
