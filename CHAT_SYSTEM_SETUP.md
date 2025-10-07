# Chat System Setup Guide for FoodLoopPH

## Overview
Your FoodLoopPH app now has a fully functional chat system that allows users to communicate with each other about food listings. This guide explains how to set up and deploy the chat functionality.

## Components Created

### 1. Database Functions (SQL)
**File**: `supabase/sql/functions/chat_functions.sql`

This file contains three main functions:

1. **`get_user_conversations(user_id)`**: Returns all conversations for a user with latest message info
2. **`get_conversation_messages(user_id, other_user_id, listing_id, limit, offset)`**: Gets messages between two users
3. **`send_message(sender_id, receiver_id, message_text, listing_id)`**: Sends a new message

Also creates an optional `user_chat_read_status` table for tracking unread messages.

### 2. Chat List Page
**File**: `lib/screens/chat_list_page.dart`

- Shows all conversations for the current user
- Displays latest messages and unread counts
- Includes search functionality
- Pulls data from `get_user_conversations` function
- Navigates to individual chat page when tapped

### 3. Individual Chat Page  
**File**: `lib/screens/chat_page.dart`

- Shows messages between two users
- Real-time message updates using Supabase realtime
- Send new messages functionality
- Connected to `get_conversation_messages` and `send_message` functions
- Proper UI for message bubbles and input

## Deployment Steps

### Step 1: Deploy SQL Functions
1. Open your Supabase dashboard
2. Go to the SQL Editor
3. Copy and paste the contents of `supabase/sql/functions/chat_functions.sql`
4. Run the SQL to create all functions and tables

### Step 2: Test the Functions
Run these test queries in Supabase SQL Editor:

```sql
-- Test get_user_conversations (replace with actual user ID)
SELECT * FROM get_user_conversations('your-user-id-here');

-- Test sending a message (replace with actual user IDs)
SELECT send_message(
    'sender-user-id',
    'receiver-user-id', 
    'Hello! Is this food still available?',
    'listing-id-or-null'
);

-- Test get_conversation_messages
SELECT * FROM get_conversation_messages(
    'user-id',
    'other-user-id',
    null, -- listing_id (optional)
    20,   -- limit
    0     -- offset
);
```

### Step 3: Enable Realtime (Optional)
For real-time message updates:

1. In Supabase Dashboard, go to Database > Replication
2. Enable replication for the `chat_messages` table
3. Make sure your RLS policies allow users to see their own messages

### Step 4: Set Up Row Level Security (RLS)
Add these RLS policies to your `chat_messages` table:

```sql
-- Policy for users to see messages they sent or received
CREATE POLICY "Users can view their messages" ON chat_messages
FOR SELECT USING (
    auth.uid() = sender_id OR 
    auth.uid() = receiver_id
);

-- Policy for users to send messages
CREATE POLICY "Users can send messages" ON chat_messages
FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (SELECT 1 FROM users WHERE id = sender_id) AND
    EXISTS (SELECT 1 FROM users WHERE id = receiver_id)
);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
```

## How to Use in Your App

### From Food Listings
When viewing a food listing, users can click a "Contact Seller" button that navigates to:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(
      otherUserId: listing.postedBy, // seller's user ID
      otherUserName: sellerName,     // seller's display name
      listingId: listing.id,         // food listing ID
      listingTitle: listing.title,   // food listing title
    ),
  ),
);
```

### From Main Navigation
The chat list is already integrated into your main navigation. Users can see all their conversations from the chat tab.

## Key Features

✅ **Real-time messaging**: Messages appear instantly using Supabase realtime
✅ **Conversation context**: Messages are linked to specific food listings
✅ **User-friendly UI**: Clean message bubbles with timestamps
✅ **Search functionality**: Users can search their conversations
✅ **Unread message counts**: Shows number of unread messages per conversation
✅ **Loading states**: Proper loading indicators while sending messages
✅ **Error handling**: Graceful error handling with user feedback

## Database Schema Requirements

Your existing tables should already be compatible. The chat system uses:

- `users` table (for user information)
- `food_listings` table (for listing context)
- `chat_messages` table (created by the SQL file)

## Testing the Chat System

1. **Create test users**: Make sure you have at least 2 user accounts
2. **Create a food listing**: Post a food listing from one account
3. **Start a conversation**: From another account, navigate to chat with the listing owner
4. **Send messages**: Test sending messages back and forth
5. **Check realtime**: Open the chat on both devices to see real-time updates
6. **Test navigation**: Verify chat list shows conversations correctly

## Troubleshooting

### Common Issues

**"Function get_user_conversations not found"**
- Make sure you ran the SQL file in Supabase
- Check the function exists in Database > Functions

**"RPC call failed"**
- Verify RLS policies allow the current user to access the data
- Check that user IDs exist in the users table

**Messages not appearing in real-time**
- Ensure realtime replication is enabled for chat_messages table
- Check browser console for WebSocket connection errors

**"Cannot send message"** 
- Verify both sender and receiver exist in users table
- Check RLS policies allow INSERT for the current user

### Debugging Queries

```sql
-- Check if functions exist
SELECT proname FROM pg_proc WHERE proname LIKE '%chat%' OR proname LIKE '%conversation%';

-- Check recent messages
SELECT * FROM chat_messages ORDER BY timestamp DESC LIMIT 10;

-- Check user conversations manually
SELECT DISTINCT sender_id, receiver_id FROM chat_messages WHERE sender_id = 'user-id' OR receiver_id = 'user-id';
```

## Next Steps

Consider adding these enhancements:
- Message attachments (photos)
- Message status indicators (delivered, read)
- Push notifications for new messages
- Conversation archiving/deletion
- Emoji reactions
- Voice messages
- Block/report functionality

## Support

If you encounter issues:
1. Check Supabase logs in Dashboard > Logs
2. Verify all SQL functions are deployed correctly
3. Test with simple RPC calls in SQL Editor
4. Check Flutter logs for detailed error messages

Your chat system is now ready to help users connect and share food in your community! 🎉