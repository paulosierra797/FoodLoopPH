-- Master trigger deployment file
-- Run this file to deploy all triggers for FoodLoopPH

-- 1. Auto-update timestamps
\i 'triggers/auto_update_timestamps.sql'

-- 2. Validate user exists (already exists)
\i 'triggers/validate_user_exists.sql'

-- 3. Food status validation
\i 'triggers/validate_food_status.sql'

-- 4. Activity logging
\i 'triggers/activity_log.sql'

-- 5. Notifications
\i 'triggers/notifications.sql'

-- 6. Data cleanup
\i 'triggers/data_cleanup.sql'

-- Grant all necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Success message
SELECT 'All triggers deployed successfully!' as status;