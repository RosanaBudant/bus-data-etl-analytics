-- Consulta na tabela tipos_dia
SELECT
    id_tipo_dia,
    descricao
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    id_tipo_dia INT,
    descricao VARCHAR(50) COLLATE Latin1_General_100_CI_AI_SC_UTF8
) AS tipos_dia

-- Consulta da tabela linhas
SELECT
    codigo_linha,
    sentido
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    codigo_linha VARCHAR(20),
    sentido VARCHAR(56) COLLATE Latin1_General_100_CI_AI_SC_UTF8
) AS linhas

-- Consulta da tabela horario_oficial
SELECT
    id_horario,
    hora_saida,
    adaptado_deficiente,
    fk_linha,
    fk_tipo_dia
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    id_horario INT,
    hora_saida VARCHAR(10),
    adaptado_deficiente VARCHAR(5),
    fk_linha VARCHAR(20),
    fk_tipo_dia INT
) AS horarios

-- Join entre tabelas
SELECT
    h.id_horario,
    h.hora_saida,
    h.adaptado_deficiente,
    l.codigo_linha,
    l.sentido,
    td.descricao as tipo_dia
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    id_horario INT,
    hora_saida VARCHAR(10),
    adaptado_deficiente VARCHAR(5),
    fk_linha VARCHAR(20),
    fk_tipo_dia INT
) AS h
INNER JOIN OPENROWSET(
    BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = TRUE,
    FIELDTERMINATOR = ';',
    FIELDQUOTE = '"'
)
WITH (
    codigo_linha VARCHAR(20),
    sentido VARCHAR(56) COLLATE Latin1_General_100_CI_AI_SC_UTF8
) AS l ON h.fk_linha = l.codigo_linha
INNER JOIN OPENROWSET(
    BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = TRUE,
    FIELDTERMINATOR = ';',
    FIELDQUOTE = '"'
)
WITH (
    id_tipo_dia INT,
    descricao VARCHAR(50) COLLATE Latin1_General_100_CI_AI_SC_UTF8
) AS td ON h.fk_tipo_dia = td.id_tipo_dia

--Consulta básica Mongo
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    data_extracao VARCHAR(50),
    linha VARCHAR(20),
    sentido VARCHAR(56),
    numero_sequencia INT,
    tipo VARCHAR(50),
    nome VARCHAR(100),
    endereco_logradouro VARCHAR(200),
    codigo VARCHAR(20)
) AS mongo_data

-- Mongo
-- Pontos por linha
SELECT
    linha,
    sentido,
    COUNT(*) as total_pontos,
    MIN(numero_sequencia) as sequencia_inicio,
    MAX(numero_sequencia) as sequencia_fim
FROM
    OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
WITH (
    data_extracao VARCHAR(50),
    linha VARCHAR(20),
    sentido VARCHAR(56),
    numero_sequencia INT,
    tipo VARCHAR(50),
    nome VARCHAR(100),
    endereco_logradouro VARCHAR(200),
    codigo VARCHAR(20)
) AS mongo_data
GROUP BY linha, sentido
ORDER BY linha, sentido

-- mongo e postgres juntos
-- JOIN entre PostgreSQL (dadospostgres) e MongoDB (dadosmongo)
SELECT
    p.codigo_linha,
    p.sentido as sentido_horario,
    p.hora_saida,
    p.tipo_dia,
    m.linha as linha_mongo,
    m.sentido as sentido_mongo,
    m.nome as ponto,
    m.endereco_logradouro,
    m.numero_sequencia
FROM (
    -- Dados do PostgreSQL (pasta dadospostgres)
    SELECT
        l.codigo_linha,
        l.sentido,
        h.hora_saida,
        td.descricao as tipo_dia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        id_horario INT,
        hora_saida VARCHAR(10),
        adaptado_deficiente VARCHAR(5),
        fk_linha VARCHAR(20),
        fk_tipo_dia INT
    ) AS h
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        codigo_linha VARCHAR(20),
        sentido VARCHAR(56)
    ) AS l ON h.fk_linha = l.codigo_linha
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        id_tipo_dia INT,
        descricao VARCHAR(50)
    ) AS td ON h.fk_tipo_dia = td.id_tipo_dia
) AS p
INNER JOIN (
    -- Dados do MongoDB (pasta dadosmongo)
    SELECT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido,
        nome,
        endereco_logradouro,
        numero_sequencia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS m ON p.codigo_linha = m.linha AND p.sentido = m.sentido

-- Horários com sequências de Pontos-- Horários específicos com todos os pontos na ordem
SELECT
    p.codigo_linha,
    p.sentido,
    p.hora_saida,
    p.tipo_dia,
    m.numero_sequencia,
    m.nome as ponto,
    m.endereco_logradouro,
    m.tipo
FROM (
    SELECT
        l.codigo_linha,
        l.sentido,
        h.hora_saida,
        td.descricao as tipo_dia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        id_horario INT,
        hora_saida VARCHAR(10),
        adaptado_deficiente VARCHAR(5),
        fk_linha VARCHAR(20),
        fk_tipo_dia INT
    ) AS h
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        codigo_linha VARCHAR(20),
        sentido VARCHAR(56)
    ) AS l ON h.fk_linha = l.codigo_linha
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        id_tipo_dia INT,
        descricao VARCHAR(50)
    ) AS td ON h.fk_tipo_dia = td.id_tipo_dia
    WHERE l.codigo_linha = 'T3' AND td.descricao = 'DIAUTIL'
) AS p
INNER JOIN (
    SELECT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido,
        nome,
        endereco_logradouro,
        numero_sequencia,
        tipo
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS m ON p.codigo_linha = m.linha AND p.sentido = m.sentido
ORDER BY p.hora_saida, m.numero_sequencia

-- Primeiro e Ultimo Horários-- Primeiro e último horário com pontos de origem e destino
SELECT
    p.codigo_linha,
    p.sentido,
    p.tipo_dia,
    MIN(p.hora_saida) as primeiro_horario,
    MAX(p.hora_saida) as ultimo_horario,
    origem.nome as ponto_origem,
    origem.endereco_logradouro as endereco_origem,
    destino.nome as ponto_destino,
    destino.endereco_logradouro as endereco_destino
FROM (
    SELECT
        l.codigo_linha,
        l.sentido,
        h.hora_saida,
        td.descricao as tipo_dia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        id_horario INT,
        hora_saida VARCHAR(10),
        adaptado_deficiente VARCHAR(5),
        fk_linha VARCHAR(20),
        fk_tipo_dia INT
    ) AS h
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        codigo_linha VARCHAR(20),
        sentido VARCHAR(56)
    ) AS l ON h.fk_linha = l.codigo_linha
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        id_tipo_dia INT,
        descricao VARCHAR(50)
    ) AS td ON h.fk_tipo_dia = td.id_tipo_dia
) AS p
INNER JOIN (
    SELECT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido,
        nome,
        endereco_logradouro,
        numero_sequencia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS origem ON p.codigo_linha = origem.linha AND p.sentido = origem.sentido AND origem.numero_sequencia = 1
INNER JOIN (
    SELECT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido,
        nome,
        endereco_logradouro,
        numero_sequencia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS destino ON p.codigo_linha = destino.linha AND p.sentido = destino.sentido 
    AND destino.numero_sequencia = (
        SELECT MAX(numero_sequencia) 
        FROM OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
        WITH (
            data_extracao VARCHAR(50),
            linha VARCHAR(20),
            sentido VARCHAR(56),
            numero_sequencia INT,
            tipo VARCHAR(50),
            nome VARCHAR(100),
            endereco_logradouro VARCHAR(200),
            codigo VARCHAR(20)
        ) AS max_seq
        WHERE max_seq.linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 = p.codigo_linha 
          AND max_seq.sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 = p.sentido
    )
GROUP BY p.codigo_linha, p.sentido, p.tipo_dia, origem.nome, origem.endereco_logradouro, destino.nome, destino.endereco_logradouro
ORDER BY p.codigo_linha, p.sentido

-- Filtro por período do DIAUTIL-- Horários por período do dia (CORRIGIDO)
SELECT
    p.codigo_linha,
    p.sentido,
    CASE 
        WHEN TRY_CAST(REPLACE(LEFT(p.hora_saida, 2), ':', '') AS INT) < 12 THEN 'MANHÃ'
        WHEN TRY_CAST(REPLACE(LEFT(p.hora_saida, 2), ':', '') AS INT) < 18 THEN 'TARDE' 
        ELSE 'NOITE'
    END as periodo,
    p.tipo_dia,
    COUNT(DISTINCT p.hora_saida) as total_horarios
FROM (
    SELECT
        l.codigo_linha,
        l.sentido,
        h.hora_saida,
        td.descricao as tipo_dia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        id_horario INT,
        hora_saida VARCHAR(10),
        adaptado_deficiente VARCHAR(5),
        fk_linha VARCHAR(20),
        fk_tipo_dia INT
    ) AS h
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        codigo_linha VARCHAR(20),
        sentido VARCHAR(56)
    ) AS l ON h.fk_linha = l.codigo_linha
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        id_tipo_dia INT,
        descricao VARCHAR(50)
    ) AS td ON h.fk_tipo_dia = td.id_tipo_dia
) AS p
INNER JOIN (
    SELECT DISTINCT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS m ON p.codigo_linha = m.linha AND p.sentido = m.sentido
GROUP BY p.codigo_linha, p.sentido, p.tipo_dia,
    CASE 
        WHEN TRY_CAST(REPLACE(LEFT(p.hora_saida, 2), ':', '') AS INT) < 12 THEN 'MANHÃ'
        WHEN TRY_CAST(REPLACE(LEFT(p.hora_saida, 2), ':', '') AS INT) < 18 THEN 'TARDE' 
        ELSE 'NOITE'
    END
ORDER BY p.codigo_linha, periodo

-- Análise por linha-- Análise completa: horários + pontos + estatísticas (CORRIGIDA)
SELECT
    p.codigo_linha,
    p.sentido,
    p.tipo_dia,
    COUNT(DISTINCT p.hora_saida) as total_horarios,
    COUNT(DISTINCT m.nome) as total_pontos,
    MIN(m.numero_sequencia) as ponto_inicio,
    MAX(m.numero_sequencia) as ponto_fim
FROM (
    SELECT
        l.codigo_linha,
        l.sentido,
        h.hora_saida,
        td.descricao as tipo_dia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.horarios_oficial',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        id_horario INT,
        hora_saida VARCHAR(10),
        adaptado_deficiente VARCHAR(5),
        fk_linha VARCHAR(20),
        fk_tipo_dia INT
    ) AS h
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.linhas',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        codigo_linha VARCHAR(20),
        sentido VARCHAR(56)
    ) AS l ON h.fk_linha = l.codigo_linha
    INNER JOIN OPENROWSET(
        BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadospostgres/public.tipos_dia',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ';',
        FIELDQUOTE = '"'
    )
    WITH (
        id_tipo_dia INT,
        descricao VARCHAR(50)
    ) AS td ON h.fk_tipo_dia = td.id_tipo_dia
) AS p
INNER JOIN (
    SELECT
        linha COLLATE Latin1_General_100_CI_AI_SC_UTF8 as linha,
        sentido COLLATE Latin1_General_100_CI_AI_SC_UTF8 as sentido,
        nome,
        numero_sequencia
    FROM
        OPENROWSET(
            BULK 'https://contaarmazena0t31.dfs.core.windows.net/sistemaarquivos0t31/dadosmongo/**',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE,
            FIELDTERMINATOR = ';',
            FIELDQUOTE = '"'
        )
    WITH (
        data_extracao VARCHAR(50),
        linha VARCHAR(20),
        sentido VARCHAR(56),
        numero_sequencia INT,
        tipo VARCHAR(50),
        nome VARCHAR(100),
        endereco_logradouro VARCHAR(200),
        codigo VARCHAR(20)
    ) AS mongo_data
) AS m ON p.codigo_linha = m.linha AND p.sentido = m.sentido
GROUP BY p.codigo_linha, p.sentido, p.tipo_dia
ORDER BY p.codigo_linha, p.sentido, p.tipo_dia

