# End-to-End Data Engineering Project using AWS and Snowflake

## Summary
In this project, data is extracted from an API (CityBikes API from https://api.citybik.es/v2/) to create an interactive dashboard to report on bike availability and view other statistics. Data ingestion is performed using AWS Glue, and the data is stored in S3, where data is initially stored in its native format (JSON). Then, the processing and storage of the data is handled through Snowflake. First, an external stage is created to visualize the data without storing it in Snowflake, using the $ notation. Afterwards, Snowpipes are created, which allow incremental ingestion into a raw layer. In this layer, the data is stored in table format, where the entire JSON file and its metadata are saved. Next, using dynamic tables (which allow dynamic transformations and reading only the new records for incremental load), we unnest the arrays in the JSON files (using the flatten function), clean and filter the data, and obtain a table with structured data. Finally, a small data warehouse is created with 4 dimension tables and 2 fact tables. This layer or schema is then connected to Power BI to create interactive dashboards.

## Tools and Technologies
- **Cloud**: AWS
- **Processing**: Snowflake
- **Storage**: S3 and Snowflake
- **Business Intelligence Dashboard**: Power BI
- **Data Pipelines/Orchestrator**: AWS Glue and Snowflake (Snowpipes and Dynamic Tables)

## Project Architecture
Here you can visualize the completed project:
<img src="https://i.imgur.com/rPCVeny.png" alt="architecture">

## Objectives
Extract data from an API, transform it, and load it into Power BI.

## Provisioned Resources
  ### Amazon Web Services
   - AWS Glue
   - S3
  ### Snowflake
   - Snowflake Instance

## Process Description

### 1. Ingest data from API
- The data is extracted in JSON format from an API (https://api.citybik.es/v2/) using a script in AWS Glue and stored in S3).
- In this [Script](AWS/CallAPI.py) you can see the python script that calls the API.

  #### Trigger
   
    <img src="https://i.imgur.com/6YHw8ew.png" alt="Trigg">

    This trigger activates the 'CallAPI' job every 10 minutes, meaning that it is being called and retrieving data from the API every 10 minutes. This is easily configurable and can be changed as needed.
    

### 2. Snowflake
  - As a first step, we need to create a storage integration between Snowflake and AWS. This is primarily a secure permission/authentication mechanism between Snowflake and an external storage service (in this case, AWS). Next, we create an external stage, which is an object that points to a specific location of the external files.
    - This can be seen in the following SQL worksheet: [storage_integration.sql](Snowflake/storage_integration.sql)
  - Then, we need to create the internal storage area within Snowflake:
    - We create the "citybikes" database, and then create several schemas ("landing", "raw", "silver", and "gold").
    - Once the external stage and landing layer are set up, we can query the data without storing it in Snowflake, and we can navigate through the JSON using the $ notation.
    - The implementation is available in the following worksheet: [schema_creation.sql](Snowflake/schema_creation.sql)
  - Next, we create the table for the raw layer. One table is created, storing the full JSON object in one column, along with the filename and the processing timestamp.
    <img src="https://i.imgur.com/rRTiB6a.png" alt="table example1">
    - Then, we proceed to create the Snowpipes, which will ingest data from S3 into Snowflake whenever a blob/file is created inside a bucket.
    - The steps are illustrated in the following worksheet: [raw_layer.sql](Snowflake/raw_layer.sql)
  - Then, we create the dynamic tables in the silver layer, which have the capability to either process all the data from the source table (full load) or only process the new data (incremental load). [Snowflake Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)  are tables that automatically update based on a defined query. They work like materialized views that stay continuously or periodically refreshed, allowing incremental loads, automated transformations, and simplifying the development of data pipelines without the need for additional code.
    - SQL code for this step is provided in the following worksheet: [silver_layer.sql](Snowflake/silver_layer.sql)
    <img src="https://i.imgur.com/x5W4Nsr.png" alt="table example2">
  - Finally, we create the dimension tables and the fact tables, which will also be dynamic tables, as they are derived from the tables created in the silver layer.
    - The corresponding script can be found here: [gold_layer.sql](Snowflake/gold_layer.sql)

### 3. Connect Snowflake with Power BI
- In this step, we need to connect the "gold" schema to Power BI. This allows us to create interactive dashboards and work with the data in real time.
 - The model view can be seen here:
   <img src="https://i.imgur.com/yHaNwvx.png" alt="model">
   
- In addition, we can display a real-time map showing bike availability at the stations, as well as view the free spots and the last time the data was updated.
  
   <img src="https://i.imgur.com/EUUxSgA.png" alt="model1">
 

Here you can see the [video](https://drive.google.com/file/d/13U7OFlwrM3vmYuxhmyZYSjT4mn3c_X8h/view?usp=sharing) that documents the implementation of the process.



 

 

 


 

