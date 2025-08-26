import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _notificationsEnabled = true;
  bool _newFoodNearby = true;
  bool _foodClaimUpdates = true;
  bool _pickupReminders = true;
  bool _donorMessages = true;
  bool _ratingsFeedback = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get newFoodNearby => _newFoodNearby;
  bool get foodClaimUpdates => _foodClaimUpdates;
  bool get pickupReminders => _pickupReminders;
  bool get donorMessages => _donorMessages;
  bool get ratingsFeedback => _ratingsFeedback;

  Future<void> initialize() async {
    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // Handle notification tap
  }

  // Show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'foodloop_channel',
      'FoodLoop Notifications',
      channelDescription: 'Notifications for FoodLoop PH app',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Specific notification methods
  Future<void> showNewFoodNearbyNotification({
    required String foodName,
    required String donorName,
    required String distance,
  }) async {
    if (!_newFoodNearby) return;

    await showNotification(
      id: 1,
      title: 'New Food Available Nearby! 🍽️',
      body: '$donorName posted $foodName ($distance away)',
      payload: 'new_food_nearby',
    );
  }

  Future<void> showFoodClaimUpdateNotification({
    required String foodName,
    required String claimerName,
  }) async {
    if (!_foodClaimUpdates) return;

    await showNotification(
      id: 2,
      title: 'Your Food Was Claimed! 🎉',
      body: '$claimerName claimed your $foodName',
      payload: 'food_claimed',
    );
  }

  Future<void> showPickupReminderNotification({
    required String foodName,
    required String time,
  }) async {
    if (!_pickupReminders) return;

    await showNotification(
      id: 3,
      title: 'Pickup Reminder ⏰',
      body: 'Don\'t forget to pickup $foodName at $time',
      payload: 'pickup_reminder',
    );
  }

  Future<void> showDonorMessageNotification({
    required String senderName,
    required String message,
  }) async {
    if (!_donorMessages) return;

    await showNotification(
      id: 4,
      title: 'New Message from $senderName 💬',
      body: message,
      payload: 'new_message',
    );
  }

  Future<void> showRatingFeedbackNotification({
    required String reviewerName,
    required int rating,
  }) async {
    if (!_ratingsFeedback) return;

    String stars = '⭐' * rating;
    await showNotification(
      id: 5,
      title: 'New Rating Received! $stars',
      body: '$reviewerName gave you a $rating-star rating',
      payload: 'new_rating',
    );
  }

  // Settings update methods
  void updateNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    if (!enabled) {
      // Disable all notification types when main toggle is off
      _newFoodNearby = false;
      _foodClaimUpdates = false;
      _pickupReminders = false;
      _donorMessages = false;
      _ratingsFeedback = false;
    }
    notifyListeners();
  }

  void updateNewFoodNearby(bool enabled) {
    _newFoodNearby = enabled;
    notifyListeners();
  }

  void updateFoodClaimUpdates(bool enabled) {
    _foodClaimUpdates = enabled;
    notifyListeners();
  }

  void updatePickupReminders(bool enabled) {
    _pickupReminders = enabled;
    notifyListeners();
  }

  void updateDonorMessages(bool enabled) {
    _donorMessages = enabled;
    notifyListeners();
  }

  void updateRatingsFeedback(bool enabled) {
    _ratingsFeedback = enabled;
    notifyListeners();
  }

  // Demo notifications for testing
  Future<void> sendTestNotifications() async {
    await Future.delayed(Duration(seconds: 2));
    await showNewFoodNearbyNotification(
      foodName: 'Fresh Pizza',
      donorName: 'Mario\'s Pizzeria',
      distance: '0.5km',
    );

    await Future.delayed(Duration(seconds: 5));
    await showDonorMessageNotification(
      senderName: 'Maria Santos',
      message: 'Hi! The food is ready for pickup.',
    );

    await Future.delayed(Duration(seconds: 8));
    await showPickupReminderNotification(
      foodName: 'Burger & Fries',
      time: '3:00 PM',
    );
  }
}
