-- Activity logging trigger
-- Logs important activities for analytics and auditing

-- Create activity_log table if it doesn't exist
CREATE TABLE IF NOT EXISTS activity_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the logging function
CREATE OR REPLACE FUNCTION log_activity()
RETURNS TRIGGER AS $$
DECLARE
    user_id_val UUID;
    action_val VARCHAR(50);
BEGIN
    -- Get current user ID
    user_id_val := auth.uid();
    
    -- Determine action type
    IF TG_OP = 'INSERT' THEN
        action_val := 'CREATE';
        INSERT INTO activity_log (user_id, action, table_name, record_id, new_values)
        VALUES (user_id_val, action_val, TG_TABLE_NAME, NEW.id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        action_val := 'UPDATE';
        INSERT INTO activity_log (user_id, action, table_name, record_id, old_values, new_values)
        VALUES (user_id_val, action_val, TG_TABLE_NAME, NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        action_val := 'DELETE';
        INSERT INTO activity_log (user_id, action, table_name, record_id, old_values)
        VALUES (user_id_val, action_val, TG_TABLE_NAME, OLD.id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply to food_listings table
DROP TRIGGER IF EXISTS log_food_listings_activity ON food_listings;
CREATE TRIGGER log_food_listings_activity
    AFTER INSERT OR UPDATE OR DELETE ON food_listings
    FOR EACH ROW
    EXECUTE FUNCTION log_activity();

-- Apply to food_claims table (if it exists)
DROP TRIGGER IF EXISTS log_food_claims_activity ON food_claims;
CREATE TRIGGER log_food_claims_activity
    AFTER INSERT OR UPDATE OR DELETE ON food_claims
    FOR EACH ROW
    EXECUTE FUNCTION log_activity();

-- Grant permissions
GRANT ALL ON TABLE activity_log TO authenticated;
GRANT EXECUTE ON FUNCTION log_activity() TO authenticated;