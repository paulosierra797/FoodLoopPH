import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool notificationsEnabled = true;
  bool newFoodNearby = true;
  bool foodClaimUpdates = true;
  bool pickUpReminders = true;
  bool donorMessages = true;
  bool ratingsAndFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF8A50),
                    Color(0xFFFFB74D)
                  ], // Orange gradient
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Notification Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  SizedBox(height: 24),

                  // Main notifications toggle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                notificationsEnabled = value;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Colors.black,
                            inactiveThumbColor: Colors.grey[400],
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Notification categories
                  _buildNotificationItem(
                    'New Food Nearby',
                    'Get notified when someone posts available food near your location.',
                    newFoodNearby,
                    (value) => setState(() => newFoodNearby = value),
                  ),

                  _buildNotificationItem(
                    'Food Claim Updates',
                    'Alerts when someone reserves or claims a post on your post.',
                    foodClaimUpdates,
                    (value) => setState(() => foodClaimUpdates = value),
                  ),

                  _buildNotificationItem(
                    'Pick Up Reminders',
                    'Remind me before my scheduled food pickup.',
                    pickUpReminders,
                    (value) => setState(() => pickUpReminders = value),
                  ),

                  _buildNotificationItem(
                    'Donor Messages',
                    'Get notified when a donor or recipient sends you a message.',
                    donorMessages,
                    (value) => setState(() => donorMessages = value),
                  ),

                  _buildNotificationItem(
                    'Ratings & Feedback',
                    'Notifications when you receive a new rating or review.',
                    ratingsAndFeedback,
                    (value) => setState(() => ratingsAndFeedback = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange checkbox icon
          Container(
            margin: EdgeInsets.only(top: 2),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFFFF8A50),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),

          SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
