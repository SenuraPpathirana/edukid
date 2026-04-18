-- EMERGENCY FIX for total_time = 330 issue
-- Run this in Supabase SQL Editor NOW!

-- Step 1: See what's wrong with the table
SELECT 
  column_name, 
  column_default, 
  is_nullable,
  data_type
FROM information_schema.columns
WHERE table_name = 'timer'
ORDER BY ordinal_position;

-- Step 2: Delete ALL test timers (start fresh)
DELETE FROM timer;

-- Step 3: Remove ANY default value from total_time
ALTER TABLE timer ALTER COLUMN total_time DROP DEFAULT;
ALTER TABLE timer ALTER COLUMN end_time DROP DEFAULT;

-- Step 4: Make sure they can be NULL
ALTER TABLE timer ALTER COLUMN total_time DROP NOT NULL;
ALTER TABLE timer ALTER COLUMN end_time DROP NOT NULL;

-- Step 5: Drop ALL triggers
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'timer') 
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON timer';
    END LOOP;
END $$;

-- Step 6: Verify everything is clean
SELECT 
  column_name, 
  column_default, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'timer' 
  AND column_name IN ('duration', 'start_time', 'end_time', 'total_time');

-- EXPECTED OUTPUT (must match this):
-- duration    | NULL (or empty) | NO
-- start_time  | NULL (or empty) | NO
-- end_time    | NULL (or empty) | YES  ← MUST BE YES
-- total_time  | NULL (or empty) | YES  ← MUST BE YES

-- Step 7: Check triggers are gone
SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'timer';
-- EXPECTED: Empty (no rows)

-- ✅ NOW: Restart your backend server and try creating a new timer!
