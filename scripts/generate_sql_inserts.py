import pandas as pd
import sys

sys.stdout.reconfigure(encoding='utf-8')

df = pd.read_csv("tabela_horaria_onibus.csv", encoding='ISO-8859-1', sep=';')

# Gerar os comandos INSERT
for _, row in df.iterrows():
    print(f"INSERT INTO BDHorarioOnibus (data_extracao, linha, sentido, tipo_tabela, tipo_dia, horario_largada, adaptado_deficiente) VALUES ('{row['data_extracao']}', '{row['linha']}', '{row['sentido']}', '{row['tipo_tabela']}', '{row['tipo_dia']}', '{row['horario_largada']}', '{row['adaptado_deficiente']}');")