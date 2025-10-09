import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_provider.dart';
import '../services/database_notification_service.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    
    return Scaffold(
      backgroundColor: Colors.amber[700],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.amber[700],
              child: Row(
                children: [
                  Text(
                    "Notifications",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.notifications, color: Colors.black87, size: 24),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back, size: 20),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Notifications",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          notificationsAsync.when(
                            data: (notifications) {
                              final unreadCount = notifications.where((n) => !(n['is_read'] ?? true)).length;
                              return unreadCount > 0
                                  ? GestureDetector(
                                      onTap: () => _markAllAsRead(),
                                      child: Text(
                                        "Mark all read",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.amber[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : Container(width: 36);
                            },
                            loading: () => Container(width: 36),
                            error: (_, __) => Container(width: 36),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        child: notificationsAsync.when(
                          data: (notifications) => notifications.isEmpty
                              ? _buildEmptyNotifications()
                              : _buildNotificationsList(notifications),
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber[700],
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading notifications',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => ref.invalidate(notificationsProvider),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No Notifications",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "You're all caught up!\nWe'll notify you when something new happens.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, index);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    IconData iconData;
    Color iconColor;

    switch (notification['type']) {
      case 'food_claimed':
        iconData = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'new_message':
        iconData = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'food_expiring':
        iconData = Icons.schedule;
        iconColor = Colors.red;
        break;
      case 'welcome':
        iconData = Icons.waving_hand;
        iconColor = Colors.amber;
        break;
      case 'update':
        iconData = Icons.info;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        // Delete notification from database
        await DatabaseNotificationService().deleteNotification(notification['id']);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationsCountProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification dismissed')),
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () async {
          // Mark as read when tapped
          if (!(notification['is_read'] ?? false)) {
            await DatabaseNotificationService().markAsRead(notification['id']);
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadNotificationsCountProvider);
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: (notification['is_read'] ?? false) ? Colors.white : Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (notification['is_read'] ?? false) ? Colors.grey[200]! : Colors.amber[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(DateTime.parse(notification['created_at'])),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (!(notification['is_read'] ?? false))
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  void _markAllAsRead() async {
    await DatabaseNotificationService().markAllAsRead();
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }
}
