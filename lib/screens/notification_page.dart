import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Sample notifications - can be empty to show "no notifications"
  List<Map<String, dynamic>> notifications = [
    // Uncomment these to show sample notifications
    // {
    //   "id": 1,
    //   "title": "New comment on your post",
    //   "message": "Maria commented on your zero waste tips post",
    //   "time": "2 hours ago",
    //   "isRead": false,
    //   "type": "comment",
    // },
    // {
    //   "id": 2,
    //   "title": "Someone liked your post",
    //   "message": "Your recipe post received 5 new likes",
    //   "time": "4 hours ago",
    //   "isRead": true,
    //   "type": "like",
    // },
  ];

  @override
  Widget build(BuildContext context) {
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
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      final userName =
                          userService.currentUser?.firstName ?? "User";
                      return Text(
                        "Good morning, $userName",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      );
                    },
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
                          if (notifications.isNotEmpty)
                            GestureDetector(
                              onTap: _markAllAsRead,
                              child: Text(
                                "Mark all read",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            Container(width: 36),
                        ],
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        child: notifications.isEmpty
                            ? _buildEmptyNotifications()
                            : _buildNotificationsList(),
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
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Add sample notifications for demo
              setState(() {
                notifications = [
                  {
                    "id": 1,
                    "title": "Welcome to FoodLoop!",
                    "message": "Thanks for joining our community. Start exploring now!",
                    "time": "now",
                    "isRead": false,
                    "type": "welcome",
                  },
                  {
                    "id": 2,
                    "title": "Community Update",
                    "message": "New features available in the community forum",
                    "time": "1 hour ago",
                    "isRead": false,
                    "type": "update",
                  },
                ];
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              "Add Sample Notifications",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
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
      case 'comment':
        iconData = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'like':
        iconData = Icons.favorite;
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
      onDismissed: (direction) {
        setState(() {
          notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification dismissed')),
        );
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
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['isRead'] ? Colors.white : Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification['isRead'] ? Colors.grey[200]! : Colors.amber[200]!,
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
                    notification['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
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
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }
}
