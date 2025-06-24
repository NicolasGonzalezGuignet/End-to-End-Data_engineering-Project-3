# End-to-End Data Engineering Project using AWS and Snowflake

## Summary
In this project, data is extracted from an API (CityBikes API from https://api.citybik.es/v2/) to create an interactive dashboard para informa acerca de la disponibilidad dde las bicis y ver otras estadisticas. Data ingestion is performed using AWS Glue, and the data is stored in S3, where data is initially stored in its native format (JSON). Then, the processing and storage of the data is handled through Snowflake. First, an external stage is created to visualize the data without storing it in Snowflake, using the $ notation. Afterwards, Snowpipes are created, los cuales permiten la incremental ingestion into a raw layer. In this layer, the data is stored in table format, where the entire JSON file and its metadata are saved. Next, using dynamic tables (which allow dynamic transformations and reading only the new records for incremental load), we unnest the arrays in the JSON files (using the flatten function), clean and filter the data, and obtain a table with structured data. Finally, a small data warehouse is created with 4 dimension tables and 2 fact tables. This layer or schema is then connected to Power BI to create interactive dashboards.

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
  ### Azure
   - AWS Glue
   - S3
  ### Snowflake
   - Snowflake Instance

## Process Description

### 1. Ingest data from APIs
- The data is extracted in JSON format from an API (https://api.citybik.es/v2/) using a script in AWS Glue and stored in S3).
- In this [Script](AWS/CallAPI.py) you can see the script that calls the API.

  #### Trigger
   
    <img src="https://i.imgur.com/6YHw8ew.png" alt="Trigg">

    Este trigger activa al job "CallAPI" cada 10 minutos, es decir, que se esta llamanddo cada 10 minutos y obteniendo datos de la api cada 10 minutos, esto es facilmente         configurable y se puede cambiar segun se requiera.
    

### 2. Snowflake
  - As a first step, we need to create a storage integration between Snowflake and AWS. This is primarily a secure permission/authentication mechanism between Snowflake and an external storage service (in this case, AWS). Next, we create an external stage, which is an object that points to a specific location of the external files.
    - This can be seen in the following SQL worksheet: [storage_integration.sql](Snowflake/Worksheets/storage_integration.sql)
  - Then, we need to create the internal storage area within Snowflake:
    - We create the "citybikes" database, and then create several schemas ("landing", "raw", "silver", and "gold").
    - Once the external stage and landing layer are set up, we can query the data without storing it in Snowflake, and we can navigate through the JSON using the $ notation.
    - The implementation is available in the following worksheet: [schema_creation.sql](Snowflake/Worksheets/schema_creation.sql)
  - Next, we create the tables for the raw layer. Four tables are created, each storing the full JSON object in one column, along with the filename and the processing timestamp (one for each object of study).
    <img src="https://i.imgur.com/tqXEKJ2.png" alt="table example1">
    - Then, we proceed to create the Snowpipes, which will ingest data from Azure into Snowflake whenever a blob is created inside a container, using Event Grid notifications.
    - The steps are illustrated in the following worksheet: [raw_layer.txt](Snowflake/Worksheets/raw_layer.sql)
  - Then, we create the dynamic tables in the silver layer, which have the capability to either process all the data from the source table (full load) or only process the new data (incremental load). [Snowflake Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)  are tables that automatically update based on a defined query. They work like materialized views that stay continuously or periodically refreshed, allowing incremental loads, automated transformations, and simplifying the development of data pipelines without the need for additional code.
    - SQL code for this step is provided in the following worksheet: [silver_layer.txt](Snowflake/Worksheets/silver_layer.sql)
    <img src="https://i.imgur.com/aIY5myU.png" alt="table example2">
  - Finally, we create the dimension tables and the fact tables, which will also be dynamic tables, as they are derived from the tables created in the silver layer.
    - The corresponding script can be found here: [gold_layer.txt](Snowflake/Worksheets/gold_layer.sql)

### 3. Connect Snowflake with Power BI
- In this step, we need to connect the "gold" schema to Power BI. This allows us to create interactive dashboards and work with the data in real time.
 - The model view can be seen here:
  - <img src="https://i.imgur.com/yHaNwvx.png" alt="model">
 

Here you can see the [video](https://drive.google.com/file/d/1dHaZ7ptRNtrSOl9Ww-Q85RGjIFvcayiR/view?usp=sharing) that documents the implementation of the ETL.



 

 

 


 

