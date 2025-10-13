// Main Navigation Screen with Single Scaffold
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_service_provider.dart';
import '../providers/notifications_provider.dart';
import '../services/database_notification_service.dart';
import 'home_page.dart';
import 'explore_page_full.dart';
import 'add_food_page.dart';
import 'community_page.dart';
import 'chat_list_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'notification_settings_page.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      const ExplorePage(),
      AddFoodPage(),
      const CommunityPageNew(),
      ChatListPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.watch(userServiceProvider);
    return WillPopScope(
        onWillPop: () async {
          // If not on Home tab, go to Home instead of popping the route stack
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
            return false; // don't pop the route
          }
          // When already on Home, consume back to avoid navigating to Landing/Login
          // Optionally, implement double-back-to-exit UX later.
          return false;
        },
        child: Scaffold(
          // Consistent AppBar with notification bell and hamburger menu on the right
          appBar: AppBar(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false, // Remove default leading
            actions: [
              // Facebook/Instagram-style notification icon with badge
              Stack(
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      _showNotificationDropdown(context);
                    },
                  ),
                  // Notification badge with real count
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCountAsync =
                          ref.watch(unreadNotificationsCountProvider);
                      return unreadCountAsync.when(
                        data: (count) {
                          if (count > 0) {
                            return Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  count > 99 ? '99+' : count.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                        loading: () => SizedBox.shrink(),
                        error: (_, __) => SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
              // Hamburger menu moved to the right
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),

          // End Drawer for hamburger menu (right side)
          endDrawer: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.45, // Reduced from 0.85 to 0.45 (45%)
            child: Drawer(
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with User Info
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.orange[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Text(
                                (() {
                                  final user = userService.currentUser;
                                  final fullName = user?.fullName ?? "";
                                  return fullName.isNotEmpty
                                      ? fullName
                                          .split(' ')
                                          .map((name) =>
                                              name.isNotEmpty ? name[0] : '')
                                          .take(2)
                                          .join('')
                                      : "JD";
                                })(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Column(
                              children: [
                                Text(
                                  userService.currentUser?.fullName ??
                                      "Juan Dela Cruz",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  userService.currentUser?.email ??
                                      "juan.delacruz@example.com",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu Items
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          children: [
                            _buildDrawerItem(Icons.star_outline, 'My Watchlist',
                                () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WatchlistPage()),
                              );
                            }),
                            _buildDrawerItem(
                                Icons.list_alt_outlined, 'My Listings', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListingsPage()),
                              );
                            }),
                            Divider(height: 20, color: Colors.grey[300]),
                            _buildDrawerItem(Icons.person_outline, 'Profile',
                                () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()),
                              );
                            }),
                            _buildDrawerItem(Icons.settings_outlined,
                                'Notification Settings', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationSettingsPage()),
                              );
                            }),
                            _buildDrawerItem(
                                Icons.lock_outline, 'Change Password', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePasswordPage()),
                              );
                            }),
                            _buildDrawerItem(Icons.info_outline, 'About', () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutPage()),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Sign Out Button at the bottom
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[500],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              // Sign out from Supabase
                              await Supabase.instance.client.auth.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => LandingPage()),
                                (route) => false,
                              );
                            },
                            icon: Icon(Icons.logout, size: 20),
                            label: Text(
                              'Sign Out',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dynamic Body Content
          body: _pages[_selectedIndex],

          // Standard Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.orange[600],
            unselectedItemColor: Colors.grey[500],
            backgroundColor: Colors.white,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: 'Share',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                activeIcon: Icon(Icons.mail),
                label: 'Messages',
              ),
            ],
          ),
        ));
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  } // Added missing closing brace for the method

  // Facebook/Instagram-style notification dropdown
  void _showNotificationDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 300,
        kToolbarHeight + 10,
        10,
        0,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.settings,
                            color: Colors.grey[600], size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final notificationsAsync =
                          ref.watch(notificationsProvider);
                      return notificationsAsync.when(
                        data: (notifications) {
                          if (notifications.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_none,
                                      size: 48, color: Colors.grey[400]),
                                  SizedBox(height: 12),
                                  Text(
                                    'No notifications yet',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Show only the first 3 notifications in dropdown
                          final displayNotifications =
                              notifications.take(3).toList();

                          return ListView(
                            padding: EdgeInsets.zero,
                            children: displayNotifications.map((notification) {
                              final createdAt =
                                  DateTime.parse(notification['created_at']);
                              final timeAgo = _formatTimeAgo(createdAt);

                              return _buildNotificationItem(
                                _getNotificationIcon(notification['type']),
                                notification['title'] ?? 'FoodLoop',
                                notification['message'] ?? '',
                                timeAgo,
                                !(notification['is_read'] ?? true),
                                () {
                                  // Mark as read when clicked
                                  DatabaseNotificationService()
                                      .markAsRead(notification['id']);
                                  ref.invalidate(notificationsProvider);
                                  ref.invalidate(
                                      unreadNotificationsCountProvider);
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Center(
                          child: CircularProgressIndicator(
                              color: Colors.orange[600]),
                        ),
                        error: (_, __) => Center(
                          child: Text(
                            'Error loading notifications',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationPage()),
                        );
                      },
                      child: Text(
                        'See All Notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for notifications
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

  String _getNotificationIcon(String? type) {
    switch (type) {
      case 'food_claimed':
        return '🎉';
      case 'new_message':
        return '💬';
      case 'food_expiring':
        return '⏰';
      default:
        return '🍎';
    }
  }

  Widget _buildNotificationItem(
      String avatar, String name, String message, String time, bool isUnread,
      [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue[50] : Colors.transparent,
        ),
        child: Row(
          children: [
            // Avatar with online indicator for unread
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange[100],
                  child: Text(avatar, style: TextStyle(fontSize: 16)),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$name ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: message,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Action button (optional)
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
