-- Add recipe column to menu_items table for auto stock deduction
-- Run this in Supabase SQL Editor

-- 1. Check if recipe column exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'menu_items' 
        AND column_name = 'recipe'
    ) THEN
        -- 2. Add recipe column as JSONB (stores {inventory_id: quantity})
        ALTER TABLE menu_items ADD COLUMN recipe JSONB DEFAULT '{}'::jsonb;
        
        -- 3. Add comment for documentation
        COMMENT ON COLUMN menu_items.recipe IS 'Recipe mapping: inventory item ID -> quantity needed per unit of menu item';
        
        RAISE NOTICE 'Added recipe column to menu_items table';
    ELSE
        RAISE NOTICE 'Recipe column already exists in menu_items table';
    END IF;
END $$;

-- 4. Verify the column was added
SELECT 
    table_name, 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'menu_items'
ORDER BY ordinal_position;

-- 5. Sample query to see recipe data
SELECT 
    id,
    name,
    category,
    recipe
FROM menu_items 
WHERE recipe IS NOT NULL AND recipe != '{}'::jsonb
LIMIT 5;

-- 6. Create a function to update inventory when an order is placed
-- This function will be called from a trigger or from the order processing code
CREATE OR REPLACE FUNCTION update_inventory_from_order()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
    recipe_item RECORD;
    quantity_needed NUMERIC;
    inventory_id UUID;
BEGIN
    -- For each item in the order_items table (assuming you have such a table)
    -- This is a template; you'll need to adapt based on your actual schema
    FOR item IN 
        SELECT menu_item_id, quantity 
        FROM order_items 
        WHERE order_id = NEW.id
    LOOP
        -- Get the recipe for this menu item
        SELECT recipe INTO recipe_item
        FROM menu_items 
        WHERE id = item.menu_item_id;
        
        -- If recipe exists and is not empty
        IF recipe_item.recipe IS NOT NULL AND recipe_item.recipe != '{}'::jsonb THEN
            -- Loop through each ingredient in the recipe
            FOR inventory_id, quantity_needed IN 
                SELECT * FROM jsonb_each_text(recipe_item.recipe)
            LOOP
                -- Convert quantity_needed to numeric
                quantity_needed := quantity_needed::numeric;
                
                -- Update inventory: subtract (quantity_needed * item.quantity)
                UPDATE inventory 
                SET current_stock = current_stock - (quantity_needed * item.quantity)
                WHERE id = inventory_id::uuid;
                
                -- Log the deduction (optional)
                INSERT INTO inventory_logs (inventory_id, change_amount, reason, created_at)
                VALUES (inventory_id::uuid, -(quantity_needed * item.quantity), 
                        'Order #' || NEW.id || ' - ' || (SELECT name FROM menu_items WHERE id = item.menu_item_id),
                        NOW());
            END LOOP;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger to automatically update inventory when order status changes to 'completed'
-- (Assuming you have an orders table with status field)
-- DROP TRIGGER IF EXISTS update_inventory_on_order_complete ON orders;
-- CREATE TRIGGER update_inventory_on_order_complete
-- AFTER UPDATE OF status ON orders
-- FOR EACH ROW
-- WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
-- EXECUTE FUNCTION update_inventory_from_order();

-- Note: The trigger above is commented out because you might want to handle inventory
-- updates differently (e.g., when order is placed, not when completed).
-- Adjust based on your business logic.

-- 8. Create inventory_logs table if it doesn't exist (for tracking stock changes)
CREATE TABLE IF NOT EXISTS inventory_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    inventory_id UUID REFERENCES inventory(id),
    change_amount NUMERIC NOT NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Create index for better performance
CREATE INDEX IF NOT EXISTS idx_inventory_logs_inventory_id ON inventory_logs(inventory_id);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_created_at ON inventory_logs(created_at);

-- 10. Verify everything is set up
