import pandas_datareader.data as web
from datetime import datetime , timedelta
import pandas as pd
from pathlib import Path
import s3fs
from secrets import s3_access_key_id, s3_secret_access_key

def moedas_em_dolar(moedas_dict):
    ticker_yahoo = lambda x : f'{x}USD=X'
    tickers = []

    for k, i in moedas_dict.items():
            tickers.append(ticker_yahoo(i))

    start = datetime.today() - timedelta(5)

    try:
        yahoo = web.get_data_yahoo(tickers, start=start)['Close']
        yahoo = yahoo.fillna(method='ffill')
        yahoo = yahoo.iloc[-1,:]
        yahoo.index = [ x[:3] for x in yahoo.index ]
        yahoo.name = 'usd'
    except:
        print("Houve falha na extração dos câmbios")

    return yahoo

def cria_df_base(moedas_dict):
    currency_table = pd.DataFrame({
        'symbol' : moedas_dict.keys(),
        'code' : moedas_dict.values()
    })
    return currency_table

def coluna_em_moeda(df, cod_moeda):
    df[cod_moeda.lower()] = df['usd'] / df.loc[df['code'] == cod_moeda, 'usd'].values[0]
    return df

def salvar_localmente(df):
    local_out_dir = Path('./base_de_dados/bronze')

    try:
        df.to_csv(f'{local_out_dir}/currency.csv', index=False)
        print(f'Arquivo salvo localmente em {local_out_dir.resolve()}')
    except:
        print('Extração local falhou.')

def upar_no_s3(df, bucket_s3, key, secret):
    try:
        s3 = s3fs.S3FileSystem(key=key, secret=secret)

        with s3.open(f'{bucket_s3}/currency.csv','w') as f:
            df.to_csv(f, index=False)

        print(f'Arquivo salvo em {bucket_s3}')
    except:
        print(f'Não foi possível upar o arquivo em {bucket_s3}')


if __name__ == '__main__':

    ### Dicionário de moedas na base e seus respectivos códigos ###
    moedas_dict = {
        'R$':'BRL',
        '$' : 'USD',
        '£' : 'GBP',
        'P' : 'BWP',
        'IDR' : 'IDR',
        'AED' : 'AED',
        'LKR' : 'LKR',
        'NZ$' : 'NZD',
        'TL' : 'TRY',
        'QR' : 'QAR',
        'EUR' : 'EUR'
    }

    ### Extraindo equivalência com Dólar do Yahoo! Finance ###
    usd = moedas_em_dolar(moedas_dict)

    ### Criando DataFrame ###
    currency_table = cria_df_base(moedas_dict)
    currency_table = currency_table.merge(usd, left_on='code', right_index=True)

    currency_table = coluna_em_moeda(currency_table, 'BRL')
    currency_table = coluna_em_moeda(currency_table, 'EUR')


    ### Salvando localmente ###
    # salvar_localmente(currency_table)

    ### Salvando no Bucket S3 ###
    upar_no_s3(currency_table, 's3://challenge-bi-s3/Semana-2/currency', s3_access_key_id, s3_secret_access_key)


