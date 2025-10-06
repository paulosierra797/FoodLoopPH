# 🧪 How to Test Your Database Triggers & Views

## Quick Trigger Test (30 seconds)

### 1. Open Supabase SQL Editor
- Dashboard → Your Project → SQL Editor → New Query

### 2. Test Valid User Insert (Should Work)
```sql
-- Test with a real user from your database
INSERT INTO food_listings (
    title, 
    description, 
    posted_by, 
    status,
    category
) VALUES (
    'Test Food Item', 
    'This is a test listing', 
    (SELECT id FROM users LIMIT 1),  -- Uses first user in your table
    'available',
    'Test Category'
);

-- Verify it was inserted
SELECT * FROM food_listings WHERE title = 'Test Food Item';

-- Clean up
DELETE FROM food_listings WHERE title = 'Test Food Item';
```

**Expected Result:** ✅ Insert succeeds, you see the row, then it's deleted.

### 3. Test Invalid User Insert (Should Fail)
```sql
-- Test with fake user ID - this should trigger our validation
INSERT INTO food_listings (
    title, 
    description, 
    posted_by, 
    status
) VALUES (
    'This Should Fail', 
    'Invalid user test', 
    '00000000-0000-0000-0000-000000000000'::uuid,  -- Fake user ID
    'available'
);
```

**Expected Result:** ❌ Error message: 
```
ERROR: User 00000000-0000-0000-0000-000000000000 does not exist in public.users. Cannot insert food listing.
```

### 4. Test View Query
```sql
-- Test the updated view
SELECT 
    user_name,
    food_name,
    description,
    status,
    created_at
FROM user_food_view 
ORDER BY created_at DESC 
LIMIT 5;
```

**Expected Result:** ✅ Shows your 5 food listings with user names properly joined.

---

## Advanced Testing

### Check Trigger Exists
```sql
-- Verify trigger is attached to table
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'validate_user_exists';
```

**Expected Result:** Shows one row with trigger details.

### Check Function Exists
```sql
-- Verify function was created
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_name = 'check_user_exists_in_public';
```

**Expected Result:** Shows function details.

### Test Different Scenarios

**Test 1: NULL posted_by (Should Fail)**
```sql
INSERT INTO food_listings (title, description, posted_by) 
VALUES ('Test', 'Test', NULL);
```

**Test 2: Empty String posted_by (Should Fail)**
```sql
-- This will fail at UUID conversion level
INSERT INTO food_listings (title, description, posted_by) 
VALUES ('Test', 'Test', ''::uuid);
```

---

## In Your Flutter App

### How to See Trigger Working

1. **Try adding a food listing** in your app
2. **If you see any weird user-related errors**, the trigger caught an issue
3. **Check Flutter console** for database error messages

### Common Trigger Scenarios

| Scenario | What Happens | Trigger Response |
|----------|-------------|------------------|
| Valid user adds food | ✅ Insert succeeds | Trigger allows it |
| Deleted user tries to add food | ❌ Clear error | "User XYZ does not exist" |
| Corrupted user ID in app | ❌ Clear error | "User XYZ does not exist" |
| App bug with null user | ❌ Handled gracefully | Better error message |

---

## Troubleshooting

### If Trigger Isn't Working:
1. **Check if it exists:**
   ```sql
   SELECT * FROM information_schema.triggers 
   WHERE trigger_name = 'validate_user_exists';
   ```

2. **Re-run the deployment SQL** from QUICK_FIX.md

3. **Check permissions:**
   ```sql
   SELECT * FROM information_schema.routine_privileges 
   WHERE routine_name = 'check_user_exists_in_public';
   ```

### If View Isn't Working:
1. **Check if it exists:**
   ```sql
   SELECT * FROM information_schema.views 
   WHERE table_name = 'user_food_view';
   ```

2. **Test direct query:**
   ```sql
   SELECT COUNT(*) FROM user_food_view;
   ```

---

## Success Indicators ✅

- ✅ Valid inserts work normally
- ✅ Invalid inserts show clear error messages
- ✅ View returns data with proper joins
- ✅ Flutter app loads listings without schema errors
- ✅ No more PGRST205 errors in app console

**Your database is properly protected and your app should work smoothly!** 🚀