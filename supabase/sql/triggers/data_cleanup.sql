-- Data cleanup trigger
-- Automatically cleans up related data when records are deleted

CREATE OR REPLACE FUNCTION cleanup_related_data()
RETURNS TRIGGER AS $$
BEGIN
    -- When a food listing is deleted, clean up related data
    IF TG_TABLE_NAME = 'food_listings' THEN
        -- Delete related chat messages
        DELETE FROM chat_messages WHERE listing_id = OLD.id;
        
        -- Delete related food claims
        DELETE FROM food_claims WHERE food_listing_id = OLD.id;
        
        -- Delete related notifications
        DELETE FROM notifications WHERE related_id = OLD.id AND type IN ('food_claimed', 'food_expiring');
        
        -- Delete related activity logs (optional - you might want to keep these for audit)
        -- DELETE FROM activity_log WHERE record_id = OLD.id AND table_name = 'food_listings';
    END IF;
    
    -- When a user is deleted, clean up their data
    IF TG_TABLE_NAME = 'users' THEN
        -- Delete their food listings (this will cascade to other cleanups)
        DELETE FROM food_listings WHERE posted_by = OLD.id;
        
        -- Delete their chat messages
        DELETE FROM chat_messages WHERE sender_id = OLD.id OR receiver_id = OLD.id;
        
        -- Delete their notifications
        DELETE FROM notifications WHERE user_id = OLD.id;
        
        -- Delete their food claims
        DELETE FROM food_claims WHERE user_id = OLD.id;
        
        -- Delete their activity logs
        DELETE FROM activity_log WHERE user_id = OLD.id;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Apply to food_listings table
DROP TRIGGER IF EXISTS cleanup_food_listings ON food_listings;
CREATE TRIGGER cleanup_food_listings
    BEFORE DELETE ON food_listings
    FOR EACH ROW
    EXECUTE FUNCTION cleanup_related_data();

-- Apply to users table (be careful with this one!)
-- DROP TRIGGER IF EXISTS cleanup_users ON users;
-- CREATE TRIGGER cleanup_users
--     BEFORE DELETE ON users
--     FOR EACH ROW
--     EXECUTE FUNCTION cleanup_related_data();

GRANT EXECUTE ON FUNCTION cleanup_related_data() TO authenticated;