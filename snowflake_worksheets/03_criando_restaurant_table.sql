USE rest_india.public;
USE ROLE ACCOUNTADMIN;

---- Sincronizar time zone com horário de São Paulo ----
ALTER SESSION SET timezone = 'America/Sao_Paulo';

---- Criando objeto File Format considerando array externo ----
CREATE OR REPLACE FILE FORMAT rest_india.public.json_ff
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE
    NULL_IF = ('\\N', 'NULL', '', ' ');
    
DESC FILE FORMAT json_ff;

---- Criando stage object que acessa a pasta no bucket S3 ----
CREATE OR REPLACE STAGE rest_india.public.restaurante_st
    URL = 's3://challenge-bi-s3/Semana-2/restaurante/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.json_ff;
    
DESC STAGE rest_india.public.restaurante_st;

LIST @rest_india.public.restaurante_st;

---- Criando Tabela 'restaurant' ----
CREATE OR REPLACE TABLE rest_india.public.restaurant (
    rest_id INT NOT NULL,
    rest_name STRING NOT NULL,
    country_id INT,
    city_id INT,
    city_name STRING,
    address STRING,
    locality STRING,
    locality_verbose STRING,
    longitude FLOAT,
    latitude FLOAT,
    cuisines STRING,
    avg_cost_for_two INT,
    currency STRING,
    has_table_booking BOOLEAN,
    has_online_delivery BOOLEAN,
    is_delivering BOOLEAN,
    switch_to_order_menu BOOLEAN,
    price_range INT,
    aggregate_rating FLOAT,
    rating_color STRING,
    rating_text STRING,
    num_of_votes INT,
    meta_created_ts TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(),
    meta_updated_ts TIMESTAMP_LTZ NULL
);

---- Inserindo primeiros valores na Tabela ----
INSERT INTO rest_india.public.restaurant (
    rest_id, rest_name, country_id, city_id, city_name, address, locality, locality_verbose,
    longitude, latitude, cuisines, avg_cost_for_two, currency, has_table_booking, 
    has_online_delivery, is_delivering, switch_to_order_menu, price_range, aggregate_rating,
    rating_color, rating_text, num_of_votes
)
    SELECT 
        rt.value:restaurant:R:res_id::INT AS rest_id,
        rt.value:restaurant:name::STRING AS rest_name,
        rt.value:restaurant:location:country_id::INT AS country_id,
        rt.value:restaurant:location:city_id::INT AS city_id,
        rt.value:restaurant:location:city::STRING AS city_name,
        rt.value:restaurant:location:address::STRING AS address,
        rt.value:restaurant:location:locality::STRING AS locality,
        rt.value:restaurant:location:locality_verbose::STRING AS locality_verbose,
        NULLIF(rt.value:restaurant:location:longitude::FLOAT, 0) AS longitude,
        NULLIF(rt.value:restaurant:location:latitude::FLOAT, 0) AS latitude,
        rt.value:restaurant:cuisines::STRING AS cuisines,
        NULLIF(rt.value:restaurant:average_cost_for_two::INT, 0) AS avg_cost_for_two,
        rt.value:restaurant:currency::STRING AS currency,
        rt.value:restaurant:has_table_booking::INT::BOOLEAN AS has_table_booking,
        rt.value:restaurant:has_online_delivery::INT::BOOLEAN AS has_online_delivery,
        rt.value:restaurant:is_delivering_now::INT::BOOLEAN AS is_delivering,
        rt.value:restaurant:switch_to_order_menu::INT::BOOLEAN AS switch_to_order_menu,
        rt.value:restaurant:price_range::INT AS price_range,
        rt.value:restaurant:user_rating:aggregate_rating::FLOAT AS aggregate_rating,
        rt.value:restaurant:user_rating:rating_color::STRING AS rating_color,
        rt.value:restaurant:user_rating:rating_text::STRING AS rating_text,
        rt.value:restaurant:user_rating:votes::INT AS num_of_votes
    FROM 
        @rest_india.public.restaurante_st (PATTERN => '.*file1.json') stg,
        lateral flatten(input => stg.$1:restaurants) rt
;

---- See table ----
SELECT * FROM rest_india.public.restaurant;

SELECT 
    COUNT_IF(latitude = 0) AS zero_lat,
    COUNT_IF(longitude = 0) AS zero_long
FROM rest_india.public.restaurant;

---- Check for rest_id duplicates ----
SELECT rest_id, COUNT(1) AS num_records
FROM rest_india.public.restaurant
GROUP BY rest_id
ORDER BY num_records DESC;

