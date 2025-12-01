-- COMPREHENSIVE DATABASE SCHEMA FIX FOR DCB ORDERING SYSTEM
-- Run this in your Supabase SQL Editor to fix all schema issues

-- 1. Check and fix orders table constraints and columns
-- First, let's check what values are allowed for order_type
-- If needed, drop and recreate the check constraint with proper values
DO $$ 
BEGIN
    -- Check if the constraint exists and drop it if needed
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints 
               WHERE constraint_name = 'orders_order_type_check' AND table_name = 'orders') THEN
        ALTER TABLE orders DROP CONSTRAINT orders_order_type_check;
    END IF;
    
    -- Add the constraint with allowed values that match the code
    ALTER TABLE orders ADD CONSTRAINT orders_order_type_check 
    CHECK (order_type IN ('Delivery', 'Pickup', 'delivery', 'pickup', 'Dine-in'));
END $$;

-- 2. Add missing columns to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status TEXT;

-- 3. Add constraints for payment_method and status if they don't exist
DO $$ 
BEGIN
    -- Payment method constraint
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orders_payment_method_check' AND table_name = 'orders') THEN
        ALTER TABLE orders ADD CONSTRAINT orders_payment_method_check 
        CHECK (payment_method IN ('COD', 'Online', 'Card', 'cod', 'online', 'card'));
    END IF;
    
    -- Status constraint  
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orders_status_check' AND table_name = 'orders') THEN
        ALTER TABLE orders ADD CONSTRAINT orders_status_check 
        CHECK (status IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'Completed', 'Cancelled',
                         'pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'));
    END IF;
END $$;

-- 4. Add missing columns to customers table
ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS name TEXT;

-- 5. Ensure menu_items table has all required columns
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS prices JSONB;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS in_stock BOOLEAN DEFAULT true;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS category TEXT;

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_menu_items_in_stock ON menu_items(in_stock);

-- 7. Verify all changes
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('orders', 'customers', 'menu_items')
ORDER BY table_name, ordinal_position;

-- 8. Show table constraints
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name IN ('orders', 'customers', 'menu_items')
ORDER BY tc.table_name, tc.constraint_name;
