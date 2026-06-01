-- Mogadishu Market — initial schema
-- Run in Supabase Dashboard → SQL Editor

-- Profiles (custom auth — matches existing app)
CREATE TABLE IF NOT EXISTS profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  store_id TEXT,
  phone TEXT,
  is_banned BOOLEAN NOT NULL DEFAULT false
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL
);

-- Stores
CREATE TABLE IF NOT EXISTS stores (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  logo TEXT NOT NULL DEFAULT '',
  banner TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  contact TEXT NOT NULL DEFAULT '',
  rating DOUBLE PRECISION NOT NULL DEFAULT 0,
  followers INTEGER NOT NULL DEFAULT 0,
  is_approved BOOLEAN NOT NULL DEFAULT false,
  owner_id TEXT NOT NULL,
  has_delivery BOOLEAN NOT NULL DEFAULT true,
  evc_number TEXT,
  edahab_number TEXT,
  is_banned BOOLEAN NOT NULL DEFAULT false
);

-- Products
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price DOUBLE PRECISION NOT NULL,
  image TEXT NOT NULL DEFAULT '',
  category_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  store_name TEXT NOT NULL DEFAULT '',
  rating DOUBLE PRECISION NOT NULL DEFAULT 0,
  stock INTEGER NOT NULL DEFAULT 0,
  is_approved BOOLEAN NOT NULL DEFAULT false
);

-- Orders (items stored as JSONB)
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  items JSONB NOT NULL DEFAULT '[]',
  total_amount DOUBLE PRECISION NOT NULL,
  date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status TEXT NOT NULL DEFAULT 'pending',
  store_id TEXT NOT NULL,
  payment_method TEXT NOT NULL DEFAULT 'evcPlus',
  is_paid BOOLEAN NOT NULL DEFAULT false,
  delivery_person_id TEXT,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  customer_name TEXT,
  customer_phone TEXT,
  customer_address TEXT
);

-- Promo banners
CREATE TABLE IF NOT EXISTS promo_banners (
  id TEXT PRIMARY KEY,
  image_url TEXT NOT NULL,
  title TEXT NOT NULL,
  tag TEXT NOT NULL DEFAULT '',
  btn_text TEXT NOT NULL DEFAULT 'Shop Now',
  color_hex TEXT NOT NULL DEFAULT '0xFFFF6B00'
);

-- App settings (admin payment numbers, etc.)
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Chat messages
CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT PRIMARY KEY,
  sender_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_read BOOLEAN NOT NULL DEFAULT false
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_store ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_store ON orders(store_id);
CREATE INDEX IF NOT EXISTS idx_chat_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_receiver ON chat_messages(receiver_id);

-- RLS (permissive for anon client — custom auth in app)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_all_profiles" ON profiles FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_categories" ON categories FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_stores" ON stores FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_products" ON products FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_orders" ON orders FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_promos" ON promo_banners FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_settings" ON app_settings FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_chat" ON chat_messages FOR ALL TO anon USING (true) WITH CHECK (true);

-- Default admin (change password after first login)
INSERT INTO profiles (id, name, email, password, role)
VALUES ('admin', 'Super Admin', 'admin@market.com', 'admin123', 'admin')
ON CONFLICT (id) DO NOTHING;

INSERT INTO app_settings (key, value) VALUES
  ('admin_evc', '614227744'),
  ('admin_edahab', '624227744')
ON CONFLICT (key) DO NOTHING;
