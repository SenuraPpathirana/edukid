-- Add is_used column to email_verifications table if it doesn't exist
-- Run this in your Supabase SQL editor

ALTER TABLE email_verifications 
ADD COLUMN IF NOT EXISTS is_used BOOLEAN DEFAULT FALSE;

-- Optional: Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_email_verifications_parent_used 
ON email_verifications(user_id, is_used);

-- Optional: Add created_at column if it doesn't exist (for ordering)
ALTER TABLE email_verifications 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();

