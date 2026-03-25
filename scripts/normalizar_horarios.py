import pandas as pd

df = pd.read_csv('tabela_horaria_onibus.csv', encoding='latin-1', sep=';')

print("Arquivo carregado com encoding: latin-1 e separador ;")

nome_da_coluna = 'horario_largada'

# Corrigir e converter para formato 00:00
def corrigir_horario(horario):
    if pd.isna(horario):
        return horario
        
    horario_str = str(horario).strip()
    
    if ':' in horario_str:
        partes = horario_str.split(':')
        hora = partes[0]
        
        if hora == '24': hora = '00'
        elif hora == '25': hora = '01'
        elif hora == '26': hora = '02'  
        elif hora == '27': hora = '03'
        
        return f"{hora.zfill(2)}:{partes[1]}"
    
    return horario_str

df[nome_da_coluna] = df[nome_da_coluna].apply(corrigir_horario)

df.to_csv('arquivo_corrigido.csv', index=False, encoding='latin-1', sep=';')

print("Horários corrigidos para formato 00:00!")
print("Arquivo salvo como: arquivo_corrigido.csv")

print("\nAmostra dos horários corrigidos:")
print(df[nome_da_coluna].head(15))
