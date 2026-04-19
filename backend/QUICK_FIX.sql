-- ⚡ QUICK FIX - Run this first to stop the bleeding
-- Copy and paste this entire block into Supabase SQL Editor

-- 1. Check what's setting total_time to 330
SELECT 
  column_name, 
  column_default, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'timer';

-- 2. Delete all the bad test timers
DELETE FROM timer 
WHERE start_time > NOW() - INTERVAL '7 days';

-- 3. Drop any triggers that might be auto-setting values
DROP TRIGGER IF EXISTS auto_set_end_time ON timer;
DROP TRIGGER IF EXISTS auto_complete_timer ON timer;
DROP TRIGGER IF EXISTS set_timer_end ON timer;
DROP TRIGGER IF EXISTS timer_auto_complete ON timer;
DROP TRIGGER IF EXISTS update_timer_total ON timer;
DROP TRIGGER IF EXISTS calculate_total_time ON timer;
DROP TRIGGER IF EXISTS set_total_time ON timer;

-- 4. Remove default values that might be setting values automatically
ALTER TABLE timer ALTER COLUMN end_time DROP DEFAULT;
ALTER TABLE timer ALTER COLUMN total_time DROP DEFAULT;

-- 5. Allow NULL values
ALTER TABLE timer ALTER COLUMN end_time DROP NOT NULL;
ALTER TABLE timer ALTER COLUMN total_time DROP NOT NULL;

-- 6. Verify - this should show end_time and total_time as nullable with no defaults
SELECT 
  column_name, 
  column_default, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'timer' 
  AND column_name IN ('end_time', 'total_time');

-- Expected output:
-- end_time    | NULL (or empty) | YES
-- total_time  | NULL (or empty) | YES

-- 7. Check no triggers remain
SELECT trigger_name, action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'timer';

-- Expected: No rows returned (empty result)

-- 8. Check for functions being called
SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_name LIKE '%timer%'
  AND routine_type = 'FUNCTION';

-- ✅ If all checks pass, restart your backend server and test!
