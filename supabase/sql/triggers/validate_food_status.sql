-- Food status validation trigger
-- Ensures valid status transitions and business rules

CREATE OR REPLACE FUNCTION validate_food_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Don't allow status change to 'available' if already claimed
    IF NEW.status = 'available' AND OLD.status = 'claimed' THEN
        RAISE EXCEPTION 'Cannot change status from claimed back to available. Food ID: %', NEW.id;
    END IF;
    
    -- Don't allow claimed_by to be set unless status is 'claimed'
    IF NEW.claimed_by IS NOT NULL AND NEW.status != 'claimed' THEN
        RAISE EXCEPTION 'claimed_by can only be set when status is claimed. Food ID: %', NEW.id;
    END IF;
    
    -- Don't allow empty claimed_by when status is 'claimed'
    IF NEW.status = 'claimed' AND NEW.claimed_by IS NULL THEN
        RAISE EXCEPTION 'claimed_by must be set when status is claimed. Food ID: %', NEW.id;
    END IF;
    
    -- Auto-set claimed_at when status changes to claimed
    IF NEW.status = 'claimed' AND OLD.status != 'claimed' THEN
        NEW.claimed_at = NOW();
    END IF;
    
    -- Clear claimed fields when status changes from claimed
    IF NEW.status != 'claimed' AND OLD.status = 'claimed' THEN
        NEW.claimed_by = NULL;
        NEW.claimed_at = NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_food_status ON food_listings;
CREATE TRIGGER validate_food_status
    BEFORE UPDATE ON food_listings
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status OR OLD.claimed_by IS DISTINCT FROM NEW.claimed_by)
    EXECUTE FUNCTION validate_food_status_change();

GRANT EXECUTE ON FUNCTION validate_food_status_change() TO authenticated;