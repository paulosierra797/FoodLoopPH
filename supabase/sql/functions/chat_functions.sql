-- SQL functions for chat functionality
-- These functions help manage conversations and messages in the FoodLoopPH app

-- Drop existing functions first to avoid signature conflicts
DROP FUNCTION IF EXISTS get_user_conversations(uuid);
DROP FUNCTION IF EXISTS get_conversation_messages(uuid, uuid, uuid, integer, integer);
DROP FUNCTION IF EXISTS send_message(uuid, uuid, text, uuid);

-- Function to get user conversations with latest message info
CREATE OR REPLACE FUNCTION get_user_conversations(user_id uuid)
RETURNS TABLE (
    other_user_id uuid,
    other_user_name text,
    other_user_email text,
    listing_id uuid,
    listing_title text,
    last_message text,
    last_message_time timestamp,
    unread_count bigint
)
LANGUAGE plpgsql
SECURITY invoker
AS $$
BEGIN
    RETURN QUERY
    WITH conversation_partners AS (
        -- Get all unique conversation partners for this user
        SELECT DISTINCT
            CASE 
                WHEN cm.sender_id = user_id THEN cm.receiver_id
                ELSE cm.sender_id
            END as partner_id,
            cm.listing_id
        FROM chat_messages cm
        WHERE cm.sender_id = user_id OR cm.receiver_id = user_id
    ),
    latest_messages AS (
        -- Get the latest message for each conversation
        SELECT DISTINCT ON (
            CASE 
                WHEN cm.sender_id = user_id THEN cm.receiver_id
                ELSE cm.sender_id
            END,
            cm.listing_id
        )
        CASE 
            WHEN cm.sender_id = user_id THEN cm.receiver_id
            ELSE cm.sender_id
        END as partner_id,
        cm.listing_id,
        cm.message_text,
        cm."timestamp"
        FROM chat_messages cm
        WHERE cm.sender_id = user_id OR cm.receiver_id = user_id
        ORDER BY 
            CASE 
                WHEN cm.sender_id = user_id THEN cm.receiver_id
                ELSE cm.sender_id
            END,
            cm.listing_id,
            cm."timestamp" DESC
    ),
    unread_counts AS (
        -- Count unread messages for each conversation
        SELECT 
            cm.sender_id as partner_id,
            cm.listing_id,
            COUNT(*) as unread_count
        FROM chat_messages cm
        WHERE cm.receiver_id = user_id 
        AND cm."timestamp" > COALESCE(
            (SELECT last_read_at FROM user_chat_read_status 
             WHERE user_id_param = user_id 
             AND other_user_id = cm.sender_id 
             AND listing_id_param = cm.listing_id),
            '1970-01-01'::timestamp
        )
        GROUP BY cm.sender_id, cm.listing_id
    )
    SELECT 
        cp.partner_id,
        CONCAT(u.first_name, ' ', u.last_name) as other_user_name,
        u.email as other_user_email,
        cp.listing_id,
        fl.title as listing_title,
        COALESCE(lm.message_text, '') as last_message,
        COALESCE(lm."timestamp", NOW()) as last_message_time,
        COALESCE(uc.unread_count, 0) as unread_count
    FROM conversation_partners cp
    LEFT JOIN users u ON u.id = cp.partner_id
    LEFT JOIN food_listings fl ON fl.id = cp.listing_id
    LEFT JOIN latest_messages lm ON lm.partner_id = cp.partner_id AND lm.listing_id = cp.listing_id
    LEFT JOIN unread_counts uc ON uc.partner_id = cp.partner_id AND uc.listing_id = cp.listing_id
    ORDER BY COALESCE(lm."timestamp", NOW()) DESC;
END;
$$;

-- Function to get messages for a specific conversation
CREATE OR REPLACE FUNCTION get_conversation_messages(
    user_id uuid,
    other_user_id uuid,
    listing_id_param uuid DEFAULT NULL,
    limit_count integer DEFAULT 50,
    offset_count integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    sender_id uuid,
    receiver_id uuid,
    message_text text,
    "timestamp" timestamp,
    sender_name text,
    is_from_current_user boolean
)
LANGUAGE plpgsql
SECURITY invoker
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cm.id,
        cm.sender_id,
        cm.receiver_id,
        cm.message_text,
        cm."timestamp",
        CONCAT(u.first_name, ' ', u.last_name) as sender_name,
        (cm.sender_id = user_id) as is_from_current_user
    FROM chat_messages cm
    LEFT JOIN users u ON u.id = cm.sender_id
    WHERE (
        (cm.sender_id = user_id AND cm.receiver_id = other_user_id) OR
        (cm.sender_id = other_user_id AND cm.receiver_id = user_id)
    )
    AND (listing_id_param IS NULL OR cm.listing_id = listing_id_param)
    ORDER BY cm."timestamp" ASC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$;

-- Function to send a message
CREATE OR REPLACE FUNCTION send_message(
    sender_id uuid,
    receiver_id uuid,
    message_text text,
    listing_id_param uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY invoker
AS $$
DECLARE
    new_message_id uuid;
BEGIN
    -- Validate that sender exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = sender_id) THEN
        RAISE EXCEPTION 'Sender user does not exist';
    END IF;
    
    -- Validate that receiver exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = receiver_id) THEN
        RAISE EXCEPTION 'Receiver user does not exist';
    END IF;
    
    -- Validate listing if provided
    IF listing_id_param IS NOT NULL AND NOT EXISTS (SELECT 1 FROM food_listings WHERE id = listing_id_param) THEN
        RAISE EXCEPTION 'Food listing does not exist';
    END IF;
    
    -- Insert the message
    INSERT INTO chat_messages (sender_id, receiver_id, message_text, listing_id)
    VALUES (sender_id, receiver_id, message_text, listing_id_param)
    RETURNING id INTO new_message_id;
    
    RETURN new_message_id;
END;
$$;

-- Create table for tracking read status (optional - for unread count feature)
CREATE TABLE IF NOT EXISTS user_chat_read_status (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id_param uuid REFERENCES users(id) ON DELETE CASCADE,
    other_user_id uuid REFERENCES users(id) ON DELETE CASCADE,
    listing_id_param uuid REFERENCES food_listings(id) ON DELETE CASCADE,
    last_read_at timestamp DEFAULT NOW(),
    created_at timestamp DEFAULT NOW(),
    UNIQUE(user_id_param, other_user_id, listing_id_param)
);

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_conversations(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_conversation_messages(uuid, uuid, uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION send_message(uuid, uuid, text, uuid) TO authenticated;
GRANT ALL ON TABLE user_chat_read_status TO authenticated;