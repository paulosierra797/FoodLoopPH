# ⚡ Quick Fix for "Could not find table public.food_listings" Error

## 🔴 The Problem
Your app shows: `PostgrestException(message: Could not find the table 'public.food_listings' in the schema cache, code: PGRST205)`

This happens because the `user_food_view` view exists but wasn't properly refreshed in Supabase's schema cache after you modified your tables.

## ✅ The Solution - Run This SQL in Supabase

### Step 1: Open SQL Editor
1. Go to https://supabase.com/dashboard
2. Select your **FoodLoopPH** project  
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Run This SQL

**Copy and paste this ENTIRE block** and click **Run** (or press Ctrl+Enter):

```sql
-- 1. Create validation trigger function
CREATE OR REPLACE FUNCTION check_user_exists_in_public()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = NEW.posted_by) THEN
        RAISE EXCEPTION 'User % does not exist in public.users. Cannot insert food listing.', NEW.posted_by;
    END IF;
    RETURN NEW;
END;
$$;

-- 2. Attach trigger to food_listings table
DROP TRIGGER IF EXISTS validate_user_exists ON public.food_listings;
CREATE TRIGGER validate_user_exists
    BEFORE INSERT ON public.food_listings
    FOR EACH ROW
    EXECUTE FUNCTION check_user_exists_in_public();

-- 3. Refresh the view with correct structure
DROP VIEW IF EXISTS public.user_food_view CASCADE;

CREATE VIEW public.user_food_view AS
SELECT 
    u.id AS user_id,
    u.email AS user_email,
    u.first_name,
    u.last_name,
    CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS user_name,
    f.id AS food_listing_id,
    f.title AS food_name,
    f.description,
    f.images,
    f.category,
    f.location,
    f.quantity,
    f.expiration_date,
    f.contact_number,
    f.is_urgent,
    f.status,
    f.posted_by,
    f.created_at
FROM public.users u
INNER JOIN public.food_listings f ON f.posted_by = u.id;

-- 4. Grant permissions
GRANT SELECT ON public.user_food_view TO authenticated;
GRANT SELECT ON public.user_food_view TO anon;
GRANT EXECUTE ON FUNCTION check_user_exists_in_public() TO authenticated;
GRANT EXECUTE ON FUNCTION check_user_exists_in_public() TO anon;

-- 5. Force schema cache reload
NOTIFY pgrst, 'reload schema';
```

### Step 3: Verify
You should see: **`Success. No rows returned`** ✅

### Step 4: Test the View
Run this to confirm the view works:
```sql
SELECT * FROM user_food_view LIMIT 5;
```

You should see your 5 food listings!

### Step 5: Test the Trigger (Optional)
To verify the validation trigger is working, run these tests:

**Test 1: Valid User (Should Work)**
```sql
-- This should succeed (replace with a real user ID from your users table)
INSERT INTO food_listings (title, description, posted_by, status) 
VALUES ('Test Food', 'Test Description', 
        (SELECT id FROM users LIMIT 1), 'available');

-- Clean up the test
DELETE FROM food_listings WHERE title = 'Test Food';
```

**Test 2: Invalid User (Should Fail)**
```sql
-- This should FAIL with our custom error message
INSERT INTO food_listings (title, description, posted_by, status) 
VALUES ('Test Food', 'Test Description', 
        '00000000-0000-0000-0000-000000000000'::uuid, 'available');
```

You should see: `ERROR: User 00000000-0000-0000-0000-000000000000 does not exist in public.users. Cannot insert food listing.`

### Step 6: Restart Flutter App
1. Stop your current Flutter app (Ctrl+C in terminal)
2. Run `flutter run` again
3. Navigate to the User Listings Analytics screen
4. ✅ Data should load without errors!

---

## 🎯 What This Does
- **Creates** a validation trigger to ensure users exist before adding listings
- **Drops** the old view that had schema issues
- **Creates** a new view matching your actual `food_listings` table structure  
- **Refreshes** Supabase's schema cache
- **Grants** permissions for your app to read the view and use the trigger

## 📊 Your Current Data
Based on your screenshot, you have 5 food listings:
- basura (Prepared Food)
- Fruits (Fresh Produce)  
- sadsa (Packaged Food)
- Food (Fresh Produce)
- food (Baked Goods)

All should appear in the app after this fix!
