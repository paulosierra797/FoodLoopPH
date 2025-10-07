-- Table to track which user claimed which food listing
CREATE TABLE IF NOT EXISTS food_claims (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES users(id) ON DELETE CASCADE,
    food_listing_id uuid REFERENCES food_listings(id) ON DELETE CASCADE,
    claimed_at timestamp with time zone DEFAULT now(),
    UNIQUE(user_id, food_listing_id)
);

-- Grant permissions
GRANT ALL ON TABLE food_claims TO authenticated;
