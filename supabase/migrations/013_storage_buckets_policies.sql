-- Create storage buckets for images, product-images, and videos
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('images', 'images', true),
  ('product-images', 'product-images', true),
  ('videos', 'videos', true)
ON CONFLICT (id) DO NOTHING;

-- Set up permissive storage policies for Select and Insert to allow anon/authenticated uploads and downloads
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id IN ('images', 'product-images', 'videos'));

DROP POLICY IF EXISTS "Allow Anon Uploads" ON storage.objects;
CREATE POLICY "Allow Anon Uploads" 
ON storage.objects FOR INSERT 
TO public 
WITH CHECK (bucket_id IN ('images', 'product-images', 'videos'));

DROP POLICY IF EXISTS "Allow Owner Deletes" ON storage.objects;
CREATE POLICY "Allow Owner Deletes" 
ON storage.objects FOR DELETE 
TO public 
USING (bucket_id IN ('images', 'product-images', 'videos'));
