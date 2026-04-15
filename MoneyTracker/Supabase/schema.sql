-- =========================================================
-- MoneyTracker — Supabase Schema
-- Run this in Supabase Dashboard → SQL Editor
-- Follow order: profiles → wallets → categories → transactions
-- =========================================================

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name  TEXT,
  avatar_url    TEXT,
  currency      TEXT        NOT NULL DEFAULT 'VND',
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own profile"
  ON profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 2. WALLETS
CREATE TABLE IF NOT EXISTS wallets (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  type        TEXT        NOT NULL CHECK (type IN ('cash','bank','credit_card','e_wallet')),
  balance     NUMERIC(15,2) NOT NULL DEFAULT 0,
  color       TEXT        NOT NULL DEFAULT '#00D68F',
  icon        TEXT        NOT NULL DEFAULT 'creditcard.fill',
  is_default  BOOLEAN     DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own wallets"
  ON wallets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 3. CATEGORIES (system + user-defined)
CREATE TABLE IF NOT EXISTS categories (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        REFERENCES profiles(id) ON DELETE CASCADE, -- NULL = system
  name        TEXT        NOT NULL,
  icon        TEXT        NOT NULL DEFAULT 'tag',
  color       TEXT        NOT NULL DEFAULT '#007AFF',
  type        TEXT        NOT NULL CHECK (type IN ('income','expense','both')),
  is_system   BOOLEAN     DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read system + own categories"
  ON categories FOR SELECT
  USING (user_id IS NULL OR auth.uid() = user_id);
CREATE POLICY "Manage own categories"
  ON categories FOR INSERT UPDATE DELETE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Seed default categories
INSERT INTO categories (name, icon, color, type, is_system) VALUES
  ('Ăn uống',    'fork.knife',                  '#FF6B6B', 'expense', TRUE),
  ('Di chuyển',  'car.fill',                    '#F5A623', 'expense', TRUE),
  ('Mua sắm',    'bag.fill',                    '#007AFF', 'expense', TRUE),
  ('Hóa đơn',    'doc.text.fill',               '#5E5CE6', 'expense', TRUE),
  ('Giải trí',   'popcorn.fill',                '#AF52DE', 'expense', TRUE),
  ('Sức khỏe',   'heart.fill',                  '#FF375F', 'expense', TRUE),
  ('Quà tặng',   'gift.fill',                   '#FF9F0A', 'expense', TRUE),
  ('Gia đình',   'house.fill',                  '#5AC8FA', 'expense', TRUE),
  ('Giáo dục',   'book.fill',                   '#30D158', 'expense', TRUE),
  ('Lương',      'banknote.fill',               '#00D68F', 'income',  TRUE),
  ('Tiền thưởng','star.fill',                   '#44F3A9', 'income',  TRUE),
  ('Đầu tư',     'chart.line.uptrend.xyaxis',   '#00D68F', 'income',  TRUE),
  ('Khác',       'ellipsis.circle.fill',        '#8E8E93', 'both',    TRUE)
ON CONFLICT DO NOTHING;

-- 4. TRANSACTIONS
CREATE TABLE IF NOT EXISTS transactions (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  wallet_id     UUID        NOT NULL REFERENCES wallets(id)  ON DELETE CASCADE,
  category_id   UUID        NOT NULL REFERENCES categories(id),
  type          TEXT        NOT NULL CHECK (type IN ('income','expense')),
  amount        NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  note          TEXT,
  date          DATE        NOT NULL DEFAULT CURRENT_DATE,
  receipt_url   TEXT,
  is_recurring  BOOLEAN     DEFAULT FALSE,
  recurring_id  UUID,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_date
  ON transactions(user_id, date DESC);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own transactions"
  ON transactions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 5. BUDGETS (Phase 2)
CREATE TABLE IF NOT EXISTS budgets (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id   UUID        NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  wallet_id     UUID        REFERENCES wallets(id),
  limit_amount  NUMERIC(15,2) NOT NULL CHECK (limit_amount > 0),
  period        TEXT        NOT NULL CHECK (period IN ('monthly','weekly','yearly')),
  alert_at      NUMERIC(3,2) DEFAULT 0.8,
  month         INTEGER     CHECK (month BETWEEN 1 AND 12),
  year          INTEGER,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own budgets"
  ON budgets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 6. RECURRING RULES (Phase 2)
CREATE TABLE IF NOT EXISTS recurring_rules (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  wallet_id      UUID        NOT NULL REFERENCES wallets(id),
  category_id    UUID        NOT NULL REFERENCES categories(id),
  type           TEXT        NOT NULL CHECK (type IN ('income','expense')),
  amount         NUMERIC(15,2) NOT NULL,
  note           TEXT,
  frequency      TEXT        NOT NULL CHECK (frequency IN ('daily','weekly','monthly','yearly')),
  start_date     DATE        NOT NULL,
  end_date       DATE,
  next_run_date  DATE        NOT NULL,
  is_active      BOOLEAN     DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE recurring_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own recurring rules"
  ON recurring_rules FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 7. HELPER FUNCTION — auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_wallets_updated_at
  BEFORE UPDATE ON wallets FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_transactions_updated_at
  BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 8. ENABLE REALTIME for transactions
-- Dashboard → Replication → tables: enable transactions
