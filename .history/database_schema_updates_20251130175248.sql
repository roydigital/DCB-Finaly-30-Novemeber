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
-- Note: If you want to enable the total_orders tracking feature, uncomment line 8 above
-- This would require updating the code to increment this value when orders are placed
