---- Cria tabela para resolver atributo multi-valorado ----
CREATE OR REPLACE TABLE rest_india.public.rest_cuisine
AS SELECT
    rest_id,
    rest_name,
    TRIM(c.value::STRING) AS cuisine
FROM 
    rest_india.public.restaurant,
    lateral flatten(input=>split(cuisines, ','), OUTER=>FALSE) c
WHERE LENGTH(TRIM(cuisine)) > 0;

---- Análise ----
-- SELECT count(1) FROM rest_india.public.rest_cuisine;

-- SELECT 
--     rest_id,
--     MAX(rest_name),
--     count(1) num_of_cuisines 
-- FROM rest_india.public.rest_cuisine 
-- GROUP BY rest_id 
-- ORDER BY num_of_cuisines DESC
-- LIMIT 100;

---- Vê a tabela ----
-- SELECT * FROM rest_india.public.rest_cuisine LIMIT 100;