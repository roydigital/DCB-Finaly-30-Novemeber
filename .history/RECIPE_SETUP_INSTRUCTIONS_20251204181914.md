# Recipe Logic Setup - Complete Implementation

## What Has Been Implemented

### 1. Updated Menu Manager (admin/menu.html)
- Added recipe builder interface with tabbed layout (Basic Info / Recipe)
- Integrated inventory dropdown to select ingredients
- Recipe builder allows linking inventory items to menu items with quantities
- Recipe data is saved as JSONB in the `recipe` column

### 2. Auto Stock Deduction Logic (index.html)
- Added `updateInventoryFromOrder()` function that automatically deducts inventory when orders are placed
- Function processes each item in the order, checks its recipe, and deducts corresponding inventory quantities
- Logs all inventory updates for tracking
- Integrated into the existing `placeOrder()` function

### 3. Database Schema Update (recipe_schema_update.sql)
- SQL script to add `recipe` column to `menu_items` table as JSONB type
- Optional: Creates inventory_logs table for tracking stock changes
- Optional: Creates function and trigger for automatic inventory updates

## Final Step Required

### Run the SQL Script in Supabase

1. **Go to Supabase SQL Editor:**
   - Navigate to: https://supabase.com/dashboard/project/kjbelegkbusvtvtcgwhq/sql

2. **Copy and Run the SQL:**
   - Open `recipe_schema_update.sql` file
   - Copy the entire SQL content
   - Paste into the SQL Editor
   - Click "Run" or press Ctrl+Enter

3. **Alternative - Run Minimal SQL:**
   ```sql
   -- Add recipe column to menu_items table
   ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS recipe JSONB DEFAULT '{}'::jsonb;
   
   -- Add comment for documentation
   COMMENT ON COLUMN menu_items.recipe IS 'Recipe mapping: inventory item ID -> quantity needed per unit of menu item';
   ```

## Testing the Implementation

### Test 1: Recipe Builder Interface
1. Open `admin/menu.html`
2. Click "Add Item" or edit an existing item
3. Switch to "Recipe / Stock" tab
4. Select an inventory item from dropdown
5. Enter quantity needed
6. Click "+" to add to recipe
7. Save the item

### Test 2: Auto Stock Deduction
1. Open `index.html` (customer ordering page)
2. Add items with recipes to cart
3. Place an order with customer details
4. Check inventory levels in `admin/inventory.html`
5. Verify stock was automatically deducted

### Test 3: Schema Verification
1. Open `test_recipe_logic.html`
2. Click "Check if recipe column exists"
3. Verify it shows "Recipe column exists: YES"

## How It Works

### Recipe Data Structure
```json
{
  "inventory_item_id_1": 0.5,
  "inventory_item_id_2": 0.2,
  "inventory_item_id_3": 1.0
}
```
- Keys: Inventory item UUIDs
- Values: Quantity needed per unit of menu item

### Order Processing Flow
1. Customer places order → Order saved to database
2. `updateInventoryFromOrder()` function called
3. For each item in order:
   - Fetch recipe from menu_items
   - For each ingredient in recipe:
     - Calculate: `quantity_needed = recipe_quantity × order_quantity`
     - Update inventory: `new_stock = current_stock - quantity_needed`
4. Inventory updated in real-time

## Troubleshooting

### Common Issues

1. **Recipe column not found error:**
   - Run the SQL script to add the column

2. **Inventory not deducting:**
   - Check browser console for errors
   - Verify menu item has a recipe defined
   - Verify inventory items exist in database

3. **Recipe builder dropdown empty:**
   - Ensure inventory items exist in `inventory` table
   - Check network tab for fetch errors

### Support Files Created
- `recipe_schema_update.sql` - Database schema update
- `test_recipe_logic.html` - Testing interface
- `run_recipe_schema.js` - Node.js schema check script

## Next Steps

1. **Train staff** on using the recipe builder
2. **Set up recipes** for all menu items
3. **Monitor inventory** levels after initial implementation
4. **Consider adding** low stock alerts based on recipe usage

## Benefits Achieved

✅ **Automated stock management** - No manual calculations needed  
✅ **Real-time inventory updates** - Stock levels always accurate  
✅ **Recipe consistency** - Standardized portion sizes  
✅ **Waste reduction** - Precise ingredient tracking  
✅ **Cost control** - Better inventory forecasting

