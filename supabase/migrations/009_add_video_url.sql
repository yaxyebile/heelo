-- ── Add Video URL to Property Listings and Second Hand Items ──
ALTER TABLE property_listings ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE second_hand_items ADD COLUMN IF NOT EXISTS video_url TEXT;
