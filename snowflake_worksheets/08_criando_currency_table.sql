USE rest_india.public;
USE ROLE ACCOUNTADMIN;

---- Criando objeto File Format ----
CREATE OR REPLACE FILE FORMAT rest_india.public.csv_ff
    TYPE = CSV
    SKIP_HEADER = 1;
    
-- DESC FILE FORMAT rest_india.public.csv_ff;

---- Criando stage object que acessa a pasta no bucket S3 ----
CREATE OR REPLACE STAGE rest_india.public.currency_st
    URL = 's3://challenge-bi-s3/Semana-2/currency/'
    STORAGE_INTEGRATION = semana2_s3_si
    FILE_FORMAT = rest_india.public.csv_ff;
    
-- DESC STAGE rest_india.public.currency_st;

-- LIST @rest_india.public.currency_st;

---- Criando tabela ----
CREATE OR REPLACE TABLE rest_india.public.currency (
    symbol VARCHAR(8),
    code CHAR(3),
    usd FLOAT,
    brl FLOAT,
    eur FLOAT
);

---- Validando COPY command ----
-- COPY INTO rest_india.public.currency
-- FROM @rest_india.public.currency_st
--     VALIDATION_MODE = RETURN_12_ROWS;

---- Criando Pipe ----
CREATE OR REPLACE PIPE currency_pipe
    AUTO_INGEST = TRUE
AS 
COPY INTO rest_india.public.currency
FROM @rest_india.public.currency_st
    ON_ERROR = SKIP_FILE;

---- Pegando notification_channel para setar a notificação de eventos na AWS ----
-- DESC PIPE currency_pipe;

SELECT * FROM rest_india.public.currency;