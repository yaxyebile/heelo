-- ─────────────────────────────────────────────
-- 005_second_hand_marketplace.sql
-- Suuqa Alaabta Casriga ah
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS second_hand_items (
  id            TEXT PRIMARY KEY,
  title         TEXT NOT NULL,
  description   TEXT DEFAULT '',
  seller_id     TEXT DEFAULT '',
  seller_name   TEXT DEFAULT '',
  seller_phone  TEXT DEFAULT '',
  category      TEXT DEFAULT 'other',
  condition     TEXT DEFAULT 'good',
  price         NUMERIC DEFAULT 0,
  currency      TEXT DEFAULT 'USD',
  location      TEXT DEFAULT '',
  images        TEXT[] DEFAULT '{}',
  status        TEXT DEFAULT 'pending',  -- pending | approved | sold | rejected
  created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sh_status   ON second_hand_items(status);
CREATE INDEX IF NOT EXISTS idx_sh_category ON second_hand_items(category);
CREATE INDEX IF NOT EXISTS idx_sh_created  ON second_hand_items(created_at DESC);

ALTER TABLE second_hand_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sh_public_read"   ON second_hand_items FOR SELECT USING (true);
CREATE POLICY "sh_insert"        ON second_hand_items FOR INSERT WITH CHECK (true);
CREATE POLICY "sh_update"        ON second_hand_items FOR UPDATE USING (true);
CREATE POLICY "sh_delete"        ON second_hand_items FOR DELETE USING (true);
