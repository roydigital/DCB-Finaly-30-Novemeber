const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://kjbelegkbusvtvtcgwhq.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqYmVsZWdrYnVzdnR2dGNnd2hxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MjI5ODIsImV4cCI6MjA3NDA5ODk4Mn0.-K-rkuJnyDPL5YnkJ62-UG1_mG0BIILMUEZpSTNnq5M';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function runSchemaUpdate() {
    console.log('Running recipe schema update...');
    
    try {
        // Check if recipe column exists
        const { data: checkData, error: checkError } = await supabase
            .from('menu_items')
            .select('*')
            .limit(1);
            
        if (checkError) {
            console.error('Error checking menu_items:', checkError);
            return;
        }
        
        if (checkData.length > 0) {
            const sample = checkData[0];
            console.log('Sample menu_item fields:', Object.keys(sample));
            console.log('Has recipe field?', 'recipe' in sample);
            
            if ('recipe' in sample) {
                console.log('Recipe column already exists!');
                console.log('Recipe sample:', sample.recipe);
            } else {
                console.log('Recipe column does not exist. Need to add it via SQL.');
                console.log('Please run the SQL in recipe_schema_update.sql manually in Supabase SQL Editor.');
            }
        }
        
        // Try to run SQL via RPC if we have a function, but we don't.
        // Instead, we'll just log what needs to be done.
        console.log('\n=== IMPORTANT ===');
        console.log('To add the recipe column to menu_items table:');
        console.log('1. Go to https://supabase.com/dashboard/project/kjbelegkbusvtvtcgwhq/sql');
        console.log('2. Copy the SQL from recipe_schema_update.sql');
        console.log('3. Run it in the SQL Editor');
        console.log('4. The recipe column will be added as JSONB type');
        
    } catch (err) {
        console.error('Error:', err);
    }
}

runSchemaUpdate();
