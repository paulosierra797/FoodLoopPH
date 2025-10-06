# Deploy SQL to Supabase

## Problem
The app is getting errors because the required SQL views and functions haven't been deployed to your Supabase project yet.

## Quick Fix: Deploy Required SQL

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your FoodLoopPH project
3. Click on **SQL Editor** in the left sidebar

### Step 2: Deploy the View (REQUIRED - Do This First!)
1. Click **New Query**
2. Copy the entire contents of `supabase/sql/views/user_food_view.sql`
3. Paste into the SQL editor
4. Click **Run** (or press Ctrl+Enter)
5. You should see: `Success. No rows returned`

### Step 3: Deploy the Functions (OPTIONAL - For Advanced Features)
1. Click **New Query** again
2. Copy the entire contents of `supabase/sql/functions/get_user_food_listings.sql`
3. Paste into the SQL editor
4. Click **Run**
5. You should see: `Success. No rows returned`

### Step 3: Verify Deployment
Run this test query in the SQL editor to verify the view works:
```sql
SELECT * FROM user_food_view LIMIT 5;
```

If you see data returned (or "No rows" if you have no listings yet), it's working!

Optionally test the function:
```sql
SELECT * FROM get_user_food_listings(
  p_posted_by := NULL,
  p_status := 'available',
  p_limit := 10,
  p_offset := 0);
```

### Step 5: Restart Your Flutter App
1. Stop the current `flutter run` session (Ctrl+C in terminal)
2. Run `flutter run` again
3. The 404 errors should be gone

## Alternative: Keep Using VIEW Mode
If you prefer not to deploy the SQL function right now:
- The app is now defaulting to **VIEW mode** which queries `user_food_view` directly
- This will work without deploying the SQL function
- You can toggle between modes using the button in the app bar
- VIEW mode may have limited filtering options compared to the function

## Which Should You Use?

### Use VIEW Mode when:
- You want simple, direct queries
- You don't need complex filtering
- You want faster initial setup

### Use FUNCTION Mode when:
- You need server-side filtering and pagination
- You want better performance with large datasets
- You need role-based access control (the `get_my_food_listings` wrapper)

## Current Status
✅ App updated to default to VIEW mode (no 404 errors)
❌ SQL function not yet deployed to Supabase
🔧 You can deploy anytime by following the steps above
