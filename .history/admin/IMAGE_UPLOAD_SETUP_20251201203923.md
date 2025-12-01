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
- File naming: `{timestamp}-{random}.{extension}` (e.g., `1733075505123-abc123.jpg`)

## How It Works

### User Interface
1. **Drag & Drop Area**: Users can drag images directly onto the upload area
2. **File Browser**: Click "Browse Files" or the upload area to select images
3. **Image Preview**: Selected images show immediate preview
4. **Upload Progress**: Shows upload status with progress indicator
5. **Auto-fill URL**: After upload, the image URL is automatically populated in the form

### Technical Implementation
1. **File Validation**: 
   - Only image files (JPG, PNG, WebP) accepted
   - Maximum file size: 5MB
   - Client-side validation before upload

2. **Upload Process**:
   ```javascript
   // 1. Generate unique filename
   const fileName = `${Date.now()}-${random}.${ext}`
   const filePath = `menu-images/${fileName}`
   
   // 2. Upload to Supabase Storage
   await supabase.storage.from('files').upload(filePath, file)
   
   // 3. Get public URL
   const { data } = supabase.storage.from('files').getPublicUrl(filePath)
   
   // 4. Update form field
   document.getElementById('inp-image').value = data.publicUrl
   ```

3. **Error Handling**:
   - Clear error messages for common issues
   - Guidance for bucket configuration problems
   - Graceful fallback if upload fails

## Testing the Feature

### Quick Test
1. Open `admin/menu.html` in browser
2. Click "Add Item" button
3. In the drawer, try:
   - Dragging an image onto the upload area
   - Clicking the upload area to browse for images
   - Using the "Browse Files" button
4. Verify:
   - Image preview appears
   - Upload progress shows
   - URL field is auto-filled after upload
   - Copy URL button works
   - Clear button resets the selection

### Integration Test
1. Upload an image
2. Fill other required fields (Name, Category, Price)
3. Click "SAVE ITEM"
4. Verify the item appears in the menu table with the uploaded image

## Troubleshooting

### Common Issues

1. **"Upload failed: Storage bucket 'files' may not exist"**
   - Solution: Create the `files` bucket in Supabase Storage

2. **"Upload failed: Permission denied"**
   - Solution: Configure bucket policies to allow public uploads

3. **CORS errors in browser console**
   - Solution: Ensure CORS is configured in Supabase Storage settings
   - Add your domain to allowed origins

4. **Images not displaying after upload**
   - Check if bucket is set to "Public"
   - Verify the image URL is accessible directly in browser

### Browser Compatibility
- Works in modern browsers (Chrome, Firefox, Safari, Edge)
- Requires JavaScript enabled
- File API support (all modern browsers)

## Security Considerations

1. **File Type Validation**: Only image files allowed
2. **Size Limits**: 5MB maximum per file
3. **Unique Filenames**: Prevents overwriting existing files
4. **Public Access**: Bucket is public for simplicity
   - For production, consider adding authentication
   - Implement signed URLs for better security

## Performance Notes

1. **Client-side Processing**:
   - Image preview uses FileReader (no server round-trip)
   - Validation happens before upload

2. **Upload Optimization**:
   - Files uploaded directly to Supabase (no intermediate server)
   - Progress indicators for user feedback

3. **Caching**:
   - Supabase Storage configured with 1-hour cache control
   - Consider CDN integration for better performance

## Future Enhancements

1. **Image Compression**: Client-side compression before upload
2. **Multiple Uploads**: Support for uploading multiple images
3. **Image Editing**: Basic crop/resize before upload
4. **Bulk Operations**: Upload images for multiple items at once
5. **Storage Analytics**: Track storage usage and optimize

## Support
For issues with the upload functionality, check:
1. Browser console for errors
2. Supabase Storage bucket configuration
3. Network tab for upload requests
4. CORS configuration in Supabase
