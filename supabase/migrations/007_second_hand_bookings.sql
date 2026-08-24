-- ─────────────────────────────────────────────
-- 007_second_hand_bookings.sql
-- Booskings/Carbunta alaabta casriga ah ee la isticmaalay
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS second_hand_bookings (
  id                  TEXT PRIMARY KEY,
  item_id             TEXT NOT NULL,
  item_title          TEXT NOT NULL,
  user_id             TEXT NOT NULL,
  user_name           TEXT NOT NULL,
  user_phone          TEXT NOT NULL,
  total_price         NUMERIC NOT NULL,
  deposit_amount      NUMERIC NOT NULL,
  currency            TEXT DEFAULT 'USD',
  payment_method      TEXT NOT NULL,
  transaction_phone   TEXT NOT NULL,
  status              TEXT DEFAULT 'pending', -- pending | approved | cancelled
  created_at          TIMESTAMPTZ DEFAULT now()
);

-- Index for fast filtering
CREATE INDEX IF NOT EXISTS idx_sh_bookings_user ON second_hand_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_sh_bookings_item ON second_hand_bookings(item_id);
CREATE INDEX IF NOT EXISTS idx_sh_bookings_status ON second_hand_bookings(status);

-- Row Level Security
ALTER TABLE second_hand_bookings ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "sh_bookings_public_read" ON second_hand_bookings
  FOR SELECT USING (true);

CREATE POLICY "sh_bookings_insert" ON second_hand_bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "sh_bookings_update" ON second_hand_bookings
  FOR UPDATE USING (true);

CREATE POLICY "sh_bookings_delete" ON second_hand_bookings
  FOR DELETE USING (true);
