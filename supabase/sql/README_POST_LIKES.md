# Post Likes Table Setup

This document explains how to set up the `post_likes` table for the community page likes feature.

## What It Does

The `post_likes` table tracks which users liked which community posts, enabling:
- ✅ Persistent likes that survive app restarts
- ✅ Real-time like counts visible to all users
- ✅ Individual user like tracking (you can see which posts YOU liked)
- ✅ Social engagement metrics

## Database Schema

```sql
CREATE TABLE post_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamp DEFAULT now(),
  UNIQUE(post_id, user_id)
);
```

## How to Deploy

### Option 1: Using Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy and paste the contents of `create_post_likes_table.sql`
5. Click **Run** or press `Ctrl+Enter`
6. Verify success (you should see "Success. No rows returned")

### Option 2: Using Supabase CLI

```bash
# Navigate to your project directory
cd C:\Users\Paulo\Documents\FoodLoopPH

# Run the SQL file
supabase db execute -f supabase/sql/create_post_likes_table.sql
```

## Verification

After running the SQL, verify the table was created:

1. In Supabase Dashboard, go to **Table Editor**
2. You should see `post_likes` in the tables list
3. Click on it to view the structure

Or run this SQL query:

```sql
SELECT * FROM information_schema.tables 
WHERE table_name = 'post_likes';
```

## Features Included

### Row Level Security (RLS)
- ✅ All users can view likes (for like counts)
- ✅ Users can only add their own likes
- ✅ Users can only remove their own likes

### Indexes
- Index on `post_id` for fast like count queries
- Index on `user_id` for fast user-specific queries

### Constraints
- Unique constraint on `(post_id, user_id)` prevents duplicate likes
- Foreign key cascades ensure data integrity

## Testing

After deployment, test the feature:

1. Run the Flutter app
2. Go to Community page
3. Click the like button on a post
4. Close and reopen the app
5. The like should still be there! ✅

## Troubleshooting

**Error: relation "post_likes" already exists**
- The table is already created, you're good to go!

**Error: relation "community_posts" does not exist**
- Make sure your `community_posts` table exists first

**Likes not persisting**
- Check Supabase logs in the Dashboard
- Verify RLS policies are active
- Ensure the user is authenticated

## Support

If you encounter any issues, check:
- Supabase Dashboard > Database > Tables
- Supabase Dashboard > Authentication > Policies
- Flutter console for error messages
