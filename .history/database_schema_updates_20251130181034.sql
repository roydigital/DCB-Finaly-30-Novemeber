-- DATABASE SCHEMA FIX FOR DCB ORDERING SYSTEM
-- Based on your actual table schemas

-- 1. First, let's see what data we have
SELECT 'Current order data:' as info;
SELECT DISTINCT order_type, status, payment_method FROM orders;

-- 2. The main issue: Your orders table constraint only allows ['online', 'walkin', 'dining']
-- but your code is trying to insert 'Delivery'. We need to update the constraint.

-- 3. Drop the existing constraint
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_order_type_check;

-- 4. Update existing data to match the new constraint
-- Convert existing order_type values to the allowed ones
-- Fix payment method values  
UPDATE orders SET payment_method = 'COD' WHERE payment_method = 'cash';
UPDATE orders SET payment_method = 'Online' WHERE payment_method = 'online';
UPDATE orders SET payment_method = 'Card' WHERE payment_method = 'card';

-- Fix order type values
UPDATE orders SET order_type = 'Delivery' WHERE order_type = 'delivery';
UPDATE orders SET order_type = 'Pickup' WHERE order_type = 'pickup';

-- 3. DROP ALL CONSTRAINTS FIRST
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_order_type_check;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_payment_method_check;

-- 4. ADD MISSING COLUMNS
ALTER TABLE orders ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'COD';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Pending';

ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS name TEXT;

ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS prices JSONB;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS in_stock BOOLEAN DEFAULT true;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS category TEXT;

-- 5. UPDATE EXISTING ROWS WITH DEFAULT VALUES
UPDATE orders SET payment_method = 'COD' WHERE payment_method IS NULL;
UPDATE orders SET status = 'Pending' WHERE status IS NULL;

-- 6. ADD CONSTRAINTS BACK WITH PROPER VALUES
ALTER TABLE orders ADD CONSTRAINT orders_order_type_check 
CHECK (order_type IN ('Delivery', 'Pickup', 'Dine-in'));

ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'Completed', 'Cancelled'));

ALTER TABLE orders ADD CONSTRAINT orders_payment_method_check 
CHECK (payment_method IN ('COD', 'Online', 'Card'));

-- 7. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_menu_items_in_stock ON menu_items(in_stock);

-- 8. VERIFICATION QUERIES
SELECT 'Orders table columns:' as info;
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'orders'
ORDER BY ordinal_position;

SELECT 'Customers table columns:' as info;
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'customers'
ORDER BY ordinal_position;

SELECT 'Current order data sample:' as info;
SELECT order_type, status, payment_method FROM orders LIMIT 10;
