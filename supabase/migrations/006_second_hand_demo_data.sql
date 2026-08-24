-- ─────────────────────────────────────────────
-- 006_second_hand_demo_data.sql
-- Xogta Dheemo (Demo Data) ee Suuqa Casriga Ah
-- Fadlan ku dhex orod SQL Editor-kaaga (Supabase)
-- ─────────────────────────────────────────────

INSERT INTO second_hand_items (
  id, title, description, seller_id, seller_name, seller_phone, 
  category, condition, price, currency, location, images, status, created_at
) VALUES 
(
  'sh_101', 
  'MacBook Pro M1 2020', 
  'Kombiyuutar Macbook Pro M1 ah, aad u nadiif ah oo aan wax xag xag ah lahayn. Battery health 95%.', 
  'admin_user_id_1', 
  'Mukhtar Tech', 
  '+252610000001', 
  'electronics', 
  'likeNew', 
  850, 
  'USD', 
  'Mogadishu, KM4', 
  '{"https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800"}', 
  'approved', 
  now()
),
(
  'sh_102', 
  'Samsung S22 Ultra', 
  'Taleefan S22 Ultra, 256GB storage, Midab madow. Shaashada waxba kama jabin waana hubal.', 
  'admin_user_id_1', 
  'Hodan Mobiles', 
  '+252610000002', 
  'electronics', 
  'good', 
  620, 
  'USD', 
  'Mogadishu, Hodan', 
  '{"https://images.unsplash.com/photo-1649859398021-afbfe80e83b9?auto=format&fit=crop&w=800"}', 
  'approved', 
  now() - interval '1 day'
),
(
  'sh_103', 
  'Sariir Double ah oo Nadiif ah', 
  'Sariir weyn oo laba qofle ah oo alwaax fiyoor fiyoor ah (Mahogany). Cilmilo kasta u adkaysata.', 
  'admin_user_id_1', 
  'Ustaad Alaabta Guriga', 
  '+252610000003', 
  'furniture', 
  'fair', 
  120, 
  'USD', 
  'Mogadishu, Waberi', 
  '{"https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800"}', 
  'approved', 
  now() - interval '2 days'
),
(
  'sh_104', 
  'Dharka Hiddaha iyo Dhaqanka', 
  'Saddex qaybood oo dharka hiddaha iyo dhaqanka u badan macawis gacanta lagu tolo.', 
  'admin_user_id_1', 
  'Xareedo Fashion', 
  '+252610000004', 
  'clothing', 
  'new', 
  45, 
  'USD', 
  'Mogadishu, Hamar Weyne', 
  '{"https://images.unsplash.com/photo-1515347619252-c36ae55cb470?auto=format&fit=crop&w=800"}', 
  'approved', 
  now() - interval '3 hours'
),
(
  'sh_105', 
  'Gaari Toyota Vitz 2010', 
  'Gaari Vitz cad ah oo taarkeedu yahay Mogadishu. Mishiin iyo Giyar box waa caadi.', 
  'admin_user_id_1', 
  'Gaadiid Auto', 
  '+252610000005', 
  'vehicles', 
  'good', 
  4200, 
  'USD', 
  'Mogadishu, Maka Al-Mukarama', 
  '{"https://images.unsplash.com/photo-1590362891991-f766f809ec0a?auto=format&fit=crop&w=800"}', 
  'approved', 
  now() - interval '4 days'
);
