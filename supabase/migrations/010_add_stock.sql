-- ── Add Stock Column to Second Hand Items ──
ALTER TABLE second_hand_items ADD COLUMN IF NOT EXISTS stock INTEGER NOT NULL DEFAULT 1;
