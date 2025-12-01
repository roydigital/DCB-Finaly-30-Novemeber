-- Supabase Storage Setup for Menu Images
-- Run this in Supabase SQL Editor

-- 1. First, ensure you have created the 'files' bucket in the Supabase UI:
--    - Go to Storage → Create new bucket
--    - Name: 'files'
--    - Set to Public

-- 2. Create policy to allow public access for the 'files' bucket
CREATE POLICY "Allow public uploads" ON storage.objects
FOR ALL 
USING (bucket_id = 'files');

-- 3. Optional: Create a more restrictive policy if you prefer:
-- CREATE POLICY "Allow public uploads to menu-images" ON storage.objects
-- FOR ALL 
-- USING (
--   bucket_id = 'files' 
--   AND (storage.foldername(name))[1] = 'menu-images'
-- );

-- 4. If you want to allow delete operations as well:
-- CREATE POLICY "Allow public deletes" ON storage.objects
-- FOR DELETE
-- USING (bucket_id = 'files');

-- 5. Verify the policy was created
SELECT * FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage';

-- Note: If the 'files' bucket doesn't exist, you'll need to create it 
-- through the Supabase Dashboard UI first, as bucket creation via SQL 
-- is not typically supported in the public API.
