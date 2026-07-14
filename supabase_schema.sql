-- ============================================================
-- SISTEMA DE COMISSÕES - Schema Supabase Completo (Prefixado com com_)
-- Execute no SQL Editor do Supabase Dashboard
-- ============================================================

-- 1. Tabela de atendentes / configuração
CREATE TABLE IF NOT EXISTS com_atendentes (
  id BIGINT PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE,
  tipo TEXT NOT NULL DEFAULT 'pct',  -- 'pct' (percentual) ou 'valor' (fixo)
  valor NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabela de vendas
CREATE TABLE IF NOT EXISTS com_vendas (
  id BIGINT PRIMARY KEY,
  data DATE NOT NULL,
  os TEXT DEFAULT '',
  cliente TEXT NOT NULL,
  produto TEXT NOT NULL,
  atendente BIGINT REFERENCES com_atendentes(id) ON DELETE SET NULL,
  valor NUMERIC(10,2) NOT NULL,
  pagamento TEXT DEFAULT 'À vista',
  status TEXT DEFAULT 'pendente',
  obs TEXT DEFAULT '',
  com_tipo TEXT DEFAULT NULL,
  com_valor NUMERIC(10,2) DEFAULT NULL,
  valor_recebido NUMERIC(10,2) DEFAULT 0,
  valor_comissao_baixada NUMERIC(10,2) DEFAULT 0,
  data_baixa_comissao DATE DEFAULT NULL,
  obs_baixa TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE com_vendas ADD COLUMN IF NOT EXISTS valor_recebido NUMERIC(10,2) DEFAULT 0;
ALTER TABLE com_vendas ADD COLUMN IF NOT EXISTS valor_comissao_baixada NUMERIC(10,2) DEFAULT 0;

-- 3. Tabela de recebimentos
CREATE TABLE IF NOT EXISTS com_recebimentos (
  id BIGINT PRIMARY KEY,
  cliente TEXT NOT NULL,
  tipo TEXT NOT NULL,
  recorrencia TEXT NOT NULL,
  valor NUMERIC(10,2) NOT NULL,
  data_prevista DATE DEFAULT NULL,
  dia INT DEFAULT NULL,
  inicio TEXT DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tabela de produtos
CREATE TABLE IF NOT EXISTS com_produtos (
  nome TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Tabela de config
CREATE TABLE IF NOT EXISTS com_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security) - acesso público simples via Anon Key
ALTER TABLE com_vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE com_atendentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE com_recebimentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE com_produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE com_config ENABLE ROW LEVEL SECURITY;

-- Políticas permissivas (ajuste conforme necessidade de autenticação futura)
CREATE POLICY "Acesso total vendas" ON com_vendas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total atendentes" ON com_atendentes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total recebimentos" ON com_recebimentos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total produtos" ON com_produtos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total config" ON com_config FOR ALL USING (true) WITH CHECK (true);
