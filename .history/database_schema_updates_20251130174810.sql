-- SQL Script to Add Missing Columns to Supabase Tables
-- Run this in your Supabase SQL Editor

-- 1. Add 'note' column to orders table (for delivery address/notes)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS note TEXT;

-- 2. Add 'address' column to customers table (for storing customer addresses)
ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;

-- 3. Optional: Add 'total_orders' column if you want to track order count per customer
-- ALTER TABLE customers ADD COLUMN IF NOT EXISTS total_orders INTEGER DEFAULT 0;

-- 4. Verify the changes
SELECT 
    table_name, 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name IN ('orders', 'customers') 
    AND column_name IN ('note', 'address')
ORDER BY table_name, column_name;

-- Note: If you want to enable the total_orders tracking feature, uncomment line 8 above
-- This would require updating the code to increment this value when orders are placed
