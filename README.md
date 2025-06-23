# End-to-End Data Engineering Project using AWS and Snowflake

## Summary
In this project, data is extracted from an API (CityBikes API from https://api.citybik.es/v2/) to create an interactive dashboard with the weather forecast for the next 24 hours, view the current weather conditions, and analyze climate variables from the past 10 years. Data ingestion is performed using Azure Data Factory, and the data is stored in a data lake (ADLS Gen2), where data is initially stored in its native format (JSON). Then, the processing and storage of the data is handled through Snowflake. First, an external stage is created to visualize the data without storing it in Snowflake, using the $ notation. Afterwards, Snowpipes are created, which, through Event Grid notifications in Azure (blob created), enable incremental ingestion into a raw layer. In this layer, the data is stored in table format, where the entire JSON file and its metadata are saved. Next, using dynamic tables (which allow dynamic transformations and reading only the new records for incremental load), we unnest the arrays in the JSON files (using the flatten function), clean and filter the data, and obtain a table with structured data. Finally, a small data warehouse is created with 2 dimension tables and 3 fact tables. This layer or schema is then connected to Power BI to create interactive dashboards.

## Tools and Technologies
- **Cloud**: Azure
- **Processing**: Snowflake
- **Storage**: Azure Data Lake Storage Gen 2 and Snowflake
- **Business Intelligence Dashboard**: Power BI
- **Data Pipelines/Orchestrator**: Azure Data Factory and Snowflake (Snowpipes and Dynamic Tables)

## Project Architecture
Here you can visualize the completed project:
<img src="https://i.imgur.com/rPCVeny.png" alt="architecture">

## Objectives
Extract data from an API, transform it, and load it into Power BI.

## Provisioned Resources
  ### Azure
   - Azure Data Factory (ADF)
   - Storage Account (ADLS Gen2)
   - Azure Event Grid Notifications
  ### Snowflake
   - Snowflake Instance

## Process Description

### 1. Ingest data from APIs
- The data is extracted in JSON format from two APIs (https://openweathermap.org/api and https://dev.meteostat.net/api) using Azure Data Factory (ADF) and stored in an Azure    Data Lake Storage Gen2 (ADLSg2).
- In this [File](ADF/arm_template.zip) you can see the ARM template to provision a similar workspace in ADF.

  #### 1st Pipeline
    This process consists of 6 copy data activities, 3 of which are used to extract current weather data and the other 3 to extract air pollution data and save them into a ADLSg2.
    This is done for each province in the Cuyo region (Mendoza, San Juan and San Luis) (Examples of API responses : [Response1](ADF/Response-APIs-json/weather.json) / [Response2](ADF/Response-APIs-json/air-pollution.json))
    <img src="https://i.imgur.com/UzHY0bg.png" alt="1st pipeline">
    
  #### 2nd Pipeline
    Through 3 copy data activities, the 24-hour weather forecast is extracted for each province.(Examples of API responses : [Response](ADF/Response-APIs-json/forecast.json))
    <img src="https://i.imgur.com/O9CEDAJ.png" alt="2nd pipeline">

  #### 3rd Pipeline
    There are 3 copy data activities that extract data from the https://dev.meteostat.net/api API, retrieving weather information from the past 10 years for each of the previously mentioned provinces. This is useful for analyzing climate variables and observing how they change over time. (Examples of API responses : [Response](ADF/Response-APIs-json/daily-weather.json))
  <img src="https://i.imgur.com/MaWSYt7.png" alt="3rd pipeline">

  #### Linked Services / Datasets / Triggers
    Here are the linked services, datasets, and triggers used for the pipelines.

    [Linked Services](ADF/Linked_Services)
  
    <img src="https://i.imgur.com/0HDfmV6.png" alt="Ls">

    [Datasets](ADF/Datasets)
      
    <img src="https://i.imgur.com/2dJALwo.png" alt="Ds">

     [Triggers](ADF/Triggers)    
  
    <img src="https://i.imgur.com/osP9mQU.png" alt="Trigg">

    Here we have a trigger (daily_trigger) applied to Pipeline 2, which runs daily, while the other trigger runs hourly (hourly_trigger) (this can easily be adjusted, for example, to every 5 minutes) and is used for Pipeline 1. As for Pipeline 3, since it handles a bulk load of the past 10 years, a trigger is not necessary—it only needs to be executed once.
    

### 2. Snowflake
  - As a first step, we need to create a storage integration between Snowflake and Azure. This is primarily a secure permission/authentication mechanism between Snowflake and an external storage service (in this case, Azure). Next, we create an external stage, which is an object that points to a specific location of the external files. Additionally, a notification integration is created, as it is required to automate Snowpipes.
    - This can be seen in the following SQL worksheet: [storage_integration.txt](Snowflake/Worksheets/storage_integration.txt)
  - Then, we need to create the internal storage area within Snowflake:
    - We create the "weather" database, and then create several schemas ("landing", "raw", "silver", and "gold").
    - We create a file format. 
    - Once the external stage and landing layer are set up, we can query the data without storing it in Snowflake, and we can navigate through the JSON using the $ notation.
    - The implementation is available in the following worksheet: [schema_creation.txt](Snowflake/Worksheets/schema_creation.txt)
  - Next, we create the tables for the raw layer. Four tables are created, each storing the full JSON object in one column, along with the filename and the processing timestamp (one for each object of study).
    <img src="https://i.imgur.com/tqXEKJ2.png" alt="table example1">
    - Then, we proceed to create the Snowpipes, which will ingest data from Azure into Snowflake whenever a blob is created inside a container, using Event Grid notifications.
    - The steps are illustrated in the following worksheet: [raw_layer.txt](Snowflake/Worksheets/raw_layer.txt)
  - Then, we create the dynamic tables in the silver layer, which have the capability to either process all the data from the source table (full load) or only process the new data (incremental load). [Snowflake Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)  are tables that automatically update based on a defined query. They work like materialized views that stay continuously or periodically refreshed, allowing incremental loads, automated transformations, and simplifying the development of data pipelines without the need for additional code.
    - SQL code for this step is provided in the following worksheet: [silver_layer.txt](Snowflake/Worksheets/silver_layer.txt)
    <img src="https://i.imgur.com/aIY5myU.png" alt="table example2">
  - Finally, we create the dimension tables and the fact tables, which will also be dynamic tables, as they are derived from the tables created in the silver layer.
    - The corresponding scripts can be found here: [dimension_tables.txt](Snowflake/Worksheets/dimension_tables.txt) / [gold_layer.txt](Snowflake/Worksheets/gold_layer.txt)

### 3. Connect Snowflake with Power BI
- In this step, we need to connect the "gold" schema to Power BI. This allows us to create interactive dashboards and work with the data in real time.
 - The model view can be seen here:
  - <img src="https://i.imgur.com/i5i5nGG.png" alt="model">
 

Here you can see the [video](https://drive.google.com/file/d/1dHaZ7ptRNtrSOl9Ww-Q85RGjIFvcayiR/view?usp=sharing) that documents the implementation of the ETL.



 

 

 


 

