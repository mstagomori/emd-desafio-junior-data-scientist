-- 1. Quantos chamados foram abertos no dia 01/04/2023?

-- Retorna uma tabela com o número de chamados abertos no dia em questão
SELECT count(*) as chamados 
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE DATE(data_inicio) = "2023-04-01"
-- Resposta 1: 73 chamados

-- 2. Qual o tipo de chamado que teve mais reclamações no dia 01/04/2023?

-- Retorna uma tabela com as colunas: tipo (nome do tipo) e chamados (quantidade de chamados), agrupadas por tipo
SELECT tipo, count(tipo) as chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY tipo
--Resposta 2: Poluição Sonora (24 chamados)


-- 3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

-- Retorna uma tabela com as colunas: nome (nome do bairro) e qt_chamados (quantidade de chamados), agrupadas por bairro
SELECT Bairro.nome, count(Bairro.nome) as qt_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.nome
-- Resposta 3: Engenho de Dentro (8), Leblon (6) e Campo Grande (6)


-- 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?

-- Retorna uma tabela com as colunas: subprefeitura (nome da subprefeitura) e qt_chamados (quantidade de chamados), agrupadas por subprefeitura
SELECT Bairro.subprefeitura, count(Bairro.subprefeitura) as qt_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.subprefeitura
-- Resposta: Zona Norte (25)


-- 5. Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

-- Sim, existe um chamado da tabela Chamados aberto nesse dia que não possui id_bairro (valor null na coluna id_bairro) e, por isso, não pode ser 
-- associado a nenhum registro da tabela Bairro, o que inclui tanto bairro quanto subprefeitura, o que pode ser conferido através dos JOINs abaixo.

-- Retorna o número de chamados não associados a um bairro OU subprefeitura (valores null no LEFT JOIN)
SELECT count(*)
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
LEFT JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
AND (Bairro.nome IS NULL OR Bairro.subprefeitura IS NULL)
GROUP BY Bairro.id_bairro
-- Retorno: 1

-- Retorna todos os chamados realizados no dia, junto do bairro e subprefeitura associados a eles, onde se encontra o chamado cujo id_bairro = null. 
-- Isso foi feito para determinar se a causa dos null em bairro ou subprefeitura foi um id_bairro null na tabela chamado_1746 ou se havia algum bairro em dados_mestres.bairro com bairro.nome ou subprefeitura nulos.
SELECT Chamados.id_chamado, Chamados.id_bairro, Bairro.subprefeitura 
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
LEFT JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"