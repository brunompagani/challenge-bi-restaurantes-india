USE rest_india.public;

---- Criando objeto File Format considerando array externo ----
CREATE OR REPLACE FILE FORMAT rest_india.public.json_ff
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE;

---- Criando stage object que acessa a pasta no bucket S3 ----
CREATE OR REPLACE STAGE rest_india.public.restaurante_st
    URL = 's3://challenge-bi-s3/Semana-2/restaurante/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.json_ff;
    
DESC STAGE rest_india.public.restaurante_st;

LIST @rest_india.public.restaurante_st;

---- Visualizando json inicial ----
SELECT 
    $1:restaurants
FROM 
    @rest_india.public.restaurante_st;

---- Ajustando para expandir todos os arrays com múltiplos restaurantes ----
SELECT 
    rt.value,
    rt.index AS array_order
FROM 
    @rest_india.public.restaurante_st stg,
    lateral flatten(input => stg.$1:restaurants) rt
LIMIT 1000;

---- Expandindo para visualização em formato tabular ----
SELECT 
    rt.value:restaurant:R:res_id::INT AS rest_id,
    rt.value:restaurant:name::STRING AS rest_name,
    rt.value:restaurant:location:country_id::INT AS country_id,
    rt.value:restaurant:location:city_id::INT AS city_id,
    rt.value:restaurant:location:city::STRING AS city_name,
    rt.value:restaurant:location:address::STRING AS address,
    rt.value:restaurant:location:locality::STRING AS locality,
    rt.value:restaurant:location:locality_verbose::STRING AS locality_verbose,
    rt.value:restaurant:location:longitude::FLOAT AS longitude,
    rt.value:restaurant:location:latitude::FLOAT AS latitude,
    rt.value:restaurant:cuisines::STRING AS cuisines,
    rt.value:restaurant:average_cost_for_two::INT AS avg_cost_for_two,
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
    @rest_india.public.restaurante_st stg,
    lateral flatten(input => stg.$1:restaurants) rt
LIMIT 1000;