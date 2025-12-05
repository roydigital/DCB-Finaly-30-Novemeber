const { createClient } = require('@supabase/supabase-js');
const supabaseUrl = 'https://kjbelegkbusvtvtcgwhq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqYmVsZWdrYnVzdnR2dGNnd2hxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MjI5ODIsImV4cCI6MjA3NDA5ODk4Mn0.-K-rkuJnyDPL5YnkJ62-UG1_mG0BIILMUEZpSTNnq5M';
const supabase = createClient(supabaseUrl, supabaseKey);

async function checkSchema() {
  try {
    // Check if recipe column exists in menu_items
    const { data, error } = await supabase
      .from('menu_items')
      .select('*')
      .limit(1);
    
    if (error) {
      console.log('Error fetching menu_items:', error.message);
      return;
    }
    
    if (data && data.length > 0) {
      const sample = data[0];
      console.log('Sample menu_item fields:', Object.keys(sample));
      console.log('Has recipe field?', 'recipe' in sample);
      if ('recipe' in sample) {
        console.log('Recipe sample:', sample.recipe);
      }
    } else {
      console.log('No menu_items found');
    }
  } catch (err) {
    console.error('Error:', err.message);
  }
}

checkSchema();
