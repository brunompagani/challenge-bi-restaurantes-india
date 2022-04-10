---- Criando Snowflake Warehouse ----
CREATE WAREHOUSE IF NOT EXISTS
    "COMPUTE_WH" 
WITH 
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 600
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
COMMENT = 'Basic Warehouse';

USE WAREHOUSE COMPUTE_WH;

----- Criando banco de dados do projeto ----
CREATE OR REPLACE DATABASE rest_india;

USE rest_india;

---- Criando Storage Integration para acessar arquivos no Bucket S3 ----

USE ROLE ACCOUNTADMIN;

--> Nesse momento eu criei um "Role" na AWS com permissões AmazonS3FullAccess
--> Peguei o ARN usado para criar o objeto de Storage Integration

CREATE OR REPLACE STORAGE INTEGRATION semana2_s3_si
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    STORAGE_AWS_ROLE_ARN = <'HIDDEN_AWS_ROLE_ARN'>
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('s3://challenge-bi-s3/Semana-2/')
COMMENT = 'Storage Integration Object for Alura BI Challenge Week 2';

DESC INTEGRATION semana2_s3_si;

--> Com essa descrição é possível pegar o STORAGE_AWS_IAM_USER_ARN e STORAGE_AWS_EXTERNAL_ID para adicionar ao Role na AWS