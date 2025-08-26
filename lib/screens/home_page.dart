// HomePage widget (donations list)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'notification_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'change_password_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isNotificationDropdownOpen = false;
  bool _showAllNotifications = true; // true for "All", false for "Unread"
  final GlobalKey _notificationKey = GlobalKey();
  
  // Notification data with state management
  List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "icon": Icons.local_pizza,
      "title": "New Food Available",
      "subtitle": "McDo Pala-pala has shared burger & fries near you",
      "time": "2 mins ago",
      "isNew": true,
    },
    {
      "id": 2,
      "icon": Icons.update,
      "title": "Food Claimed",
      "subtitle": "Someone claimed your pizza donation",
      "time": "1 hour ago",
      "isNew": true,
    },
    {
      "id": 3,
      "icon": Icons.access_time,
      "title": "Pickup Reminder",
      "subtitle": "Don't forget to pickup your food at 3:00 PM",
      "time": "2 hours ago",
      "isNew": true,
    },
    {
      "id": 4,
      "icon": Icons.star,
      "title": "New Rating",
      "subtitle": "You received a 5-star rating from John",
      "time": "1 day ago",
      "isNew": false,
    },
  ];

  void _markNotificationAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((notif) => notif["id"] == id);
      if (index != -1) {
        _notifications[index]["isNew"] = false;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification["isNew"] = false;
      }
    });
  }

  final List<Map<String, String>> donations = [
    {
      "name": "McDo Pala-pala",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Burger & Fries",
      "img": "https://i.imgur.com/3ZQ3Z5F.png"
    },
    {
      "name": "Balinsasayaw",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Pizza",
      "img": "https://i.imgur.com/jX0Xn5G.png"
    },
    {
      "name": "Jabi Caloocan",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Fried Chicken",
      "img": "https://i.imgur.com/IDQK9tC.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.amber[700],
        automaticallyImplyLeading: false,
        title: Consumer<UserService>(
          builder: (context, userService, child) {
            final userName = userService.currentUser?.firstName ?? "User";
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
        actions: [
          // Notification Icon with counter and dropdown
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Builder(
              builder: (context) {
                final unreadCount = _notifications.where((notif) => notif["isNew"] == true).length;
                
                return Stack(
                  children: [
                    GestureDetector(
                      key: _notificationKey,
                      onTap: () {
                        setState(() {
                          _isNotificationDropdownOpen = !_isNotificationDropdownOpen;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isNotificationDropdownOpen
                              ? Colors.black.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.notifications,
                            size: 26,
                            color: _isNotificationDropdownOpen
                                ? Colors.black87
                                : Colors.black),
                      ),
                    ),
                    // Notification Counter Badge
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (_isNotificationDropdownOpen)
                      Positioned(
                        top: 40,
                        right: 0,
                        child: _buildNotificationDropdown(context, _notifications),
                      ),
                  ],
                );
              },
            ),
          ),
          // Menu Icon
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                _showSideMenu();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.menu,
                  size: 26,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final item = donations[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item["img"]!,
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["name"]!,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item["address"]!,
                                style: GoogleFonts.poppins(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: [
                                Chip(label: Text("Quantity: 4 pcs")),
                                Chip(
                                    label: Text(
                                        "Food type: " + (item['food'] ?? ''))),
                              ],
                            )
                          ]),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {},
                      child: const Text("Accept"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationDropdown(BuildContext context, List<Map<String, dynamic>> allNotifications) {
    final filteredNotifications = _showAllNotifications
        ? allNotifications
        : allNotifications.where((notif) => notif["isNew"] == true).toList();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 320,
        constraints: BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with toggle
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Notifications",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: _markAllAsRead,
                        child: Text(
                          "Mark all read",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isNotificationDropdownOpen = false;
                          });
                        },
                        child: Icon(Icons.close,
                            size: 20, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // All/Unread Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAllNotifications = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _showAllNotifications
                                    ? Colors.amber[600]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "All",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _showAllNotifications
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAllNotifications = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_showAllNotifications
                                    ? Colors.amber[600]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Unread",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: !_showAllNotifications
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Notifications list or empty state
            Flexible(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyNotificationState()
                  : ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: filteredNotifications
                          .map((notif) => _buildNotificationDropdownItem(
                                id: notif["id"],
                                icon: notif["icon"],
                                title: notif["title"],
                                subtitle: notif["subtitle"],
                                time: notif["time"],
                                isNew: notif["isNew"],
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotificationState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showAllNotifications
                ? Icons.notifications_none
                : Icons.mark_email_read,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _showAllNotifications
                ? "No notifications yet"
                : "No unread notifications",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _showAllNotifications
                ? "We'll notify you when something important happens"
                : "You're all caught up!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDropdownItem({
    required int id,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isNew,
  }) {
    return InkWell(
      onTap: () {
        _markNotificationAsRead(id);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isNew ? Colors.amber[50] : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isNew ? Colors.amber[100] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isNew ? Colors.amber[800] : Colors.grey[600],
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "NEW",
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSideMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    // User Profile Section (matching the image)
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.grey[600], size: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'user@gmail.com',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Home Section
                          _buildMenuItemWithIcon(Icons.home_outlined, 'Home', () {
                            Navigator.pop(context);
                          }),
                          
                          // Activity Section Header
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              'ACTIVITY',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          _buildMenuItemWithIcon(Icons.star_outline, 'My Watchlist', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WatchlistPage()));
                          }),
                          _buildMenuItemWithIcon(Icons.list_alt_outlined, 'My Listings', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ListingsPage()));
                          }),

                          // Settings Section Header
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              'SETTINGS',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          _buildMenuItemWithIcon(Icons.person_outline, 'Profile', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                          }),
                          _buildMenuItemWithIcon(Icons.notifications_outlined, 'Notification Settings', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                          }),
                          _buildMenuItemWithIcon(Icons.help_outline, 'About', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                          }),
                          _buildMenuItemWithIcon(Icons.lock_outline, 'Change Password', () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                          }),
                        ],
                      ),
                    ),
                    // Sign Out Button
                    Container(
                      margin: EdgeInsets.all(20),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add sign out logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItemWithIcon(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
