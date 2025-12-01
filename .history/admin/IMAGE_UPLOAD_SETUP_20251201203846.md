# Image Upload Setup for Menu Manager

## Overview
The drag-and-drop image upload functionality has been implemented in `admin/menu.html`. Images are uploaded to Supabase Storage and the generated URL is automatically added to the menu item's `image_url` field.

## Supabase Storage Configuration

### 1. Create Storage Bucket
1. Go to your Supabase project dashboard
2. Navigate to **Storage** → **Create new bucket**
3. Create a bucket named: `files` (must be lowercase)
4. Set bucket to **Public** (so images can be accessed without authentication)

### 2. Configure CORS (Cross-Origin Resource Sharing)
To allow uploads from your admin interface, configure CORS:

1. In Supabase Dashboard, go to **Storage** → **Policies**
2. Click **New Policy** for the `files` bucket
3. Create a policy with these settings:
   - Policy Name: `Allow public uploads`
   - Operation: `INSERT`, `SELECT`, `UPDATE`
   - Policy Definition: `true` (allow all)
   - OR use SQL:
   ```sql
   CREATE POLICY "Allow public uploads" ON storage.objects
   FOR ALL USING (bucket_id = 'files');
   ```

### 3. Folder Structure
- Images will be uploaded to: `menu-images/` folder within the `files` bucket
