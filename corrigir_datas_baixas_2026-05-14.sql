-- Corrige as baixas que constam no relatÃ³rio ComissÃµes Baixadas.
-- Os valores sÃ£o preservados; somente a data da baixa Ã© ajustada.
UPDATE comissao_vendas
SET data_baixa_comissao = DATE '2026-05-14',
    historico_baixas = CASE
      WHEN jsonb_typeof(historico_baixas) = 'array' AND jsonb_array_length(historico_baixas) > 0
      THEN (SELECT jsonb_agg(jsonb_set(item, '{data}', to_jsonb('2026-05-14'::text))) FROM jsonb_array_elements(historico_baixas) AS item)
      ELSE historico_baixas
    END
WHERE os IN ('631','651','665','701','703','705','720','729','736','752');

-- MantÃ©m a consulta de conferÃªncia apÃ³s a correÃ§Ã£o.
SELECT os, data_baixa_comissao, valor_comissao_baixada, historico_baixas
FROM comissao_vendas
WHERE os IN ('631','651','665','701','703','705','720','729','736','752')
ORDER BY os;

-- CorreÃ§Ã£o do relatÃ³rio de 16/06/2026, incluindo a continuaÃ§Ã£o da pÃ¡gina.
UPDATE comissao_vendas
SET data_baixa_comissao = DATE '2026-06-16',
    historico_baixas = CASE
      WHEN jsonb_typeof(historico_baixas) = 'array' AND jsonb_array_length(historico_baixas) > 0
      THEN (SELECT jsonb_agg(jsonb_set(item, '{data}', to_jsonb('2026-06-16'::text))) FROM jsonb_array_elements(historico_baixas) AS item)
      ELSE historico_baixas
    END
WHERE os IN ('639','791','815','836','876','887','888','889','895','903','920','923','932','937','944','946','951');

SELECT os, data_baixa_comissao, valor_comissao_baixada, historico_baixas
FROM comissao_vendas
WHERE os IN ('639','791','815','836','876','887','888','889','895','903','920','923','932','937','944','946','951')
ORDER BY os;
