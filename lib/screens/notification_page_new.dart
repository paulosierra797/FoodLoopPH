import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPageNew extends StatefulWidget {
  const NotificationPageNew({super.key});

  @override
  State<NotificationPageNew> createState() => _NotificationPageNewState();
}

class _NotificationPageNewState extends State<NotificationPageNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'New Food Available',
      'message': 'Fresh bread posted 500m away from your location',
      'time': '2 min ago',
      'isRead': false,
      'type': 'food',
      'icon': Icons.bakery_dining,
      'avatar': 'https://via.placeholder.com/40',
    },
    {
      'id': 2,
      'title': 'Food Claimed',
      'message': 'Sarah M. claimed your pasta donation',
      'time': '15 min ago',
      'isRead': false,
      'type': 'claim',
      'icon': Icons.person,
      'avatar': 'https://via.placeholder.com/40',
    },
    {
      'id': 3,
      'title': 'Pickup Reminder',
      'message': 'Don\'t forget to pickup vegetables at 3:00 PM today',
      'time': '1 hour ago',
      'isRead': true,
      'type': 'reminder',
      'icon': Icons.schedule,
      'avatar': null,
    },
    {
      'id': 4,
      'title': 'New Message',
      'message': 'John D. sent you a message about the rice donation',
      'time': '2 hours ago',
      'isRead': true,
      'type': 'message',
      'icon': Icons.message,
      'avatar': 'https://via.placeholder.com/40',
    },
    {
      'id': 5,
      'title': 'Rating Received',
      'message': 'You received a 5-star rating from Maria S.',
      'time': '1 day ago',
      'isRead': true,
      'type': 'rating',
      'icon': Icons.star,
      'avatar': 'https://via.placeholder.com/40',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get unreadNotifications =>
      notifications.where((n) => !n['isRead']).toList();

  void markAsRead(int id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['isRead'] = true;
      }
    });
  }

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: Text(
              'Mark all read',
              style: GoogleFonts.poppins(
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber[700],
          labelColor: Colors.amber[700],
          unselectedLabelColor: Colors.grey[600],
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'All (${notifications.length})'),
            Tab(text: 'Unread (${unreadNotifications.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(notifications),
          _buildNotificationList(unreadNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notificationList) {
    if (notificationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        final notification = notificationList[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey[200]! : Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => markAsRead(notification['id']),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: notification['avatar'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          notification['avatar'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              notification['icon'],
                              color: Colors.white,
                              size: 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        notification['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
              ),
              SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification['isRead'])
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
                    SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      notification['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'food':
        return Colors.green[600]!;
      case 'claim':
        return Colors.blue[600]!;
      case 'reminder':
        return Colors.orange[600]!;
      case 'message':
        return Colors.purple[600]!;
      case 'rating':
        return Colors.amber[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
