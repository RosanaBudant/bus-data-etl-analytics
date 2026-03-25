# 🚌 Bus Data ETL & Analytics

Projeto de engenharia e análise de dados utilizando Python, SQL e MongoDB para processamento de dados de transporte público.

O projeto implementa um pipeline completo de dados (ETL), incluindo extração, transformação, carga e análise de dados provenientes de múltiplas fontes.

---

## 📌 Objetivo

Demonstrar habilidades práticas em:

* Engenharia de dados (ETL)
* Limpeza e transformação de dados
* Integração entre diferentes tecnologias
* Consultas analíticas em Data Lake

---

## 🧱 Arquitetura do Projeto

O pipeline segue as seguintes etapas:

### 📥 Extract

* Leitura de arquivos CSV com diferentes formatos e encodings
* Consulta a dados em Data Lake utilizando `OPENROWSET`

---

### 🔄 Transform

* Normalização de horários (ex: `25:30` → `01:30`)
* Limpeza de dados inconsistentes
* Tratamento de valores nulos

---

### 📤 Load

#### 🟢 MongoDB (NoSQL)

* Inserção de dados em lote (batch processing)
* Geração de scripts `insertMany`
* Tratamento de grandes volumes de dados

#### 🔵 SQL (Relacional)

* Geração de comandos `INSERT INTO`
* Preparação de carga para banco relacional

---

### 📊 Analytics

* Consultas SQL diretamente no Data Lake
* JOIN entre dados de diferentes origens (PostgreSQL + MongoDB)
* Análises de horários, linhas e itinerários

---

## 🛠️ Tecnologias

* Python 3
* pandas
* MongoDB
* SQL (Data Lake / OPENROWSET)

---

## 📂 Estrutura do projeto

```bash
bus-data-etl-analytics/
│
├── data/
├── scripts/
│   ├── transform_horarios.py
│   ├── transform_itinerario.py
│   ├── load_mongodb_batches.py
│   └── generate_sql_inserts.py
│
├── sql/
│   ├── queries_data_lake.sql
│   └── inserts_exemplo.sql
│
└── README.md
```

---

## 📊 Exemplos de análises

* Quantidade de horários por linha
* Distribuição por período do dia (manhã, tarde, noite)
* Relação entre linhas e pontos de parada
* Primeiro e último horário por linha
* Sequência de itinerários

---

## 💡 Diferenciais

* Pipeline completo de dados (ETL)
* Integração entre múltiplas fontes (CSV, Data Lake, MongoDB)
* Processamento em lote para grandes volumes
* Uso de dados reais com inconsistências

---

## 🚀 Possíveis melhorias

* Automação do pipeline (Airflow)
* Criação de dashboards (Power BI)
* API para consulta dos dados
* Testes automatizados

---

## 👩‍💻 Autora

Projeto desenvolvido por Rosana Budant como prática de engenharia e análise de dados.
