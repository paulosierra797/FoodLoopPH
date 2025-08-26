// HomeScreen widget (with navigation and drawer)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'add_food_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'about_page.dart';
import 'login_screen.dart';
import '../supabase_client.dart';

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
      SearchPage(),
      AddFoodPage(),
      Center(child: Text("Messages Page")),
      Center(child: Text("Profile Page")),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      Scaffold.of(context).openEndDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // ✅ Only one endDrawer
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              UserAccountsDrawerHeader(
                accountName: Text("User"),
                accountEmail: Text("user@email.com"),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                decoration: BoxDecoration(color: Colors.amber[700]),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text("My Watchlist"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WatchlistPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text("My Listings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListingsPage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Notification Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text("Change Password"),
                onTap: () {
                  // TODO: Implement change password navigation
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.logout, size: 20),
                    label: Text("Sign Out", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    onPressed: () async {
                      // Supabase sign out logic
                      try {
                        await supabase.auth.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Custom bottom navigation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home),
              _buildNavItem(1, Icons.search_outlined, Icons.search),
              _buildAddButton(),
              _buildNavItem(3, Icons.chat_bubble_outline, Icons.chat_bubble),
              _buildMenuButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon) {
    bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber[700]!.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? Colors.amber[700] : Colors.grey[600],
            size: 24,
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
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber[700]!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Icon(Icons.menu_outlined, color: Colors.grey[600], size: 24),
          ),
        ),
      ),
    );
  }
}
