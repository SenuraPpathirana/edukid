-- Migration: Rename parent table to user and parent_id to user_id
-- Date: 2026-01-27
-- Description: Renames all parent references to user throughout the database

-- 1. Rename the parent table to user
ALTER TABLE parent RENAME TO "user";

-- 2. Rename parent_id column to user_id in the user table
ALTER TABLE "user" RENAME COLUMN parent_id TO user_id;

-- 3. Update email_verifications table
ALTER TABLE email_verifications RENAME COLUMN parent_id TO user_id;

-- 4. Update password_reset_otps table (if exists)
ALTER TABLE password_reset_otps RENAME COLUMN parent_id TO user_id;

-- 5. Update admin_requests table
ALTER TABLE admin_requests RENAME COLUMN user_id TO user_id; -- Already correct, keeping for reference

-- 6. Rename indexes
DROP INDEX IF EXISTS idx_password_reset_otps_parent_id;
CREATE INDEX idx_password_reset_otps_user_id ON password_reset_otps(user_id);

DROP INDEX IF EXISTS email_verifications_parent_id_is_used_idx;
CREATE INDEX email_verifications_user_id_is_used_idx ON email_verifications(user_id, is_used);

-- 7. Update foreign key constraints
-- Note: Supabase/PostgreSQL will automatically update FK references when renaming columns
-- The foreign key constraint names will remain the same but reference the new column names

-- Verify the changes
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('user', 'email_verifications', 'password_reset_otps', 'admin_requests')
    AND column_name LIKE '%user_id%'
ORDER BY table_name, ordinal_position;
