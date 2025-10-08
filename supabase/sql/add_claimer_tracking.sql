-- Add claimer tracking to food_listings table
-- This will allow us to track who claimed each food item

-- Add claimed_by field to food_listings table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'food_listings' 
        AND column_name = 'claimed_by'
    ) THEN
        ALTER TABLE food_listings 
        ADD COLUMN claimed_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Add claimed_at field to track when the item was claimed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'food_listings' 
        AND column_name = 'claimed_at'
    ) THEN
        ALTER TABLE food_listings 
        ADD COLUMN claimed_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Function to claim a food item
CREATE OR REPLACE FUNCTION claim_food_item(
    food_id UUID,
    claimer_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update the food listing to mark it as claimed
    UPDATE food_listings 
    SET 
        status = 'claimed',
        claimed_by = claimer_id,
        claimed_at = NOW()
    WHERE 
        id = food_id 
        AND status = 'available'
        AND posted_by != claimer_id; -- Can't claim your own food
    
    -- Return true if a row was updated
    RETURN FOUND;
END;
$$;

-- Function to get claimer information for a listing
CREATE OR REPLACE FUNCTION get_listing_claimer(listing_id UUID)
RETURNS TABLE(
    claimer_id UUID,
    claimer_name TEXT,
    claimer_email TEXT,
    claimed_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fl.claimed_by as claimer_id,
        COALESCE(CONCAT(u.first_name, ' ', u.last_name), 'Unknown User') as claimer_name,
        u.email as claimer_email,
        fl.claimed_at
    FROM food_listings fl
    LEFT JOIN users u ON fl.claimed_by = u.id
    WHERE fl.id = listing_id
    AND fl.status = 'claimed';
END;
$$;

-- Drop existing function and create enhanced version
DROP FUNCTION IF EXISTS get_claimed_foods(uuid);

-- Function to get foods claimed by a user (enhanced version)
CREATE OR REPLACE FUNCTION get_claimed_foods(user_id UUID)
RETURNS TABLE(
    food_listing_id UUID,
    title TEXT,
    description TEXT,
    poster_id UUID,
    poster_name TEXT,
    claimed_at TIMESTAMP WITH TIME ZONE,
    location TEXT,
    category TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fl.id as food_listing_id,
        fl.title,
        fl.description,
        fl.posted_by as poster_id,
        COALESCE(CONCAT(u.first_name, ' ', u.last_name), 'Unknown User') as poster_name,
        fl.claimed_at,
        fl.location,
        fl.category
    FROM food_listings fl
    LEFT JOIN users u ON fl.posted_by = u.id
    WHERE fl.claimed_by = user_id
    AND fl.status = 'claimed'
    ORDER BY fl.claimed_at DESC;
END;
$$;

-- Update existing claimed foods to populate the claimed_by field
UPDATE food_listings 
SET 
    claimed_by = fc.user_id,
    claimed_at = fc.claimed_at
FROM food_claims fc
WHERE food_listings.id = fc.food_listing_id 
AND food_listings.status = 'claimed'
AND food_listings.claimed_by IS NULL;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION claim_food_item TO authenticated;
GRANT EXECUTE ON FUNCTION get_listing_claimer TO authenticated;
GRANT EXECUTE ON FUNCTION get_claimed_foods TO authenticated;