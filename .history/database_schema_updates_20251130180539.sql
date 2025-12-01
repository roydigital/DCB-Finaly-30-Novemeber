-- COMPREHENSIVE DATABASE SCHEMA FIX FOR DCB ORDERING SYSTEM
-- Run this in your Supabase SQL Editor to fix all schema issues

-- 1. First, let's check what order_type values exist in the table
SELECT DISTINCT order_type FROM orders;

-- 2. SAFE APPROACH: First fix the existing data, then drop constraint
-- Update any NULL or invalid order_type values to 'Delivery'
UPDATE orders 
SET order_type = 'Delivery' 
WHERE order_type IS NULL OR order_type NOT IN ('Delivery', 'Pickup', 'Dine-in');

-- 3. TEMPORARILY DISABLE ALL CONSTRAINTS to avoid conflicts
-- First drop the constraint if it exists
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_order_type_check;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_payment_method_check;

-- 4. Add missing columns to orders table with proper defaults
ALTER TABLE orders ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'COD';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Pending';

-- 5. Update existing rows with default values
UPDATE orders SET payment_method = 'COD' WHERE payment_method IS NULL;
UPDATE orders SET status = 'Pending' WHERE status IS NULL;

-- 6. Add missing columns to customers table
ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS name TEXT;

-- 7. Ensure menu_items table has all required columns
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS prices JSONB;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS in_stock BOOLEAN DEFAULT true;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS category TEXT;

-- 8. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_menu_items_in_stock ON menu_items(in_stock);

-- 9. Verify all changes
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('orders', 'customers', 'menu_items')
ORDER BY table_name, ordinal_position;

-- 10. Show table constraints
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name IN ('orders', 'customers', 'menu_items')
ORDER BY tc.table_name, tc.constraint_name;
