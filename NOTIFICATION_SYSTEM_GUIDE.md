# 🔔 FoodLoop Notification System

This document explains how the notification system works in FoodLoop PH, specifically for notifying donors when their food has been claimed.

## 📋 Overview

The notification system consists of:
1. **Database Notifications** - Stored in the `notifications` table
2. **Real-time Updates** - Using Supabase real-time subscriptions
3. **Push Notifications** - Local notifications using Flutter Local Notifications
4. **UI Components** - Notification dropdown and dedicated notification page

## 🏗️ System Architecture

### Database Structure

The `notifications` table contains:
```sql
CREATE TABLE notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'food_claimed', 'new_message', 'food_expired', etc.
    related_id UUID, -- ID of related record (food_listing, chat_message, etc.)
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Automatic Triggers

Database triggers automatically create notifications when:
- Food status changes to 'claimed' → Creates notification for donor
- New chat message is sent → Creates notification for receiver
- Food is about to expire → Creates notification for donor

## 🚀 Key Features

### 1. **Automatic Donor Notifications**
When someone claims food, the donor automatically receives:
- Database notification in the `notifications` table
- Real-time UI update (notification badge and dropdown)
- Local push notification (if enabled in settings)

### 2. **Real-time UI Updates**
- Notification badge shows unread count
- Notification dropdown shows recent notifications
- Auto-refresh when new notifications arrive

### 3. **Interactive Notifications**
- Tap to mark as read
- Swipe to dismiss/delete
- "Mark all as read" functionality

## 📱 UI Components

### Notification Badge (Main Navigation)
- Shows unread notification count
- Updates in real-time
- Located in the top app bar

### Notification Dropdown
- Shows 3 most recent notifications
- Appears when tapping the notification bell
- Click notification to mark as read

### Notification Page
- Full list of all notifications
- Swipe to delete notifications
- Mark all as read functionality
- Different icons for different notification types

## 🔧 Implementation Details

### Core Files

1. **Providers**
   - `lib/providers/notifications_provider.dart` - Fetches notifications from database
   - `lib/providers/user_service_provider.dart` - User authentication

2. **Services**
   - `lib/services/notification_service.dart` - Local push notifications
   - `lib/services/database_notification_service.dart` - Database operations
   - `lib/services/notification_test_service.dart` - Testing utilities

3. **UI Components**
   - `lib/screens/main_navigation_screen.dart` - Main notification badge and dropdown
   - `lib/screens/notification_page.dart` - Full notification list page

4. **Database**
   - `supabase/sql/triggers/notifications.sql` - Auto-notification triggers
   - `supabase/sql/tables/notifications.sql` - Notification table schema

### How Food Claim Notifications Work

1. **User claims food** in explore page
2. **Database trigger fires** when `food_listings.status` changes to 'claimed'
3. **Notification created** in `notifications` table for the donor
4. **UI updates** via Riverpod state management
5. **Push notification sent** via Flutter Local Notifications (if enabled)

## 🧪 Testing the System

### Using the Test Service

```dart
import '../services/notification_test_service.dart';

// Create sample notifications for testing
final testService = NotificationTestService();

// Test food claimed notification
await testService.createSampleFoodClaimedNotification();

// Test message notification  
await testService.createSampleMessageNotification();

// Test food expiring notification
await testService.createSampleFoodExpiringNotification();

// Create all sample notifications
await testService.createAllSampleNotifications();

// Clear all notifications (for testing)
await testService.clearAllNotifications();
```

### Manual Testing Steps

1. **Setup Two Accounts**
   - Create two user accounts (Donor & Claimer)
   - Login as Donor, post a food item
   - Switch to Claimer account

2. **Test Food Claim**
   - As Claimer: Find and claim the food item
   - Switch back to Donor account
   - Check notification badge (should show "1")
   - Tap notification bell to see dropdown
   - Navigate to notification page to see full details

3. **Test Interactions**
   - Tap notification to mark as read
   - Swipe notification to delete
   - Test "Mark all as read" button

### Database Testing

You can also test by directly inserting into the database:

```sql
-- Create a test notification for a specific user
INSERT INTO notifications (user_id, title, message, type, is_read)
VALUES (
    'user-id-here',
    'Test Notification',
    'This is a test notification message',
    'food_claimed',
    false
);
```

## 🎯 Notification Types

| Type | Icon | Description |
|------|------|-------------|
| `food_claimed` | 🍽️ (restaurant) | When donor's food is claimed |
| `new_message` | 💬 (chat_bubble) | New chat message received |
| `food_expiring` | ⏰ (schedule) | Food expires within 24 hours |
| `welcome` | 👋 (waving_hand) | Welcome message for new users |
| `update` | ℹ️ (info) | App updates and announcements |

## 🔔 Push Notification Settings

Users can control notifications via:
- Settings → Notification Settings
- Toggle for "Food Claim Updates"
- Individual notification type controls

## 🐛 Troubleshooting

### Notifications Not Showing Up

1. **Check Database Triggers**
   ```sql
   -- Verify trigger exists
   SELECT * FROM pg_trigger WHERE tgname = 'create_food_notifications';
   ```

2. **Check Table Permissions**
   ```sql
   -- Verify notifications table permissions
   SELECT * FROM information_schema.table_privileges 
   WHERE table_name = 'notifications';
   ```

3. **Check User Authentication**
   - Ensure user is properly authenticated
   - Verify user ID in `supabase.auth.currentUser`

4. **Check Provider Updates**
   - Ensure `notificationsProvider` is being watched
   - Verify `ref.invalidate()` calls after operations

### Common Issues

- **Trigger not firing**: Check if notification trigger is deployed
- **UI not updating**: Verify Riverpod provider invalidation
- **Permissions error**: Check Supabase RLS policies for notifications table
- **Push notifications not working**: Verify notification service initialization

## 📚 Future Enhancements

- Real-time WebSocket notifications
- Email notifications for important updates
- Notification categories and filtering
- Notification scheduling for reminders
- Rich notifications with images and actions

## 🤝 Contributing

When adding new notification types:
1. Add the type to the database trigger
2. Update the notification icon mapping
3. Add appropriate test cases
4. Update this documentation

---

**Happy coding! 🚀** 

For questions about the notification system, please refer to this documentation or check the implementation in the source files listed above.