// HomeScreen widget (with navigation and drawer)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'add_food_page.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'account_page.dart';
import 'notification_page.dart';
import 'about_page.dart';

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
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
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
                      leading: Icon(Icons.account_circle),
                      title: Text("Account"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountPage()),
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
                  ],
                ),
              ),
            ],
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
                  _buildNavItem(0, Icons.home_outlined, Icons.home),
                  _buildNavItem(1, Icons.search_outlined, Icons.search),
                  _buildAddButton(),
                  _buildNavItem(3, Icons.chat_bubble_outline, Icons.chat_bubble),
                  _buildMenuButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData unselectedIcon, IconData selectedIcon) {
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
            color: isSelected
                ? Colors.amber[700]!.withOpacity(0.1)
                : Colors.transparent,
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

  Widget _buildMenuButton(BuildContext context) {
    bool isSelected = _selectedIndex == 4;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Scaffold.of(context).openEndDrawer();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber[700]!.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isSelected ? Icons.menu : Icons.menu_outlined,
            color: isSelected ? Colors.amber[700] : Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }
}
