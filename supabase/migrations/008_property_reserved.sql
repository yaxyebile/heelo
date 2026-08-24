-- 008_property_reserved.sql
-- Ku dar tiirka is_reserved jadwalka property_listings-ka
-- Ku dhex orod SQL Editor-kaaga (Supabase) haddii aadan helin tiirkan

ALTER TABLE property_listings
  ADD COLUMN IF NOT EXISTS is_reserved BOOLEAN DEFAULT false;
