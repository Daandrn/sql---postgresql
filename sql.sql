CREATE TABLE IF NOT EXISTS data_types (
    -- Com exceção de serial, os tipos de dados aceitam NULL
    int2                  smallint, -- 2 bytes | -32768 até +32767 | inteiro de 2 bytes
    int4                       int, -- 4 bytes | -2147483648 até +2147483647 | inteiro de 4 bytes
    int8                    bigint, -- 8 bytes | -9223372036854775808 até +9223372036854775807 | inteiro de 8 bytes
    
    serial2            smallserial, -- 2 bytes | 1 até 32767 | inteiro de 2 bytes autoincrementável (não permite NULL)
    serial4                 serial, -- 4 bytes | 1 até 2147483647 | inteiro de 4 bytes autoincrementável (não permite NULL)
    serial8              bigserial, -- 8 bytes | 1 até 9223372036854775807 | inteiro de 8 bytes autoincrementável (não permite NULL)
    
    numeric_         numeric(6, 2), -- numeric(tamanhoTotal, decimais) | precisão exata (máximo 131072 dígitos antes da vírgula e 16383 depois) | valor com casas decimais definidas pelo usuário
    float4                    real, -- 4 bytes | precisão aproximada (máximo 6 dígitos significativos) | valor com precisão de ponto flutuante de 4 bytes
    float8        double precision, -- 8 bytes | precisão aproximada (máximo 15 dígitos significativos) | valor com precisão de ponto flutuante de 8 bytes
    
    caracter              char(10), -- string com tamanho fixo definido de 1 a 10485760 (caso a string passada seja menor que o tamanho definido, será preenchida com espaços ao final)
    caracter_variavel varchar(255), -- string com tamanho variável de 1 a 10485760
    texto                     text, -- string sem limite de tamanho (equivalente à varchar sem limite definido)
    
    data_                     date, -- armazena data. formato recomendado: '1999-01-08'
    hora                      time, -- armazena apenas hora. formatos: 04:05:06 e 04:05
    data_e_hora          timestamp, -- armazena data e hora. formato recomendado: '1999-01-08 04:05:06'
    
    booleano               boolean, -- armazena os estados true, false e null. | true == 't', yes/'y', on, 1 | false == 'f', no/'n', off, 0
    
    uuid_                     uuid  -- armazena UUID válidos
);

CREATE TABLE not_null (
    id          serial primary key,
    descricao varchar(255) not null -- not null define que o campo não pode receber null
);

CREATE TABLE valor_unico_na_tabela (
    id         serial primary key,
    descricao varchar(255) unique, -- unique define que o campo não pode se repetir em outros registros
    complemento              text, 
    nome                     text, 
    sobrenome                text, 

    unique(complemento),    -- sintaxe alternativa
    unique(nome, sobrenome) -- define único valor com combinação de colunas
);

CREATE TABLE chaves_primaria_secundaria (
    id                int primary key, -- para criar uma chave primaria basta usar PRIMARY KEY
    id2           int unique not null,
    id3           int unique not null,
    tipo  int references not_null(id), -- para criar uma chave estrangeira basta usar references nome_tabela(campo)
    tipo2                         int,

    -- 'CONSTRAINT nome_da_constraint' serve para nomear a constraint que será criada logo em seguida
    CONSTRAINT nome_da_chave FOREIGN KEY (tipo2) REFERENCES not_null(id) -- OU para criar uma chave estrangeira com nome específico
);

CREATE TABLE acoes_de_chave_estrangeira (
    id         int,
    referencia int,

    FOREIGN KEY (referencia) 
        REFERENCES not_null(id) 
            ON DELETE CASCADE -- define que se o registro da chave primaria for excluído, o registro correspondente também será excluído
            ON UPDATE CASCADE -- define que se o valor da chave primaria for atualizado, o valor correspondente na chave estrangeira será atualizado também
);

CREATE TABLE chave_primaria_composta (
    id1       int not null,
    id2       int not null,
    nome              text, 
    sobrenome         text, 

    primary key (id1, id2) -- para criar uma chave primária composta
);

CREATE TABLE chave_secundaria_composta (
    id1       int not null,
    id2       int not null,
    nome              text, 
    sobrenome         text, 

    FOREIGN KEY (id1, id2) REFERENCES table_name(id1, id2) -- referenciando a chave primária composta de outra tabela
);

CREATE TABLE valor_padrao (
    id                  serial primary key,
    descricao varchar(255) default 'teste', -- default define valor padrão para o campo caso nada seja indicado
    status             boolean default true
);

--------------------------TRANSAÇÕES------------------------------

BEGIN;    -- inicia uma transação
COMMIT;   -- confirma as alterações feitas numa transação
ROLLBACK; -- reverte as alterações feitas numa transação

--------------------------INSERT------------------------------

INSERT INTO acoes_de_chave_estrangeira VALUES (46, 'teste');                             -- Necessário iformar VALUES para todas as colunas da tabela
INSERT INTO valor_padrao (descricao, status) VALUES ('teste outro', false);              -- Necessário iformar VALUES apenas para as colunas da tabela citadas
INSERT INTO valor_padrao (descricao, status) SELECT descricao, status FROM valor_padrao; -- realiza inserts a partir do retorno de um select
INSERT INTO valor_padrao (descricao, status) VALUES                                      -- faz o insert de mais de um valor ao mesmo tempo
    ('teste 1', true),
    ('teste 2', false),
    ('teste 3', true);

------------------------SELECT--------------------------------

SELECT * FROM valor_padrao;                    -- * seleciona todas as colunas da tabela 
SELECT descricao, status FROM valor_padrao;    -- seleciona apenas as colunas especificadas 
SELECT descricao, status, * FROM valor_padrao; -- seleciona as colunas especificadas mais todas as colunas da tabela 

SELECT DISTINCT descricao FROM valor_padrao;   -- elimina registros duplicados

select distinct on (first_name ,last_name) * from valor_padrao; -- elimina registros duplicados com base nas colunas especificadas

SELECT 
    CASE                                       -- possibilita adicionar verificações condicionais
        WHEN condição1 THEN resultado1
        WHEN condição2 THEN resultado2
        ELSE resultado_default                 -- retorna valor padrão caso nenhuma condição seja atendida
    END
FROM nome_tabela;

SELECT * FROM valor_unico_na_tabela
FROM tabela
WHERE id <> 1                           -- WHERE filtra quais registros serão retornados com  base no campo informado
    AND nome != 'teste'                 -- AND combina filtros
    OR  sobrenome = 'teste 2'           -- OR adiciona opções ao filtro
ORDER BY descricao desc                 -- ordena o resultado pela coluna indicada (ASC e DESC definem a ordenação)
ORDER BY descricao desc, sobrenome asc; -- combina campos na ordenação

SELECT sobrenome, count(sobrenome) 
FROM valor_unico_na_tabela
GROUP BY sobrenome           -- agrupa as colunas fora da agregação
HAVING count(sobrenome) > 5; -- filtra resultado após o GROUP BY

------------------------JOINS--------------------------------

SELECT * 
FROM tabela1
INNER JOIN tabela2 ON tabela1.id = tabela2.id -- junta as colunas da tabela somente caso haja registros correspondentes em ambas tabelas
INNER JOIN tabela2 ON tabela1.id = tabela2.id AND tabela1.id2 = tabela2.id2
LEFT JOIN tabela2 ON tabela1.id = tabela2.id  -- junta as colunas da tabela da esquerda mostrando null caso não exista registro correspondente na tabela da direita
RIGHT JOIN tabela2 ON tabela1.id = tabela2.id -- junta as colunas da tabela da direita mostrando null caso não exista registro correspondente na tabela da esquerda
FULL JOIN tabela2 ON tabela1.id = tabela2.id  -- junta as colunas da tabela da esquerda mostrando null caso não exista registro correspondente 

------------------------TABELAS CTE--------------------------------

WITH cte_exemplo AS (
    SELECT descricao
    FROM valor_padrao
)
SELECT * FROM cte_exemplo;

------------------------UPDATE--------------------------------

UPDATE table_name SET coluna1 = 'teste', coluna2 = valor1 WHERE id = 1; -- atualiza a coluna dos registros conforme filtros

BEGIN;
    SELECT * FROM table_name WHERE condicao FOR UPDATE;                 -- seleciona um registro para ser atualizado (nenhuma outra transacao pode atualizar este registro ate que a transacao atual seja concluida)
    UPDATE table_name SET column_name = 'valor_novo' WHERE condicao;    -- realiza a atualização do registro
COMMIT;

UPDATE table_name SET coluna1 = (SELECT coluna FROM outra_tabela WHERE condicao) WHERE id = 1; -- atualiza a coluna dos registros usando subconsultas

UPDATE table_name
SET coluna = CASE -- escolhe o valor a ser atribuido à coluna conforme condições
                WHEN condicao1 THEN 'valor1'
                WHEN condicao2 THEN 'valor2'
                ELSE 'valor_padrao'
             END
WHERE condicao;

------------------------OPERADORES--------------------------------
valor1 +  valor2             -- soma
valor1 -  valor2             -- subtração
valor1 /  valor2             -- divisão
valor1 *  valor2             -- multiplicação

valor1 >  valor2             -- maior 
valor1 <  valor2             -- menor
valor1 >= valor2             -- maior ou igual
valor1 <= valor2             -- menor ou igual
valor1 =  valor2             -- igual
valor1 <> 1                  -- diferente
valor1 != valor2             -- diferente
valor1 is not null           -- não nullo
valor1 is null               -- nullo
valor1 is true               -- igual a true
valor1 is false              -- igual a false
valor1 in (1, 2, 3)          -- presente na lista
valor1 not in (1, 2, 3)      -- não presente na lista
valor1 between 0 and 100     -- presente no intervalo
valor1 not between 0 and 100 -- não presente no intervalo
valor1 LIKE 'conteudo%'      -- iniciado em
valor1 LIKE '%conteudo'      -- termina em
valor1 LIKE '%conteudo%'     -- contem
valor1 NOT LIKE 'conteudo'   -- NOT nega as afirmações acima
valor1 ILIKE 'conteudo'      -- adiciona verificação de maiusculas e minusculas nas afirmações acima
NOT valor1 =  valor2         -- Nega o resultado da comparação

------------------------UNIONS--------------------------------

SELECT coluna FROM tabela1
UNION     -- Une os resultados das consultas eliminando os duplicados
UNION ALL -- Une todos os resultados das consultas
INTERSECT -- Une os resultados presentes nas duas consultas
EXCEPT    -- Une os resultados da primeira consulta que não estão presentes na segunda
SELECT coluna FROM tabela2

------------------------CONCANTENAÇÃO--------------------------------

CONCAT(val1, val2) -- Concatena duas ou mais strings
valor1 || valor2   -- Concatena duas ou mais strings
CONCAT_WS('-', coluna1, coluna2, coluna3) -- concatena as strings separando-as pela string indicada

------------------------CONVERSÃO DE TIPO--------------------------------

CAST(valor_int AS string) -- converte tipo do dado
valor_int::string         -- converte de inteiro para string
valor_text::varchar(30)   -- converte de text para string com tamanho definido
valor_string::int         -- converte de string para inteiro
1::boolean                -- converte de para true
0::boolean                -- converte de para false

------------------------OPERAÇÕES COM DATA--------------------------------

EXTRACT(year FROM data_incio)  -- extrai o ano de uma data
EXTRACT(month FROM data_incio) -- extrai o mês de uma data
day, hour, minute, second

DATE_PART('year', data_incio)     -- extrai o ano de uma data
DATE_PART('month', data_incio)    -- extrai o mês de uma data
'day', 'hour', 'minute', 'second' -- mais opções para extração

to_char(data,'YYYY') --converte a parte da data especificada para string
'DD', 'MM'

AGE(data_fim, data_inicio)      -- calcula a diferença entre duas datas
data_incio + INTERVAL '1 year'  -- adiciona um intervalo de tempo a uma data/hora.
data_incio - INTERVAL '1 month' -- subtrai um intervalo de tempo de uma data/hora.
'2 years 3 months', '5 days 4 hours'

now()        -- retorna data e hora atual
CURRENT_DATE -- retorna data atual
CURRENT_TIME -- retorna hora atual

TO_TIMESTAMP(concat_ws(' ', data_coluna, hora_coluna), 'YYYY-MM-DD H:m:s') -- converte data ou hora para timestamp

------------------------FUNÇÕES DE AGREGAÇÃO--------------------------------

COUNT(column_name) -- conta a quantidade na coluna
COUNT(*)           -- conta a quantidade de registros na tabela
SUM(column_name)   -- soma os valores da coluna
AVG(column_name)   -- média dos valores da coluna
MIN(column_name)   -- valor mininmo da coluna
MAX(column_name)   -- valor máximo da coluna

------------------------LIDANDO COM STRINGS--------------------------------

LENGTH(column_name)   -- conta o tamanho da string
UPPER(column_name)    -- converte toda string para MAIUSCULO
LOWER(column_name)    -- converte toda string para minusculo
TRIM(column_name)     -- remove espaços vazios do inicio e fim da string
LTRIM(column_name)    -- remove espaços vazios do inicio da string
RTRIM(column_name)    -- remove espaços vazios do fim da string
LEFT(column_name, 5)  -- retorna as 5 primeiras posições da string
LEFT(column_name, 5)  -- retorna as 5 primeiras posições da string
LEFT(column_name, 5)  -- retorna as 5 primeiras posições da string
RIGHT(column_name, 3) -- retorna as 3 última posições da string
LPAD(column_name, 10, '0') -- completa o lado esquerdo da string até o tamanho especificado com a string indicada
RPAD(column_name, 10, '0') -- completa o lado direito da string até o tamanho especificado com a string indicada
REPLACE(column_name, 'substring1', 'substring2') -- reescreve parte da string para nov string
SUBSTRING(column_name FROM posicao_inicial FOR comprimento) -- retorna uma substring a partir da posicao inicial com o tamanho informado

------------------------OPERADORES DE SUB CONSULTAS--------------------------------

valor > ALL (SELECT column_name FROM table_name)     -- compara valor com todos os resultados da subconsulta
EXISTS (SELECT 1 FROM table_name WHERE condição)     -- verifica se a subconsulta retorna algum resultado
NOT EXISTS (SELECT 1 FROM table_name WHERE condição) -- verifica se a subconsulta retorna nenhum resultado

------------------------LIDANDO COM NULL--------------------------------

coallesce(valor1, valor2, 'padrao') -- retorna o valor padrão caso os parametros informados sejam null
IFNULL(column_name, 'valor_padrao') -- retorna o valor padrão caso os parametros informados sejam null

------------------------FUNÇÕES--------------------------------

ROUND(valor, 2)       -- faz arredondamento para o numero de casas decimais especificadas
to_ascii(column_name) -- converte caracateres especiais em caracteres ascII básicos (recomendado para remover acentuação de palavras)

------------------------MANIPULAR SEQUENCIAS--------------------------------

SELECT SETVAL('my_sequence', (SELECT MAX(my_sequence) + 1 FROM sequence_table)); -- altera sequencia com base na última sequencia
SELECT SETVAL('my_sequence', 100); -- altera sequencia com base em valor especifico

------------------------MANIPULAÇÃO DE TABELA--------------------------------

ALTER TABLE table_name 
    RENAME TO novo_table_name;              -- renomeia uma tabela

    ADD PRIMARY KEY (column_name);          -- adiciona uma chave primária à tabela
    DROP CONSTRAINT nome_da_chave_primaria; -- exclui a chave primária especificada

    ADD UNIQUE (column_name);               -- adiciona regra de valor unico à tabela
    DROP CONSTRAINT nome_unico;             -- exclui regra de valor unico à tabela

    ADD CONSTRAINT fk_nome FOREIGN KEY (coluna) REFERENCES outra_tabela(coluna_referenciada); -- adiciona chave estrangeira à tabela
    DROP CONSTRAINT fk_nome;                -- exclui chave estrangeira especificada

------------------------ALTERAÇÕES NA COLUNA--------------------------------

ALTER TABLE table_name 
    RENAME COLUMN column_name TO nova_column_name;      -- renomeia uma coluna
    ADD column_name tipo;                               -- adiciona uma nova coluna ao final da tabela
    ALTER COLUMN column_name TYPE novo_tipo;            -- altera o tipo de dado de uma coluna
    ALTER COLUMN column_name TYPE VARCHAR(255) USING column_name::VARCHAR(255); -- altera o tipo de dado de uma coluna quando é necessário conversão dos dados para o novo tipo
    DROP COLUMN column_name;                            -- exlui a coluna especificada
    ALTER COLUMN column_name SET DEFAULT valor_default; -- atribui valor default à coluna
    ALTER COLUMN column_name DROP DEFAULT;              -- exclui valor default da coluna
    ALTER COLUMN column_name SET NOT NULL;              -- atribui not null à coluna
    ALTER COLUMN column_name DROP NOT NULL;             -- exclui not null da coluna

------------------------EXCLUIR TABELA--------------------------------

DROP TABLE IF EXISTS table_name; -- exclui uma tabela

------------------------CRIAR INDICE--------------------------------

CREATE INDEX nome_indice ON table_name (column_name); -- cria novo indice e atribui à coluna/tabela
DROP INDEX nome_indice;                               -- exclui o indice especificado