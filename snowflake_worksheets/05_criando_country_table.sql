USE rest_india.public;
USE ROLE ACCOUNTADMIN;

---- Sincronizar time zone com horário de São Paulo ----
ALTER SESSION SET timezone = 'America/Sao_Paulo';

---- Criando objeto File Format considerando array externo ----
CREATE OR REPLACE FILE FORMAT rest_india.public.csv_ff
    TYPE = CSV
    SKIP_HEADER = 1;
    
DESC FILE FORMAT csv_ff;

---- Criando stage object que acessa a pasta no bucket S3 ----
CREATE OR REPLACE STAGE rest_india.public.country_st
    URL = 's3://challenge-bi-s3/Semana-2/codigo_paises/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.csv_ff;
    
DESC STAGE rest_india.public.country_st;

LIST @rest_india.public.country_st;

---- Criando Tabela 'country' ----

CREATE OR REPLACE TABLE rest_india.public.country (
    country_id INT NOT NULL,
    country_name STRING NOT NULL
);

COPY INTO rest_india.public.country
FROM @rest_india.public.country_st;

SELECT * FROM rest_india.public.country;