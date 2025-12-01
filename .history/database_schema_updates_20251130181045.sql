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
UPDATE orders SET order_type = 'walkin' WHERE order_type IS NULL OR order_type NOT IN ('online', 'walkin', 'dining');

-- 5. Add the new constraint that allows 'Delivery' (or change the code to use existing types)
-- Option A: Change constraint to allow 'Delivery' (recommended)
ALTER TABLE orders ADD CONSTRAINT orders_order_type_check 
CHECK (order_type IN ('online', 'walkin', 'dining', 'Delivery', 'Pickup'));

-- 6. Update the code in index.html to use allowed order_type values
-- Since your constraint now allows 'Delivery', the code should work

-- 7. Also update status and payment_method to match your defaults
UPDATE orders SET status = 'pending' WHERE status IS NULL;
UPDATE orders SET payment_method = 'cash' WHERE payment_method IS NULL;

-- 8. Add the note column if it doesn't exist
ALTER TABLE orders ADD COLUMN IF NOT EXISTS note TEXT;

-- 9. Verification
SELECT 'Orders table after changes:' as info;
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'orders'
ORDER BY ordinal_position;

SELECT 'Current constraints:' as info;
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name = 'orders';

SELECT 'Sample order data:' as info;
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
