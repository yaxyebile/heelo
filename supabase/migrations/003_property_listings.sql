-- ─────────────────────────────────────────────
-- 003_property_listings.sql
-- Guryaha iyo dhulalka kiraynta iyo iibka
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS property_listings (
  id              TEXT PRIMARY KEY,
  title           TEXT NOT NULL,
  description     TEXT DEFAULT '',
  owner_id        TEXT DEFAULT '',
  owner_name      TEXT DEFAULT '',
  owner_phone     TEXT DEFAULT '',
  property_type   TEXT DEFAULT 'house',   -- house | apartment | land | villa | shop
  listing_type    TEXT DEFAULT 'rent',    -- rent | sale
  price           NUMERIC DEFAULT 0,
  currency        TEXT DEFAULT 'USD',     -- USD | SOS | ETB | AED | SAR | EUR
  location        TEXT DEFAULT '',
  area_sqm        NUMERIC DEFAULT 0,
  bedrooms        INT DEFAULT 0,
  bathrooms       INT DEFAULT 0,
  images          TEXT[] DEFAULT '{}',
  amenities       TEXT[] DEFAULT '{}',
  is_approved     BOOLEAN DEFAULT false,
  is_available    BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- Index for fast filtering
CREATE INDEX IF NOT EXISTS idx_property_listings_type ON property_listings(listing_type);
CREATE INDEX IF NOT EXISTS idx_property_listings_approved ON property_listings(is_approved);
CREATE INDEX IF NOT EXISTS idx_property_listings_created ON property_listings(created_at DESC);

-- Row Level Security
ALTER TABLE property_listings ENABLE ROW LEVEL SECURITY;

-- Dhammaan waxay akhrisan karaan guryaha la ansixiyay
CREATE POLICY "property_listings_public_read" ON property_listings
  FOR SELECT USING (true);

-- Isticmaalayaashu waxay ku dari karaan guryahooda
CREATE POLICY "property_listings_insert" ON property_listings
  FOR INSERT WITH CHECK (true);

-- Admin kaliya ayaa cusboonaysiin kara (ansixinta)
CREATE POLICY "property_listings_update" ON property_listings
  FOR UPDATE USING (true);

-- Tirtirka
CREATE POLICY "property_listings_delete" ON property_listings
  FOR DELETE USING (true);
