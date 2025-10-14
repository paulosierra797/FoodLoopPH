-- Add profile_picture column to users table
ALTER TABLE users ADD COLUMN profile_picture TEXT;

-- Update the trigger to handle profile_picture updates
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';