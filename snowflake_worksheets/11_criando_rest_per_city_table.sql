USE rest_india_ds.public;
USE ROLE ACCOUNTADMIN;

-- Criando procedure que atualiza rest_cuisine_ds --
CREATE OR REPLACE PROCEDURE rest_india.public.refresh_rest_per_city_ds_procedure ()
    RETURNS STRING
    LANGUAGE SQL
AS
    BEGIN
    ---- Criando temp table para join
    CREATE OR REPLACE TEMPORARY TABLE rest_india.public.rest_per_city_temp
    AS
    SELECT 
        r.city_name AS city_name,
        c.country_name AS country_name,
        COUNT(r.rest_id) AS rest_per_city
    FROM 
        rest_india.public.restaurant r
            JOIN
        rest_india.public.country c ON r.country_id = c.country_id
    GROUP BY 
        r.city_name,
        c.country_name
    ORDER BY
        c.country_name,
        rest_per_city DESC;

    ---- Criando tabela restaurant_ds
    CREATE OR REPLACE TABLE rest_india_ds.public.rest_per_city_ds
    AS
    SELECT
        res.city_id,
        res.city_name,
        cou.country_name,
        ROUND(res.avg_cost_for_two * cur.usd, 2) AS avg_cost_for_two_usd,
        ROUND(res.avg_cost_for_two * cur.brl, 2) AS avg_cost_for_two_brl,
        ROUND(res.avg_cost_for_two * cur.eur, 2) AS avg_cost_for_two_eur,
        res.has_table_booking,
        res.has_online_delivery,
        res.price_range,
        res.aggregate_rating,
        res.num_of_votes,
        res.rating_color,
        res.rating_text,
        rpc.rest_per_city
    FROM 
        rest_india.public.restaurant res
            JOIN
        rest_india.public.country cou ON res.country_id = cou.country_id
            JOIN
        rest_india.public.currency cur ON res.currency = cur.symbol
            JOIN
        rest_india.public.rest_per_city rpc ON (res.city_name = rpc.city_name) AND (cou.country_name = rpc.country_name);
        
    RETURN 'Tabela rest_per_city_ds atualizada com sucesso';
    END;

-- Criando Task que atualiza tabela rest_cuisine_ds após atualização diária da tabela restaurant_ds  --
ALTER TASK rest_india.public.currency_refresh_task SUSPEND;
ALTER TASK rest_india.public.refresh_restaurant_ds_task SUSPEND;
ALTER TASK rest_india.public.refresh_rest_cuisine_ds_task SUSPEND;


CREATE OR REPLACE TASK rest_india.public.refresh_rest_per_city_ds_task
    WAREHOUSE = COMPUTE_WH
    AFTER rest_india.public.refresh_rest_cuisine_ds_task
AS CALL rest_india.public.refresh_rest_per_city_ds_procedure();

ALTER TASK rest_india.public.currency_refresh_task RESUME;
ALTER TASK rest_india.public.refresh_restaurant_ds_task RESUME;
ALTER TASK rest_india.public.refresh_rest_cuisine_ds_task RESUME;
ALTER TASK rest_india.public.rest_india.public.refresh_rest_per_city_ds_task RESUME;

-- ALTER TASK rest_india.public.refresh_rest_cuisine_ds_task SUSPEND;

-- SHOW PROCEDURES in rest_india.public;
-- SHOW TASKS in rest_india.public;

-- SELECT * FROM rest_india_ds.public.rest_cuisine_ds LIMIT 1000;

-- CALL rest_india.public.refresh_rest_cuisine_ds_procedure();

