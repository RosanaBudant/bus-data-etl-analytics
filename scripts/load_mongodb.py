import pandas as pd
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Ler o arquivo CSV
df = pd.read_csv("itinerario_onibus.csv", encoding='ISO-8859-1', sep=';')

# Substituir NaN por string vazia
df = df.fillna('')

# Dividir em blocos de 500 registros
tamanho_bloco = 500
total_blocos = (len(df) // tamanho_bloco) + 1

for bloco in range(total_blocos):
    inicio = bloco * tamanho_bloco
    fim = min((bloco + 1) * tamanho_bloco, len(df))
    df_bloco = df[inicio:fim]
    
    with open(f'inserts_bloco_{bloco+1}.js', 'w', encoding='utf-8') as f:
        f.write("use BDOnibus\n")
        f.write("db.Itinerarios.insertMany([\n")
        
        documentos = []
        for _, row in df_bloco.iterrows():
            doc = {
                "data_extracao": str(row['data_extracao']),
                "linha": str(row['linha']),
                "sentido": str(row['sentido']),
                "numero_sequencia": int(row['numero_sequencia']) if row['numero_sequencia'] != '' else 0,
                "tipo": str(row['tipo']),
                "nome": str(row['nome']),
                "endereco_logradouro": str(row['endereco_logradouro']),
                "codigo": int(row['codigo']) if row['codigo'] != '' else 0
            }
            documentos.append(doc)
        
        for i, doc in enumerate(documentos):
            json_doc = json.dumps(doc, ensure_ascii=False, default=str)
            if i < len(documentos) - 1:
                f.write(f"  {json_doc},\n")
            else:
                f.write(f"  {json_doc}\n")
        
        f.write("]);\n")
    
    print(f"Bloco {bloco+1} de {total_blocos} criado com {len(df_bloco)} registros")