-- Add latitude and longitude columns to food_listings table
-- This will enable map functionality for food listings

-- Add latitude field to food_listings table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'food_listings' 
        AND column_name = 'latitude'
    ) THEN
        ALTER TABLE food_listings 
        ADD COLUMN latitude DECIMAL(10, 8);
        
        -- Add comment for clarity
        COMMENT ON COLUMN food_listings.latitude IS 'Latitude coordinate for map display';
    END IF;
END $$;

-- Add longitude field to food_listings table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'food_listings' 
        AND column_name = 'longitude'
    ) THEN
        ALTER TABLE food_listings 
        ADD COLUMN longitude DECIMAL(11, 8);
        
        -- Add comment for clarity
        COMMENT ON COLUMN food_listings.longitude IS 'Longitude coordinate for map display';
    END IF;
END $$;

-- Create an index for efficient spatial queries
CREATE INDEX IF NOT EXISTS idx_food_listings_coordinates 
ON food_listings (latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Function to get food listings within a radius (in kilometers)
CREATE OR REPLACE FUNCTION get_nearby_food_listings(
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 10,
    user_id UUID DEFAULT NULL
)
RETURNS TABLE(
    id UUID,
    title TEXT,
    description TEXT,
    category TEXT,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    quantity TEXT,
    posted_by UUID,
    poster_name TEXT,
    status TEXT,
    expiration_date TIMESTAMP WITH TIME ZONE,
    images TEXT[],
    contact_number TEXT,
    is_urgent BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    distance_km DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fl.id,
        fl.title,
        fl.description,
        fl.category,
        fl.location,
        fl.latitude,
        fl.longitude,
        fl.quantity,
        fl.posted_by,
        COALESCE(CONCAT(u.first_name, ' ', u.last_name), u.username, 'Anonymous User') as poster_name,
        fl.status,
        fl.expiration_date,
        fl.images,
        fl.contact_number,
        fl.is_urgent,
        fl.created_at,
        -- Calculate distance using Haversine formula
        ROUND(
            CAST(
                6371 * acos(
                    cos(radians(center_lat)) * 
                    cos(radians(fl.latitude)) * 
                    cos(radians(fl.longitude) - radians(center_lng)) + 
                    sin(radians(center_lat)) * 
                    sin(radians(fl.latitude))
                ) AS DECIMAL
            ), 2
        ) as distance_km
    FROM food_listings fl
    LEFT JOIN users u ON fl.posted_by = u.id
    WHERE fl.latitude IS NOT NULL 
    AND fl.longitude IS NOT NULL
    AND fl.status = 'available'
    AND (user_id IS NULL OR fl.posted_by != user_id) -- Don't show user's own listings
    AND (
        6371 * acos(
            cos(radians(center_lat)) * 
            cos(radians(fl.latitude)) * 
            cos(radians(fl.longitude) - radians(center_lng)) + 
            sin(radians(center_lat)) * 
            sin(radians(fl.latitude))
        )
    ) <= radius_km
    ORDER BY distance_km ASC;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_nearby_food_listings TO authenticated;

-- Update comment
COMMENT ON FUNCTION get_nearby_food_listings IS 'Get food listings within specified radius from a center point';