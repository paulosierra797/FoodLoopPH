import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_notification_service.dart';

/// Service for testing and demonstrating the notification system
class NotificationTestService {
  static final NotificationTestService _instance = NotificationTestService._internal();
  factory NotificationTestService() => _instance;
  NotificationTestService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseNotificationService _dbNotificationService = DatabaseNotificationService();

  /// Create a sample food claimed notification for testing
  Future<void> createSampleFoodClaimedNotification({
    String? customFoodName,
    String? customClaimerName,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in - cannot create test notification');
      return;
    }

    try {
      final foodName = customFoodName ?? 'Fresh Pizza';
      final claimerName = customClaimerName ?? 'Test User';
      
      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': 'Food Item Claimed! 🎉',
        'message': '$claimerName has claimed your "$foodName"',
        'type': 'food_claimed',
        'related_id': null, // No specific food listing for test
        'is_read': false,
      });

      debugPrint('✅ Sample food claimed notification created successfully');
    } catch (e) {
      debugPrint('❌ Error creating sample notification: $e');
    }
  }

  /// Create a sample new message notification for testing
  Future<void> createSampleMessageNotification({
    String? customSenderName,
    String? customMessage,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in - cannot create test notification');
      return;
    }

    try {
      final senderName = customSenderName ?? 'John Doe';
      final message = customMessage ?? 'Hi! The food is ready for pickup.';
      
      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': 'New Message 💬',
        'message': '$senderName: $message',
        'type': 'new_message',
        'related_id': null,
        'is_read': false,
      });

      debugPrint('✅ Sample message notification created successfully');
    } catch (e) {
      debugPrint('❌ Error creating sample notification: $e');
    }
  }

  /// Create a sample food expiring notification for testing
  Future<void> createSampleFoodExpiringNotification({
    String? customFoodName,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in - cannot create test notification');
      return;
    }

    try {
      final foodName = customFoodName ?? 'Burger & Fries';
      
      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': 'Food Expiring Soon ⏰',
        'message': 'Your "$foodName" expires within 24 hours.',
        'type': 'food_expiring',
        'related_id': null,
        'is_read': false,
      });

      debugPrint('✅ Sample food expiring notification created successfully');
    } catch (e) {
      debugPrint('❌ Error creating sample notification: $e');
    }
  }

  /// Create multiple sample notifications at once
  Future<void> createAllSampleNotifications() async {
    await createSampleFoodClaimedNotification();
    await Future.delayed(Duration(milliseconds: 500));
    
    await createSampleMessageNotification();
    await Future.delayed(Duration(milliseconds: 500));
    
    await createSampleFoodExpiringNotification();
    
    debugPrint('✅ All sample notifications created');
  }

  /// Clear all notifications for the current user (for testing)
  Future<void> clearAllNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in - cannot clear notifications');
      return;
    }

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id);

      debugPrint('✅ All notifications cleared for current user');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  /// Simulate a food claim by creating a notification for another user
  /// This is useful for testing the donor notification feature
  Future<void> simulateFoodClaim({
    required String donorUserId,
    String? foodTitle,
    String? claimerName,
  }) async {
    try {
      await _dbNotificationService.createFoodClaimedNotification(
        donorId: donorUserId,
        foodTitle: foodTitle ?? 'Test Food Item',
        claimerName: claimerName ?? 'Test Claimer',
        foodListingId: 'test-listing-id',
      );

      debugPrint('✅ Simulated food claim notification created for donor: $donorUserId');
    } catch (e) {
      debugPrint('❌ Error simulating food claim: $e');
    }
  }

  /// Get user ID (useful for testing with multiple accounts)
  String? getCurrentUserId() {
    final user = _supabase.auth.currentUser;
    return user?.id;
  }

  /// Print current user info for debugging
  void printCurrentUserInfo() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      debugPrint('📱 Current User ID: ${user.id}');
      debugPrint('📧 Current User Email: ${user.email}');
    } else {
      debugPrint('❌ No user currently logged in');
    }
  }
}