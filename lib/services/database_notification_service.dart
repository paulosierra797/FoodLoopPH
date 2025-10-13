import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class DatabaseNotificationService {
  static final DatabaseNotificationService _instance = DatabaseNotificationService._internal();
  factory DatabaseNotificationService() => _instance;
  DatabaseNotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for the current user
  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Get notifications for the current user
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Create a test notification for a donor when their food is claimed
  Future<void> createFoodClaimedNotification({
    required String donorId,
    required String foodTitle,
    required String claimerName,
    required String foodListingId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': donorId,
        'title': 'Food Item Claimed!',
        'message': '$claimerName has claimed your "$foodTitle"',
        'type': 'food_claimed',
        'related_id': foodListingId,
        'is_read': false,
      });

      // Also send a local push notification if enabled
      await _notificationService.showFoodClaimUpdateNotification(
        foodName: foodTitle,
        claimerName: claimerName,
      );
    } catch (e) {
      debugPrint('Error creating food claimed notification: $e');
    }
  }

  /// Listen to new notifications in real-time
  void listenToNotifications(String userId, Function(Map<String, dynamic>) onNewNotification) {
    try {
      _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .listen((data) {
            if (data.isNotEmpty) {
              // Get the latest notification
              final latestNotification = data.last;
              onNewNotification(latestNotification);
            }
          });
    } catch (e) {
      debugPrint('Error setting up notifications listener: $e');
    }
  }
}