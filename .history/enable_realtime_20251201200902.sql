-- Enable Realtime for the orders table
-- Run this in your Supabase SQL Editor to ensure the database broadcasts changes

begin;
  -- 1. Ensure the publication exists (supabase_realtime is the default)
  -- This usually exists by default, but good to be sure
  -- insert into pg_publication (pubname) select 'supabase_realtime' where not exists (select 1 from pg_publication where pubname = 'supabase_realtime');

  -- 2. Add the orders table to the supabase_realtime publication
  alter publication supabase_realtime add table orders;

  -- 3. Verify it's enabled
  select * from pg_publication_tables where pubname = 'supabase_realtime';
commit;
