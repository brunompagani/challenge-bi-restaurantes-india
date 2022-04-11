USE rest_india.public;
USE ROLE ACCOUNTADMIN;
---- Sincronizar time zone com horário de São Paulo ----
ALTER SESSION SET timezone = 'America/Sao_Paulo';

---- Realizando UPSERT de novos valores na tabela com arquivos subsequentes ----

--> Alter this variable to merge new file
SET FILE_NAME_PATTERN = '.*file5.json';


--> Create Temp Table as staging area
CREATE OR REPLACE TEMPORARY TABLE rest_india.public.json_parsed
AS SELECT 
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
        @rest_india.public.restaurante_st (PATTERN => $FILE_NAME_PATTERN) stg,
        lateral flatten(input => stg.$1:restaurants) rt;

--> Deduplicate table
CREATE OR REPLACE TEMPORARY TABLE rest_india.public.json_parsed_dedup       
AS SELECT 
    DISTINCT *
FROM json_parsed;

--> Drop first temp table
DROP TABLE rest_india.public.json_parsed;

--> Check for rest_id duplicates,,,
-- SELECT rest_id, COUNT(1) AS num_records
-- FROM rest_india.public.json_parsed_dedup
-- GROUP BY rest_id
-- ORDER BY num_records DESC;

--> Execute MERGE operation
MERGE INTO rest_india.public.restaurant tgt
USING rest_india.public.json_parsed_dedup src
ON tgt.rest_id = src.rest_id
WHEN MATCHED THEN UPDATE
    SET tgt.cuisines = src.cuisines,
        tgt.avg_cost_for_two = src.avg_cost_for_two,
        tgt.currency = src.currency,
        tgt.has_table_booking = src.has_table_booking,
        tgt.has_online_delivery = src.has_online_delivery,
        tgt.is_delivering = src.is_delivering,
        tgt.switch_to_order_menu = src.switch_to_order_menu,
        tgt.price_range = src.price_range,
        tgt.aggregate_rating = src.aggregate_rating,
        tgt.rating_color = src.rating_color,
        tgt.rating_text = src.rating_text,
        tgt.num_of_votes = src.num_of_votes,
        tgt.meta_updated_ts = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT
    (rest_id, rest_name, country_id, city_id, city_name, address, locality, locality_verbose,
     longitude, latitude, cuisines, avg_cost_for_two, currency, has_table_booking, 
     has_online_delivery, is_delivering, switch_to_order_menu, price_range, aggregate_rating,
     rating_color, rating_text, num_of_votes
    ) VALUES
    (
    src.rest_id, src.rest_name, src.country_id, src.city_id, src.city_name, src.address, src.locality, src.locality_verbose,
    src.longitude, src.latitude, src.cuisines, src.avg_cost_for_two, src.currency, src.has_table_booking, 
    src.has_online_delivery, src.is_delivering, src.switch_to_order_menu, src.price_range, src.aggregate_rating,
    src.rating_color, src.rating_text, src.num_of_votes
);

--> Drop second temp table
DROP TABLE rest_india.public.json_parsed_dedup;

-- SELECT * FROM rest_india.public.restaurant ORDER BY meta_updated_ts;