-- 1. Quantos chamados foram abertos no dia 01/04/2023?

-- Retorna uma tabela com o número de chamados abertos no dia em questão
SELECT count(*) as chamados 
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE DATE(data_inicio) = "2023-04-01"
-- Resposta 1: 73 chamados

-------------------------------------------------------------------------
-- 2. Qual o tipo de chamado que teve mais reclamações no dia 01/04/2023?

-- Retorna uma tabela com as colunas: tipo (nome do tipo) e chamados (quantidade de chamados), agrupadas por tipo
SELECT tipo, count(tipo) as chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY tipo
--Resposta 2: Poluição Sonora (24 chamados)

-------------------------------------------------------------------------
-- 3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

-- Retorna uma tabela com as colunas: nome (nome do bairro) e qt_chamados (quantidade de chamados), agrupadas por bairro
SELECT Bairro.nome, count(Bairro.nome) as qt_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.nome
-- Resposta 3: Engenho de Dentro (8), Leblon (6) e Campo Grande (6)

-------------------------------------------------------------------------
-- 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?

-- Retorna uma tabela com as colunas: subprefeitura (nome da subprefeitura) e qt_chamados (quantidade de chamados), agrupadas por subprefeitura
SELECT Bairro.subprefeitura, count(Bairro.subprefeitura) as qt_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.subprefeitura
-- Resposta: Zona Norte (25)

-------------------------------------------------------------------------
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

-------------------------------------------------------------------------
-- 6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

-- Retorna o número de chamados
SELECT count(*) as chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE subtipo = "Perturbação do sossego" 
AND (DATE(data_inicio) >= "2022-01-01" AND DATE(data_inicio) <= "2023-12-31")
-- Resposta: 42408 chamados

-------------------------------------------------------------------------
-- 7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).

-- Retorna os chamados com subtipo "Perturbação do sossego" criados nos períodos de Reveillon, Carnaval e Rock in Rio, segundo a tabela de eventos.
SELECT Chamados.*
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
WHERE subtipo = "Perturbação do sossego"

-------------------------------------------------------------------------
-- 8. Quantos chamados desse subtipo foram abertos em cada evento?

-- Retorna uma tabela contendo o número de eventos abertos em cada evento
SELECT Eventos.evento, count(Eventos.evento) as chamados
FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
WHERE subtipo = "Perturbação do sossego"
GROUP BY Eventos.evento

-------------------------------------------------------------------------
-- 9. Qual evento teve a maior média diária de chamados abertos desse subtipo?

-- Retorna uma tabela com a média diária de chamados abertos em cada evento
SELECT chamados_eventos.evento, avg(chamados_eventos.qt_chamados) as media_diaria
FROM (
  SELECT DATE(Chamados.data_inicio), Eventos.evento, count(*) as qt_chamados
  FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
  INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
  ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
  WHERE subtipo = "Perturbação do sossego"
  GROUP BY DATE(Chamados.data_inicio), Eventos.evento
) chamados_eventos
GROUP BY chamados_eventos.evento
-- Resposta 9: Rock in Rio (119.14 chamados por dia)

-------------------------------------------------------------------------
-- 10. Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

-- Retorna a media diaria de chamados no periodo de 01/01/2022 a 31/12/2023
SELECT avg(chamados_eventos.qt_chamados) as media_diaria
FROM (
  SELECT DATE(Chamados.data_inicio) as data_inicio, count(*) as qt_chamados
  FROM `datario.administracao_servicos_publicos.chamado_1746` Chamados
  WHERE subtipo = "Perturbação do sossego" AND (DATE(Chamados.data_inicio) BETWEEN "2022-01-01" AND "2023-12-31")
  GROUP BY DATE(Chamados.data_inicio)
) chamados_eventos
-- Resposta 10: A média diária entre todo o período foi de 63.20, próxima à média diária do Carnaval segundo a tabela de eventos (60.25 chamados por dia), 
-- superior à média diária do período de Reveillon (45.67) e inferior à do Rock in Rio (119.14)