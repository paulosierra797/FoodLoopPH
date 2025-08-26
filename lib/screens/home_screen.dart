// HomeScreen widget (with navigation and drawer)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'add_food_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'landing_page.dart';
import 'chat_list_page.dart';
import 'community_page.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      ExplorePage(),
      AddFoodPage(),
      CommunityPage(),
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
    return Scaffold(
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Header with User Info
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Consumer<UserService>(
                            builder: (context, userService, child) {
                              final user = userService.currentUser;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? "User",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    user?.email ?? "user@gmail.com",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        // Home Button
                        _buildDrawerItem(
                          icon: Icons.home_outlined,
                          title: "Home",
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                        ),

                        SizedBox(height: 20),

                        // Activity Section
                        _buildSectionHeader("ACTIVITY"),
                        _buildDrawerItem(
                          icon: Icons.star_outline,
                          title: "My Watchlist",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WatchlistPage()),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.list_alt_outlined,
                          title: "My Listings",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListingsPage()),
                            );
                          },
                        ),

                        SizedBox(height: 20),

                        // Settings Section
                        _buildSectionHeader("SETTINGS"),
                        _buildDrawerItem(
                          icon: Icons.person_outline,
                          title: "Profile",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.notifications_outlined,
                          title: "Notification Settings",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.help_outline,
                          title: "About",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AboutPage()),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage()),
                            );
                          },
                        ),

                        Spacer(),

                        // Sign Out Button
                        Container(
                          margin: EdgeInsets.all(20),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _showSignOutDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Sign Out",
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Builder(
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItemWithLabel(0, Icons.home, Icons.home, "Home"),
                  _buildNavItemWithLabel(
                      1, Icons.search, Icons.search, "Explore"),
                  _buildAddButton(),
                  _buildNavItemWithLabel(
                      3, Icons.people, Icons.people, "Community"),
                  _buildNavItemWithLabel(4, Icons.mail, Icons.mail, "Messages"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithLabel(
      int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Color(0xFF6B46C1) : Colors.grey[500],
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isSelected ? Color(0xFF6B46C1) : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onItemTapped(2),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF6B46C1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6B46C1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      width: double.infinity,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.grey[700],
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Sign Out",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to sign out?",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                // Sign out user using UserService
                final userService =
                    Provider.of<UserService>(context, listen: false);
                await userService.signOut();

                // Navigate back to landing page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                  (route) => false,
                );
              },
              child: Text(
                "Sign Out",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
