-- CRITICAL FIX: Timer table issues
-- Copy and paste each section into Supabase SQL Editor and run them one by one

-- ====================================================================
-- STEP 1: DIAGNOSE THE PROBLEM
-- ====================================================================

-- Check database timezone
SHOW timezone;

-- Check timer table structure and defaults
SELECT 
  column_name, 
  data_type, 
  column_default, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'timer'
ORDER BY ordinal_position;

-- ⚠️ CRITICAL: Check for triggers (these might be auto-setting end_time!)
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table, 
  action_statement,
  action_timing
FROM information_schema.triggers 
WHERE event_object_table = 'timer';

-- Check for functions that might be called by triggers
SELECT 
  routine_name, 
  routine_definition
FROM information_schema.routines
WHERE routine_name LIKE '%timer%';

-- ====================================================================
-- STEP 2: VIEW CURRENT BAD DATA
-- ====================================================================

-- Show all recent timers with their issues
SELECT 
  timer_id,
  kid_id,
  duration,
  start_time,
  end_time,
  total_time,
  EXTRACT(EPOCH FROM (end_time - start_time)) as actual_seconds,
  CASE 
    WHEN end_time IS NULL THEN 'ACTIVE'
    WHEN EXTRACT(EPOCH FROM (end_time - start_time)) < 10 THEN 'ERROR - Stopped too quickly'
    ELSE 'STOPPED'
  END as status
FROM timer 
ORDER BY start_time DESC
LIMIT 10;

-- ====================================================================
-- STEP 3: FIX THE DATA
-- ====================================================================

-- Delete all bad test timers (end_time within 5 seconds of start_time)
DELETE FROM timer 
WHERE end_time IS NOT NULL 
  AND EXTRACT(EPOCH FROM (end_time - start_time)) < 5
  AND start_time > NOW() - INTERVAL '7 days';

-- Reset any remaining bad timers instead of deleting
UPDATE timer 
SET end_time = NULL,
    total_time = NULL
WHERE end_time IS NOT NULL 
  AND EXTRACT(EPOCH FROM (end_time - start_time)) < 10
  AND start_time > NOW() - INTERVAL '1 day';

-- ====================================================================
-- STEP 4: FIX THE SCHEMA
-- ====================================================================

-- Remove unwanted default values (RUN THESE IF STEP 1 SHOWED DEFAULTS)
ALTER TABLE timer ALTER COLUMN end_time DROP DEFAULT;
ALTER TABLE timer ALTER COLUMN total_time DROP DEFAULT;

-- Ensure columns allow NULL
ALTER TABLE timer ALTER COLUMN end_time DROP NOT NULL;
ALTER TABLE timer ALTER COLUMN total_time DROP NOT NULL;

-- ====================================================================
-- STEP 5: DROP ANY AUTO-SETTING TRIGGERS
-- ====================================================================

-- Drop common trigger names
DROP TRIGGER IF EXISTS auto_set_end_time ON timer;
DROP TRIGGER IF EXISTS auto_complete_timer ON timer;
DROP TRIGGER IF EXISTS set_timer_end ON timer;
DROP TRIGGER IF EXISTS timer_auto_complete ON timer;
DROP TRIGGER IF EXISTS update_timer_total ON timer;
DROP TRIGGER IF EXISTS calculate_total_time ON timer;

-- ====================================================================
-- STEP 6: VERIFY THE FIX
-- ====================================================================

-- Check recent timers
SELECT 
  timer_id,
  kid_id,
  duration as set_duration_minutes,
  start_time,
  end_time,
  total_time as actual_spent_minutes,
  CASE 
    WHEN end_time IS NULL THEN 'RUNNING'
    ELSE CONCAT(
      FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)) / 60)::text, 
      ' minutes (', 
      EXTRACT(EPOCH FROM (end_time - start_time))::text, 
      ' seconds)'
    )
  END as calculated_duration
FROM timer 
WHERE start_time > NOW() - INTERVAL '1 day'
ORDER BY start_time DESC;

-- EXPECTED BEHAVIOR:
-- When timer STARTS:
--   - duration: Set by user (e.g., 60 minutes)
--   - start_time: Current timestamp
--   - end_time: NULL (timer is running)
--   - total_time: NULL (not spent yet)
--
-- When timer STOPS:
--   - end_time: Current timestamp (when stopped)
--   - total_time: Calculate as (end_time - start_time) in minutes
--
-- Example:
--   User sets 60 min timer at 3:00 PM
--   - If completed fully: end_time = 4:00 PM, total_time = 60
--   - If stopped at 3:25 PM: end_time = 3:25 PM, total_time = 25

