USE rest_india.public;
USE ROLE ACCOUNTADMIN;

---- Criando tabela ----
CREATE OR REPLACE TABLE rest_india.public.currency (
    symbol VARCHAR(8),
    code CHAR(3),
    usd FLOAT,
    brl FLOAT,
    eur FLOAT,
    ref_date DATE DEFAULT CURRENT_DATE
);

---- Validando COPY command ----
-- COPY INTO rest_india.public.currency
-- FROM @rest_india.public.currency_st
--     VALIDATION_MODE = RETURN_12_ROWS;

-- SELECT * FROM rest_india.public.currency;

-- Criando procedure que atualiza os câmbios --
CREATE OR REPLACE PROCEDURE currency_refresh_procedure ( REF_DATE DATE )
    RETURNS STRING
    LANGUAGE SQL
    COMMENT = 'Procedure que "trunca" tabela currency e atualiza seus valores'
AS
    BEGIN
        ---- Criando objeto File Format ----
        CREATE OR REPLACE FILE FORMAT rest_india.public.csv_ff
            TYPE = CSV
            SKIP_HEADER = 1;

        ---- Criando stage object que acessa a pasta no bucket S3 ----
        CREATE OR REPLACE STAGE rest_india.public.currency_st
            URL = 's3://challenge-bi-s3/Semana-2/currency/'
            STORAGE_INTEGRATION = semana2_s3_si
            FILE_FORMAT = rest_india.public.csv_ff;

        TRUNCATE TABLE rest_india.public.currency;

        COPY INTO rest_india.public.currency (
            symbol, code, usd, brl, eur    
        )
            FROM @rest_india.public.currency_st
            ON_ERROR = ABORT_STATEMENT;

        RETURN 'Tabela currency atualizada com sucesso';
    END;

-- Criando Task que atualiza diariamente os câmbios --
CREATE OR REPLACE TASK currency_refresh_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON * 12 * * * America/Sao_Paulo'
AS CALL currency_refresh_procedure(CURRENT_DATE);

ALTER TASK currency_refresh_task RESUME;

-- SHOW PROCEDURES;
-- SHOW TASKS;