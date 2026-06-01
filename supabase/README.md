# Supabase setup — Mogadishu Market

## 1. Run the database schema (required once)

1. Open [Supabase Dashboard](https://supabase.com/dashboard/project/ytfbkcxqbfhxsuqtmmme/sql/new)
2. Copy all of `migrations/001_initial_schema.sql`
3. Paste into **SQL Editor** → **Run**

This creates: `profiles`, `categories`, `stores`, `products`, `orders`, `promo_banners`, `app_settings`, `chat_messages` and default admin.

## 2. Default admin login

| Field | Value |
|-------|-------|
| Email | `admin@market.com` |
| Password | `admin123` |

Change the password after first login in production.

## 3. Flutter app

Credentials are in `lib/core/config/supabase_config.dart`. Run:

```bash
flutter pub get
flutter run
```

Data is loaded from Supabase on startup; demo products/stores seed automatically when tables are empty.
