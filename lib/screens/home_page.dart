import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'notification_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import '../widgets/notification_dropdown.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OverlayEntry? _notificationOverlayEntry;
  bool _showAllNotifications = true; // true for "All", false for "Unread"
  final GlobalKey _notificationKey = GlobalKey();

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


  void _showNotificationOverlay() {
    if (_notificationOverlayEntry != null) return;
    final RenderBox renderBox = _notificationKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _notificationOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 180 + size.width,
        top: offset.dy + size.height + 8,
        width: 320,
        child: NotificationDropdown(
          notifications: _notifications,
          onMarkAllAsRead: () {
            setState(() {
              for (var notification in _notifications) {
                notification["isNew"] = false;
              }
            });
          },
          onMarkAsRead: (id) {
            setState(() {
              final index = _notifications.indexWhere((notif) => notif["id"] == id);
              if (index != -1) {
                _notifications[index]["isNew"] = false;
              }
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
            _hideNotificationOverlay();
          },
          iconKey: _notificationKey,
          showAll: _showAllNotifications,
          onToggleShowAll: (showAll) {
            setState(() {
              _showAllNotifications = showAll;
            });
          },
          onClose: _hideNotificationOverlay,
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_notificationOverlayEntry!);
  }

  void _hideNotificationOverlay() {
    _notificationOverlayEntry?.remove();
    _notificationOverlayEntry = null;
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Notifications and Menu
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[400]!, Colors.amber[600]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Menu Icon
                      GestureDetector(
                        onTap: _showSideMenu,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.menu, color: Colors.white, size: 24),
                        ),
                      ),

                      // Greeting Text
                      Expanded(
                        child: Consumer<UserService>(
                          builder: (context, userService, child) {
                            final userName = userService.currentUser?.firstName ?? "User";
                            return Column(
                              children: [
                                Text(
                                  "Good morning,",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Notification Icon with counter and dropdown
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Builder(
                          builder: (context) {
                            final unreadCount = _notifications.where((notif) => notif["isNew"] == true).length;
                            return Stack(
                              children: [
                                GestureDetector(
                                  key: _notificationKey,
                                  onTap: () {
                                    if (_notificationOverlayEntry == null) {
                                      _showNotificationOverlay();
                                    } else {
                                      _hideNotificationOverlay();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.notifications,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
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
                                      child: Text(
                                        unreadCount.toString(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard("Available", "12", Icons.restaurant),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard("Donated", "8", Icons.favorite),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard("Saved", "24", Icons.savings),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notification Overlay is handled separately

            // Quick Actions Section
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Actions",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          "Share Food",
                          "Donate food to help others",
                          Icons.add_circle,
                          Colors.green,
                          () {
                            // Navigate to add food page
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          "Find Food",
                          "Discover nearby donations",
                          Icons.search,
                          Colors.blue,
                          () {
                            // Navigate to explore page
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Donations Section
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Recent Donations",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Navigate to all donations
                          },
                          child: Text(
                            "See All",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          return _buildDonationCard(donations[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, String> donation) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(donation["img"]!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation["name"]!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  donation["food"]!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[500], size: 14),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        donation["address"]!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Button
          GestureDetector(
            onTap: () {
              // Handle donation action
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showSideMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Watchlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WatchlistPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.list_alt,
                    title: 'My Listings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListingsPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.orange[700], size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
    );
  }



} // <-- Add this closing bracket to end the _HomePageState class
