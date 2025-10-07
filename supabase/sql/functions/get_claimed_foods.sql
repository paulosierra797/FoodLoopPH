-- Returns all foods claimed by a user, with poster info

CREATE OR REPLACE FUNCTION get_claimed_foods(user_id uuid)
RETURNS TABLE (
    food_listing_id uuid,
    title text,
    poster_id uuid,
    poster_name text,
    poster_email text,
    claimed_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        fl.id as food_listing_id,
        fl.title,
        u.id as poster_id,
        CONCAT(u.first_name, ' ', u.last_name) as poster_name,
        u.email as poster_email,
        fc.claimed_at
    FROM food_claims fc
    JOIN food_listings fl ON fl.id = fc.food_listing_id
    JOIN users u ON u.id = fl.posted_by
    WHERE fc.user_id = get_claimed_foods.user_id
    ORDER BY fc.claimed_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_claimed_foods(uuid) TO authenticated;
