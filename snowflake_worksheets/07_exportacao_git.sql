---- Nessas Worksheet eu extrai as tableas criadas no "silver stage" para fins de documentação do projeto ----
USE rest_india.public;
USE ROLE ACCOUNTADMIN;

---- Criando objeto File Format para extração ----
CREATE OR REPLACE FILE FORMAT rest_india.public.csv_extract_ff
    TYPE = CSV
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = NONE
    NULL_IF='';
    
DESC FILE FORMAT rest_india.public.csv_extract_ff;

---- Criando external stage para extração das tabelas silver ----
CREATE OR REPLACE STAGE rest_india.public.silver_extract_st
    URL = 's3://challenge-bi-s3/Semana-2/silver_extract/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.csv_extract_ff;

---- extraindo tabela restaurant
COPY INTO @rest_india.public.silver_extract_st/restaurant.csv
FROM rest_india.public.restaurant
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;

---- extraindo tabela country_name
COPY INTO @rest_india.public.silver_extract_st/country.csv
FROM rest_india.public.country
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;
    
---- extraindo tabela rest_cuisine
COPY INTO @rest_india.public.silver_extract_st/rest_cuisine.csv
FROM rest_india.public.rest_cuisine
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;
        
---- extraindo tabela currency
COPY INTO @rest_india.public.silver_extract_st/currency.csv
FROM rest_india.public.currency
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;
    
---- Criando external stage para extração das tabelas gold ----
CREATE OR REPLACE STAGE rest_india.public.gold_extract_st
    URL = 's3://challenge-bi-s3/Semana-2/gold_extract/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.csv_extract_ff;


---- extraindo tabela restaurant_ds ----
COPY INTO @rest_india.public.gold_extract_st/restaurant_ds.csv
FROM rest_india_ds.public.restaurant_ds
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;

---- extraindo tabela rest_cuisine_ds ----
COPY INTO @rest_india.public.gold_extract_st/rest_cuisine_ds.csv
FROM rest_india_ds.public.rest_cuisine_ds
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 20000000
    HEADER = TRUE;