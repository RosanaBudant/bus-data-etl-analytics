import pandas as pd

df = pd.read_csv("itinerario_onibus.csv", encoding='ISO-8859-1', sep=';')

print("Primeiras 5 linhas:")
print(df.head())

print("\n\nColunas:")
print(df.columns.tolist())

print("\n\nVerificar valores 'nan' na coluna nome:")
print(df[df['nome'].astype(str).str.contains('nan', case=False, na=False)][['linha', 'nome', 'tipo']].head(10))

print("\n\nValores únicos em 'nome' (primeiros 20):")
print(df['nome'].value_counts().head(20))