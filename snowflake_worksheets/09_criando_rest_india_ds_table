USE rest_india_ds.public;
USE ROLE ACCOUNTADMIN;

-- Criando procedure que atualiza os câmbios --
CREATE OR REPLACE PROCEDURE rest_india.public.refresh_rest_india_ds_procedure ()
    RETURNS STRING
    LANGUAGE SQL
AS
    BEGIN
    ---- Criando tabela restaurant_ds
    CREATE OR REPLACE TABLE rest_india_ds.public.restaurant_ds
    AS
    SELECT 
        res.rest_id,
        res.rest_name,
        cou.country_name,
        res.city_name,
        res.address,
        res.locality,
        res.locality_verbose,
        res.longitude,
        res.latitude,
        res.cuisines,
        ROUND(res.avg_cost_for_two * cur.usd, 2) AS avg_cost_for_two_usd,
        ROUND(res.avg_cost_for_two * cur.brl, 2) AS avg_cost_for_two_brl,
        ROUND(res.avg_cost_for_two * cur.eur, 2) AS avg_cost_for_two_eur,
        cur.code AS original_currency,
        res.has_table_booking,
        res.has_online_delivery,
        res.price_range,
        res.aggregate_rating,
        res.num_of_votes,
        res.rating_color,
        res.rating_text
    FROM 
        rest_india.public.restaurant res
            JOIN
        rest_india.public.country cou ON res.country_id = cou.country_id
            JOIN
        rest_india.public.currency cur ON res.currency = cur.symbol;
        
    RETURN 'Tabela rest_india_ds atualizada com sucesso';
    END;

-- Criando Task que atualiza tabela rest_india_ds após atualização diária da tabela currency  --
ALTER TASK rest_india.public.currency_refresh_task SUSPEND;

CREATE OR REPLACE TASK rest_india.public.refresh_rest_india_ds_task
    WAREHOUSE = COMPUTE_WH
    AFTER rest_india.public.currency_refresh_task
AS CALL refresh_rest_india_ds_procedure();

ALTER TASK rest_india.public.refresh_rest_india_ds_task RESUME;
ALTER TASK rest_india.public.currency_refresh_task RESUME;

-- ALTER TASK rest_india.public.refresh_rest_india_ds_task SUSPEND;

-- SHOW PROCEDURES in rest_india.public;
-- SHOW TASKS in rest_india.public;

-- SELECT * FROM rest_india_ds.public.restaurant_ds;

