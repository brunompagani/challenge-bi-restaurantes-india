# restaurantes-india-bi
Repositório criado para relatar um projeto para o Alura Challenge em BI - Semana 2
# Challenge de BI - Semana 2 (Restaurantes)

## ACESSE O DASHBOARD >> [AQUI](https://datastudio.google.com/reporting/a6749a13-527d-4dd7-83bf-5ac34b44d51f/page/p_0qnkgjd1tc "Projeto Alura Food") <<

## Habilidades Demonstradas

Atributo | Complexidade
-------- | ------------
Complexidade do Projeto | ⭐️ ⭐️ ⭐️ 
Snowflakse SQL | ⭐️ ⭐️ ⭐️ ⭐️ 
Python | ⭐️ ⭐️ 
Pipeline de dados | ⭐️ ⭐️ 
Extração de dados | ⭐️ ⭐️ 
Transformação de Dados | ⭐️ ⭐️ ⭐️ 
Limpeza de dados | ⭐️ ⭐️ ⭐️ 
Carregamento de Dados | ⭐️ ⭐️ ⭐️ 
Data Warehouse | ⭐️ ⭐️ 
Análise de Dados | ⭐️ ⭐️ 
Criação de Dashboards em Google Data Studio | ⭐️ ⭐️ ⭐️ 

![picture alt](https://github.com/brunompagani/challenge-bi-restaurantes-india/blob/b7e10d0bae0ff428d483e542cd5cb3c318dc91be/git%20resouces/arquitetura-final.png)
###### Fonte: Autoria própria

## Resumo

O Projeto foi proposto pela Alura (escola de tecnologia virtual), como parte do Challenge de BI. Esse é o segundo de 3 desafios dessa edição.

Nesse projeto, a empresa fictícia, Alura Food quer abrir um restaurante de comida indiana na Índia, por isso me contratarando para organizar e analisar dados extraídos da plataforma Zomato (app de restaurantes da Índia) em formato .json, apresentando dados e insights, de forma a auxiliar a tomada de decisão dos gestores da Alura Food na expansão pretendida.

Originalmente o projeto era apenas para consolidar 5 arquivos em formato 'json' com dados repetidos, consolidá-los em uma tabela, analisar os dados e exibí-los em um dashboard. Como meu foco hoje está mais em compreender a criação de pipelines de dados, eu decidi incrementar o projeto, pensando que arquivos similares pudessem ser recebidos posteriormente e tivessem que ser armazenados de forma estruturada em um Data Warehouse conectado a um Dashboard que atualiza diariamente com os novos dados sem interferência humana, conforme mostra a figura acima. 

As ferramentas escolhidas foram o Snowflake (incrível ferramenta de Data Warehouse que queria me aprofundar), o S3 da AWS como armazenamento e o Google Data Studio para análise e vizualização, além disso forma utilizadas as liguagens Python, para extração de dados do Yahoo! Finance e Snowflake SQL para criação e manipulação dos dados.

## Extração de Dados

#### Dados Fornecidos

Os pela própria empresa vieram em formato .json sem qualquer tipo de tratamento, esses dados foram originalmente extraídos da plataforma Zomato (app de restaurantes da Índia), além disso foi fornecido um arquivo .csv.

#### Acessando a API

Para obtenção de cotações atualizadas das diversas moedas na base foi ultizado um script em Python que obtêm esses valores da API do Yahoo! Finance e os envia para um Bucket S3 da AWS e é lido e utilizado diariamente, de forma automática no Snowflake.

#### Principais Vieses da Base

Reconhecer os vieses em uma base de dados é uma habilidade necessária para qualquer um que trabalha com dados, nesse caso os principais vieses percebidos da base são:

- Número Reduzido de Restaurantes em diversas cidades: A enorme maioria das cidades têm menos de 30 restaurantes cadastrados
- Não há indicação do período a qual se refere os dados, obrigando a cmoparação de restaurantes antigos com novos.

## Data Warehouse

Os três estados que os dados assumem antes de serem consumidos podem ser vistos na pasta base de dados, **essa pasta foi criada apenas para facilitar a visualização da estrutura final do Data Warehouse aqui no GitHub**, os dados da pasta bronze foram originalmente upados no Bucket S3 da AWS e os da pasta silver e gold foram gerados e armazenados no Snowflake.

## Snowflake

Os worksheets com todos os códigos utilizados para criação dos recursos, leitura e transformação dos dados e o agendamento da tarefas podem ser vistos na pasta "snowflake_worksheets".

## AWS
 
Buckets S3 da AWS foram utilizados para armazenar o Bronze Stage da minha arquitetura e conectados ao Snowflake, possibilitando o processamento desses dados para tabelas estruturadas (Silver stage) e posterior transformação para tabelas prontas para serem consumidas pela ferramenta de visualização escolhida.

## Google Data Studio

Afim de demonstrar habilidades em análise de dados e criação de dashboards, escolhi o Data Studio por ser uma ferramenta amplamente utilizada, com muitas funcionalidades, por ser gratuita e de fácil utilização em um sistema Mac OS, o que a torna uma ótima opção comparado com competidores como Power BI e Qlik Sense (não rodam em Mac OS) ou Tableau (versão gratuita possui muitas limitações em conectores).
