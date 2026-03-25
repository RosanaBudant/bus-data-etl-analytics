# 🚌 Bus Data Processing

Projeto em Python para tratamento e análise de dados de transporte público, com foco em limpeza e padronização de informações inconsistentes em arquivos CSV.

---

## 📌 Sobre o projeto

Bases de dados reais frequentemente apresentam problemas como:

* horários inválidos (ex: `25:30`)
* valores ausentes ou inconsistentes
* dados mal formatados

Este projeto resolve esses problemas aplicando técnicas de **data cleaning** com Python e pandas.

---

## ⚙️ Funcionalidades

### ⏱️ Normalização de horários

* Corrige horários acima de 24h
* Converte valores como `25:30` → `01:30`
* Garante padronização no formato `HH:MM`

---

### 🧹 Limpeza de dados de itinerário

* Identifica valores inválidos (como `"nan"` em texto)
* Remove ou corrige dados inconsistentes
* Analisa frequência de valores

---

## 🛠️ Tecnologias utilizadas

* Python 3
* pandas

---

## 📂 Estrutura do projeto

```
bus-data-processing/
│
├── data/
│   ├── tabela_horaria_onibus.csv
│   └── itinerario_onibus.csv
│
├── scripts/
│   ├── normalizar_horarios.py
│   └── analisar_itinerario.py
│
├── output/
│   ├── horarios_corrigidos.csv
│   └── itinerario_limpo.csv
│
└── README.md
```

---

## ▶️ Como executar

1. Instale as dependências:

```
pip install pandas
```

2. Coloque os arquivos CSV na pasta `data/`

3. Execute os scripts:

```
python scripts/normalizar_horarios.py
python scripts/analisar_itinerario.py
```

---

## 📊 Exemplos

### Antes (horários inválidos)

```
25:30
26:15
```

### Depois (corrigido)

```
01:30
02:15
```

---

## 💡 Possíveis melhorias

* Interface de linha de comando (CLI)
* Validação automática de colunas
* Geração de relatórios
* Testes automatizados

---

## 👩‍💻 Autora

Projeto desenvolvido por Rosana Budant como prática de análise e tratamento de dados com Python.
