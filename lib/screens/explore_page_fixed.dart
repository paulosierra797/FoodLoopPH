import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'landing_page.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _isListView = true;
  String _selectedLocation = 'Dasmariñas, Cavite';
  bool _isNotificationDropdownOpen = false;
  bool _showAllNotifications = true; // true for "All", false for "Unread"
  final GlobalKey _notificationKey = GlobalKey();

  // Sample notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "icon": Icons.favorite,
      "title": "New food near you!",
      "subtitle": "Fresh pasta available at Maria's Kitchen, 0.5km away",
      "time": "2 min ago",
      "isNew": true,
    },
    {
      "id": 2,
      "icon": Icons.schedule,
      "title": "Food expiring soon",
      "subtitle": "Pizza from Tony's expires in 2 hours",
      "time": "15 min ago",
      "isNew": true,
    },
    {
      "id": 3,
      "icon": Icons.check_circle,
      "title": "Food saved successfully",
      "subtitle": "You saved bread from Baker's Corner",
      "time": "1 hour ago",
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
      for (var notif in _notifications) {
        notif["isNew"] = false;
      }
    });
  }

  // Sample food listings
  final List<Map<String, dynamic>> _foodListings = [
    {
      'title': 'Fresh Pasta & Marinara',
      'restaurant': 'Maria\'s Kitchen',
      'distance': '0.5 km away',
      'time': 'Expires in 2 hours',
      'rating': 4.8,
      'price': 'Free',
      'image': 'https://via.placeholder.com/150x100/FF6B6B/FFFFFF?text=Pasta',
    },
    {
      'title': 'Artisan Bread Loaves',
      'restaurant': 'Baker\'s Corner',
      'distance': '1.2 km away',
      'time': 'Expires in 4 hours',
      'rating': 4.9,
      'price': 'Free',
      'image': 'https://via.placeholder.com/150x100/4ECDC4/FFFFFF?text=Bread',
    },
    {
      'title': 'Mixed Vegetable Curry',
      'restaurant': 'Spice Garden',
      'distance': '0.8 km away',
      'time': 'Expires in 1 hour',
      'rating': 4.7,
      'price': 'Free',
      'image': 'https://via.placeholder.com/150x100/45B7D1/FFFFFF?text=Curry',
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
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
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.notifications,
                                    color: Colors.grey[700], size: 24),
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

                  // Page Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Explore Food',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),

                  // Menu Icon
                  GestureDetector(
                    onTap: _showSideMenu,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.menu, color: Colors.grey[700], size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Notification Dropdown
            if (_isNotificationDropdownOpen)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: _buildNotificationDropdown(context, _notifications),
              ),

            // Location and View Toggle Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Location Row
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showLocationPicker(context),
                          child: Text(
                            _selectedLocation,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for food, restaurants...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // View Toggle and Filters
                  Row(
                    children: [
                      // List/Map Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isListView = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isListView
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'List',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _isListView
                                        ? Colors.orange[700]
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isListView = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_isListView
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Map',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: !_isListView
                                        ? Colors.orange[700]
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),

                      // Filter Icons
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showTypeFilter,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.restaurant_menu,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showSortByFilter,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child:
                                  Icon(Icons.sort, color: Colors.white, size: 20),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showDistanceFilter,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.near_me,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isListView ? _buildListView() : _buildMapView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _foodListings.length,
      itemBuilder: (context, index) {
        final listing = _foodListings[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [Colors.orange[300]!, Colors.orange[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing['price']!,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      listing['restaurant']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          listing['distance']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.red[400]),
                        SizedBox(width: 4),
                        Text(
                          listing['time']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              listing['rating'].toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Handle reservation
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          ),
                          child: Text(
                            'Reserve',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Map View',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    // Implement location picker
  }

  void _showTypeFilter() {
    // Implement type filter dialog
  }

  void _showSortByFilter() {
    // Implement sort by filter dialog
  }

  void _showDistanceFilter() {
    // Implement distance filter dialog
  }

  Widget _buildNotificationDropdown(BuildContext context, List<Map<String, dynamic>> allNotifications) {
    final filteredNotifications = _showAllNotifications
        ? allNotifications
        : allNotifications.where((notif) => notif["isNew"] == true).toList();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
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
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            "Mark all read",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
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
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  "All",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _showAllNotifications
                                        ? Colors.blue[600]
                                        : Colors.grey[600],
                                  ),
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
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  "Unread",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: !_showAllNotifications
                                        ? Colors.blue[600]
                                        : Colors.grey[600],
                                  ),
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
            Expanded(
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

  Widget _buildEmptyNotificationState() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No notifications",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
              .animate(animation1),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.orange[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Colors.orange, size: 30),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'John Doe',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'john.doe@email.com',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu Items
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          children: [
                            // ACTIVITY Section
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'ACTIVITY',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            _buildMenuItemWithIcon(Icons.star_outline, 'My Watchlist', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WatchlistPage()),
                              );
                            }),

                            _buildMenuItemWithIcon(Icons.list_alt_outlined, 'My Listings', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ListingsPage()),
                              );
                            }),

                            SizedBox(height: 30),

                            // SETTINGS Section
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'SETTINGS',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            _buildMenuItemWithIcon(Icons.person_outline, 'Profile', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfilePage()),
                              );
                            }),

                            _buildMenuItemWithIcon(Icons.notifications_outlined, 'Notification Settings', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NotificationPage()),
                              );
                            }),

                            _buildMenuItemWithIcon(Icons.security_outlined, 'Password & Security', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                              );
                            }),

                            _buildMenuItemWithIcon(Icons.info_outline, 'About', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AboutPage()),
                              );
                            }),

                            SizedBox(height: 30),

                            // Sign Out Button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LandingPage()),
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout, color: Colors.red.shade600, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign Out',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade600,
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
                    ],
                  ),
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
