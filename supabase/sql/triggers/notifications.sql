-- Notification trigger
-- Automatically creates notifications for important events

-- Create notifications table if it doesn't exist
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'food_claimed', 'new_message', 'food_expired', etc.
    related_id UUID, -- ID of related record (food_listing, chat_message, etc.)
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create notification function
CREATE OR REPLACE FUNCTION create_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- When food is claimed, notify the poster
    IF TG_TABLE_NAME = 'food_listings' AND TG_OP = 'UPDATE' THEN
        IF NEW.status = 'claimed' AND OLD.status != 'claimed' THEN
            INSERT INTO notifications (user_id, title, message, type, related_id)
            SELECT 
                NEW.posted_by,
                'Food Item Claimed!',
                'Your food listing "' || NEW.title || '" has been claimed.',
                'food_claimed',
                NEW.id
            WHERE NEW.posted_by != NEW.claimed_by; -- Don't notify if user claimed their own food
        END IF;
    END IF;
    
    -- When new chat message is sent, notify the receiver
    IF TG_TABLE_NAME = 'chat_messages' AND TG_OP = 'INSERT' THEN
        INSERT INTO notifications (user_id, title, message, type, related_id)
        VALUES (
            NEW.receiver_id,
            'New Message',
            'You have a new message from ' || (
                SELECT COALESCE(CONCAT(first_name, ' ', last_name), email) 
                FROM users 
                WHERE id = NEW.sender_id
            ),
            'new_message',
            NEW.id
        );
    END IF;
    
    -- When food listing expires soon (you can add this logic)
    IF TG_TABLE_NAME = 'food_listings' AND TG_OP = 'UPDATE' THEN
        IF NEW.expiration_date <= (NOW() + INTERVAL '1 day') AND 
           (OLD.expiration_date > (NOW() + INTERVAL '1 day') OR OLD.expiration_date IS NULL) AND
           NEW.status = 'available' THEN
            INSERT INTO notifications (user_id, title, message, type, related_id)
            VALUES (
                NEW.posted_by,
                'Food Expiring Soon',
                'Your food listing "' || NEW.title || '" expires within 24 hours.',
                'food_expiring',
                NEW.id
            );
        END IF;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply to food_listings table
DROP TRIGGER IF EXISTS create_food_notifications ON food_listings;
CREATE TRIGGER create_food_notifications
    AFTER UPDATE ON food_listings
    FOR EACH ROW
    EXECUTE FUNCTION create_notifications();

-- Apply to chat_messages table
DROP TRIGGER IF EXISTS create_message_notifications ON chat_messages;
CREATE TRIGGER create_message_notifications
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION create_notifications();

-- Grant permissions
GRANT ALL ON TABLE notifications TO authenticated;
GRANT EXECUTE ON FUNCTION create_notifications() TO authenticated;