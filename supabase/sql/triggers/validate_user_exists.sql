-- Trigger function to validate user exists before inserting food listing
-- This provides better error messages than just relying on foreign key constraint
-- Apply in your Supabase project's SQL editor.

-- Create the trigger function
CREATE OR REPLACE FUNCTION check_user_exists_in_public()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = NEW.posted_by) THEN
        RAISE EXCEPTION 'User % does not exist in public.users. Cannot insert food listing.', NEW.posted_by;
    END IF;
    RETURN NEW;
END;
$$;

-- Drop the trigger if it already exists (to allow re-running this script)
DROP TRIGGER IF EXISTS validate_user_exists ON public.food_listings;

-- Create the trigger on food_listings table
CREATE TRIGGER validate_user_exists
    BEFORE INSERT ON public.food_listings
    FOR EACH ROW
    EXECUTE FUNCTION check_user_exists_in_public();

-- Grant execute permission
GRANT EXECUTE ON FUNCTION check_user_exists_in_public() TO authenticated;
GRANT EXECUTE ON FUNCTION check_user_exists_in_public() TO anon;
