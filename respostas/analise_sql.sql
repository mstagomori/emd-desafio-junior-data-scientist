-- 1. Quantos chamados foram abertos no dia 01/04/2023?

SELECT count(*) as chamados 
FROM `datario.adm_central_atendimento_1746.chamado` 
WHERE DATE(data_inicio) = "2023-04-01"
-- Resposta 1: 1756 chamados

-------------------------------------------------------------------------
-- 2. Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?

SELECT tipo, count(tipo) as chamados
FROM `datario.adm_central_atendimento_1746.chamado` 
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY tipo
ORDER BY chamados DESC
--Resposta 2: Estacionamento Irregular (366 chamados)

-------------------------------------------------------------------------
-- 3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

SELECT Bairro.nome, count(Bairro.nome) as chamados
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.nome
ORDER BY chamados DESC
LIMIT 3
-- Resposta 3: Campo Grande (113), Tijuca (89) e Barra da Tijuca (59)

-------------------------------------------------------------------------
-- 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?

SELECT Bairro.subprefeitura, count(Bairro.subprefeitura) as chamados
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
INNER JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
GROUP BY Bairro.subprefeitura
ORDER BY chamados DESC
LIMIT 1
-- Resposta: Zona Norte (510)

-------------------------------------------------------------------------
-- 5. Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

-- Resposta: Sim, 73 chamados. Como pode ser observado no resultado da query abaixo. Em seguida, são analisados as possíveis causas.

-- Retorna o número de chamados não associados a bairro ou subprefeitura na tabela Bairro
SELECT count(*) as chamados_sem_bairro_subprefeitura
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
LEFT JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
  AND (Bairro.nome IS NULL OR Bairro.subprefeitura IS NULL)

-- A query abaixo retorna uma tabela com o número de chamados agrupados por tipo de chamado
-- Pode-se perceber que a maioria dos chamados são do tipo Ônibus
SELECT Chamados.tipo, count(Chamados.tipo) as n_chamados
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
LEFT JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
  AND (Bairro.nome IS NULL OR Bairro.subprefeitura IS NULL)
GROUP BY Chamados.tipo
ORDER BY n_chamados DESC

-- A query abaixo retorna uma tabela com os chamados agrupados por subtipo para analisar melhor as causas, por Tipo: Subtipo
-- Alvará (1), Atendimento ao cidadão (18): Em casos de solicitação de: Orientações sobre alvará (1), correção de falhas e de cadastro no portal e app (17) e de gravação do atendimento (1), todos os casos podem ter sido feitos via app móvel, não possuindo bairro para ser associado. Além disso, a informação de bairro não é necessária para estes subtipos de chamado.
-- Defesa do consumidor (1): Verificação de problemas com produtos ou serviços - Este subtipo de chamado também não está necessáriamente associado a um bairro, pois está associado a produtos ou serviços.
-- Estacionamento irregular (1): Neste caso deveria ter sido informado o bairro, juntamente do local (latitude e longitude) onde foi Estacionado o veículo. É possível que o usuário (Guarda Municipal, segundo consulta do nome_unidade_organizacional do chamado) tenha esquecido de adicionar o bairro e o local no chamado, bem como é possível que tenha ocorrido algum erro no sistema que registre o local automaticamente, se for o caso.
-- Ônibus (50): 1) Verificação de ar condicionado inoperante no ônibus (49 chamados) - Como ônibus são unidades móveis e algumas linhas de ônibus transitam entre diferentes bairros, chamados para Vistoria de Ar condicionado, que não possuem um local para ser informado, não são associados a nenhum bairro.
--              2) Fiscalização de irregularidades em linha de ônibus (1 chamado) - Neste caso, as irregularidades poderiam estar presentes em diferentes partes de uma via que transita entre bairros, impossibilitando a associação a apenas um bairro.
-- Transporte Especial Complementar - TEC (1) e BRT (1): Mesmos motivos do tipo Ônibus.

SELECT Chamados.tipo, Chamados.subtipo, count(Chamados.subtipo) as n_chamados
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
LEFT JOIN `datario.dados_mestres.bairro` Bairro
ON Chamados.id_bairro = Bairro.id_bairro
WHERE DATE(data_inicio) = "2023-04-01"
  AND (Bairro.nome IS NULL OR Bairro.subprefeitura IS NULL)
GROUP BY Chamados.tipo, Chamados.subtipo
ORDER BY n_chamados DESC

-------------------------------------------------------------------------
-- 6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

SELECT count(*) as chamados
FROM `datario.adm_central_atendimento_1746.chamado` 
WHERE subtipo = "Perturbação do sossego" 
  AND (DATE(data_inicio) >= "2022-01-01" AND DATE(data_inicio) <= "2023-12-31")
-- Resposta: 42830 chamados

-------------------------------------------------------------------------
-- 7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).

SELECT Chamados.*
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
WHERE subtipo = "Perturbação do sossego"

-------------------------------------------------------------------------
-- 8. Quantos chamados desse subtipo foram abertos em cada evento?

-- Resposta:
-- Rock in Rio = 834
-- Carnaval = 241
-- Reveillon = 139
SELECT Eventos.evento, count(Chamados.id_chamado) as chamados
FROM `datario.adm_central_atendimento_1746.chamado` Chamados
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
WHERE subtipo = "Perturbação do sossego"
GROUP BY Eventos.evento
ORDER BY chamados DESC

-------------------------------------------------------------------------
-- 9. Qual evento teve a maior média diária de chamados abertos desse subtipo?

-- Resposta 9: Rock in Rio (119 chamados por dia em média)
SELECT chamados_eventos.evento, avg(chamados_eventos.qt_chamados) as media_diaria
FROM (
  SELECT DATE(Chamados.data_inicio), Eventos.evento, count(*) as qt_chamados
  FROM `datario.adm_central_atendimento_1746.chamado` Chamados
  INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` Eventos
  ON (DATE(Chamados.data_inicio) BETWEEN Eventos.data_inicial AND Eventos.data_final)
  WHERE subtipo = "Perturbação do sossego"
  GROUP BY DATE(Chamados.data_inicio), Eventos.evento
) chamados_eventos
GROUP BY chamados_eventos.evento
ORDER BY media_diaria DESC

-------------------------------------------------------------------------
-- 10. Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

-- Resposta 10: Em média, foram iniciados 62 chamados por dia no período de 01/01/2022 até 31/12/2023
-- Rock in rio: Muito acima da média geral (59 chamados a mais por dia)
-- Carnaval: Semelhante à média diária (60 chamados por dia, apenas 2 chamados abaixo da média)
-- Reveillon: Abaixo da média (46 chamados por dia em média, 14 chamados abaixo da média geral)
SELECT avg(chamados_diarios.qt_chamados) as media_diaria_geral
FROM (
  SELECT DATE(Chamados.data_inicio) as data_inicio, count(*) as qt_chamados
  FROM `datario.adm_central_atendimento_1746.chamado` Chamados
  WHERE subtipo = "Perturbação do sossego" AND (DATE(Chamados.data_inicio) BETWEEN "2022-01-01" AND "2023-12-31")
  GROUP BY DATE(Chamados.data_inicio)
) chamados_diarios