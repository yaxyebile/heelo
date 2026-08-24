-- ─────────────────────────────────────────────
-- 004_property_bookings.sql
-- Booskings/Carbunta guryaha iyo dhulalka
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS property_bookings (
  id                  TEXT PRIMARY KEY,
  property_id         TEXT NOT NULL,
  property_title      TEXT NOT NULL,
  property_type       TEXT NOT NULL,
  listing_type        TEXT NOT NULL,
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
CREATE INDEX IF NOT EXISTS idx_property_bookings_user ON property_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_property_bookings_property ON property_bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_property_bookings_status ON property_bookings(status);

-- Row Level Security
ALTER TABLE property_bookings ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "property_bookings_public_read" ON property_bookings
  FOR SELECT USING (true);

CREATE POLICY "property_bookings_insert" ON property_bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "property_bookings_update" ON property_bookings
  FOR UPDATE USING (true);

CREATE POLICY "property_bookings_delete" ON property_bookings
  FOR DELETE USING (true);
