# Timer Logic Fix - Complete Guide

## Understanding the Timer Fields

1. **`duration`** (int) - Time limit set by user in **minutes** (e.g., 60)
2. **`start_time`** (timestamp) - When user clicks "Start Timer" button
3. **`end_time`** (timestamp) - When timer stops:
   - If user completes full duration: `end_time = start_time + duration`
     - Example: Start 3:00 PM + 60 min = End 4:00 PM
   - If user stops early: `end_time = actual stop time`
     - Example: Start 3:00 PM, stopped at 3:25 PM = End 3:25 PM
4. **`total_time`** (int) - **ACTUAL spent time** in **minutes**
   - Calculated as: `(end_time - start_time)` in minutes
   - Example: 3:25 PM - 3:00 PM = 25 minutes

## Issues Fixed

### Issue 1: `end_time` Set Immediately
**Problem**: Timer shows `end_time` within 1 second of `start_time`
- This makes the timer appear "stopped" immediately
- Database shows: `start_time: 16:42:46`, `end_time: 16:42:47` (only 1 second!)

**Root Cause**: Database trigger, default value, or duplicate API calls

**Fix**: 
- Backend now explicitly sets `end_time: null` when creating timer
- Updated SQL script checks for triggers and default values

### Issue 2: `total_time` Not Calculated Correctly
**Problem**: `total_time` was just copying `duration` value
- Should calculate ACTUAL elapsed time, not planned duration

**Fix**: Backend now calculates when stopping:
```javascript
const elapsedMinutes = Math.floor((end_time - start_time) / 60000);
```

## Changes Made

### Backend Code Updated
File: `backend/src/modules/timers/timers.routes.js`

**On Timer Start (POST /timers)**:
```javascript
{
  duration: 60,        // User's set limit
  start_time: NOW(),   // Current time
  end_time: null,      // Not finished yet
  total_time: null     // Not spent yet
}
```

**On Timer Stop (PUT /timers/:id/stop)**:
```javascript
const elapsedMinutes = Math.floor((endTime - startTime) / 1000 / 60);

{
  end_time: NOW(),            // When stopped
  total_time: elapsedMinutes  // Actual time spent
}
```

## How to Fix Your Database

### Step 1: Open Supabase SQL Editor
1. Go to Supabase Dashboard
2. Navigate to **SQL Editor**
3. Create a new query

### Step 2: Run Diagnostic Queries

Copy and paste from `timer_timezone_fix.sql`:

```sql
-- Check for database triggers (might auto-set end_time)
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'timer';

-- Check column defaults
SELECT column_name, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'timer' AND column_name IN ('end_time', 'total_time');

-- View problematic timers
SELECT timer_id, start_time, end_time, 
       EXTRACT(EPOCH FROM (end_time - start_time)) as seconds_diff
FROM timer 
WHERE end_time IS NOT NULL 
  AND EXTRACT(EPOCH FROM (end_time - start_time)) < 10
ORDER BY start_time DESC;
```

### Step 3: Fix Bad Data

```sql
-- Reset incorrectly stopped timers
UPDATE timer 
SET end_time = NULL,
    total_time = NULL
WHERE end_time IS NOT NULL 
  AND EXTRACT(EPOCH FROM (end_time - start_time)) < 10;
```

### Step 4: Remove Unwanted Defaults (if found)

If Step 2 shows a default value on `end_time`:
```sql
ALTER TABLE timer ALTER COLUMN end_time DROP DEFAULT;
ALTER TABLE timer ALTER COLUMN total_time DROP DEFAULT;
```

### Step 5: Restart Backend Server

```bash
cd backend
npm run dev
```

## Testing the Fix

1. **Delete test timers** from database
2. **Start a new timer** in the app
3. **Check database immediately**:
   ```sql
   SELECT * FROM timer ORDER BY start_time DESC LIMIT 1;
   ```
   Expected:
   - `end_time` should be **NULL**
   - `total_time` should be **NULL**

4. **Let timer run** for 2-3 minutes
5. **Click "Stop Timer"**
6. **Check database again**:
   Expected:
   - `end_time` should be **current timestamp**
   - `total_time` should be **2 or 3** (minutes elapsed)

## Troubleshooting

### If `end_time` Still Sets Automatically

**Check for triggers**:
```sql
SELECT trigger_name, action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'timer';
```

**If trigger exists**, drop it:
```sql
DROP TRIGGER IF EXISTS [trigger_name] ON timer;
```

### If `total_time` Shows Wrong Value

**Check your calculation**:
```sql
SELECT 
  timer_id,
  start_time,
  end_time,
  total_time as stored_value,
  FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)) / 60) as calculated_minutes
FROM timer 
WHERE end_time IS NOT NULL
ORDER BY start_time DESC
LIMIT 5;
```

### Backend Not Starting?

Run error check:
```bash
cd backend
node src/server.js
```

Look for any syntax errors in the console.

## Expected Behavior Summary

| Event | duration | start_time | end_time | total_time |
|-------|----------|------------|----------|------------|
| **Timer Created** | 60 | 2026-02-09 15:00:00 | NULL | NULL |
| **Timer Running (30 min elapsed)** | 60 | 2026-02-09 15:00:00 | NULL | NULL |
| **Timer Stopped Early (30 min)** | 60 | 2026-02-09 15:00:00 | 2026-02-09 15:30:00 | 30 |
| **Timer Completed Full (60 min)** | 60 | 2026-02-09 15:00:00 | 2026-02-09 16:00:00 | 60 |

## Timezone Note

Times stored in UTC (e.g., 16:42) but your local time is UTC+6 (22:42). This is **normal** - the application converts to your timezone automatically.

The countdown works correctly regardless of timezone because it calculates elapsed seconds, not comparing clock times.
