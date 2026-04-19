-- Create child_profiles table for storing kid profiles
-- Run this SQL in your Supabase SQL editor

CREATE TABLE IF NOT EXISTS child_profiles (
  child_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  grade INTEGER NOT NULL CHECK (grade >= 1 AND grade <= 5),
  age INTEGER NOT NULL CHECK (age >= 1 AND age <= 18),
  gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster parent lookups
CREATE INDEX IF NOT EXISTS idx_child_profiles_parent 
ON child_profiles(parent_id);

-- Create index for gender filtering
CREATE INDEX IF NOT EXISTS idx_child_profiles_gender 
ON child_profiles(gender);

-- Create trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_child_profile_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_child_profile_timestamp
BEFORE UPDATE ON child_profiles
FOR EACH ROW
EXECUTE FUNCTION update_child_profile_timestamp();

-- Optional: Add Row Level Security (RLS) policies
ALTER TABLE child_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own children's profiles
CREATE POLICY "Users can view their own children"
ON child_profiles FOR SELECT
USING (parent_id = auth.uid());

-- Policy: Users can only insert profiles for themselves
CREATE POLICY "Users can insert their own children"
ON child_profiles FOR INSERT
WITH CHECK (parent_id = auth.uid());

-- Policy: Users can only update their own children's profiles
CREATE POLICY "Users can update their own children"
ON child_profiles FOR UPDATE
USING (parent_id = auth.uid());

-- Policy: Users can only delete their own children's profiles
CREATE POLICY "Users can delete their own children"
ON child_profiles FOR DELETE
USING (parent_id = auth.uid());
