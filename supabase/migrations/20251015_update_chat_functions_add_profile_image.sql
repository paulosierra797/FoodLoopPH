-- Update get_conversation_messages function to include sender profile image
-- This fixes the issue where profile pictures don't show in chat message bubbles

-- Drop and recreate the function with profile_picture field
DROP FUNCTION IF EXISTS get_conversation_messages(uuid, uuid, uuid, integer, integer);

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
    sender_profile_image text,
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
        u.profile_picture as sender_profile_image,
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

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_conversation_messages(uuid, uuid, uuid, integer, integer) TO authenticated;