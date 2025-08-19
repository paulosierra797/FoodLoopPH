import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(FoodLoopApp());
}

class FoodLoopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFC107), // Yellow background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: Column(
                children: [
                  Text(
                    "FoodLoop PH",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Share Food. Fight Waste.\nFeed Communities.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Post surplus food and\nhelp others nearby",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  "Get started",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//
// LOGIN SCREEN
//
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Food",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Loop PH",
                      style: TextStyle(color: Colors.amber[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Share Food. Fight Waste.\nFeed Communities.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              Text("Please enter your details",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v!),
                      ),
                      Text("Remember Me", style: GoogleFonts.poppins(fontSize: 12)),
                    ],
                  ),
                  TextButton(
                    onPressed: () { Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                  },
                    child: Text("Forgot Password ?", style: GoogleFonts.poppins(fontSize: 12)),
                  )
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text("Sign In", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account ? ",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text("Sign Up",
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
//Forgot Password
//

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              // Title
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "Oh, no !\n"),
                    TextSpan(
                      text: "I forgot",
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Subtitle
              Text(
                "Enter your email and we’ll send you a link to change a new password",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40),

              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Enter email",
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[700]!),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Forgot Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    String email = _emailController.text.trim();
                    if (email.isNotEmpty) {
                      // TODO: Handle forgot password logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password reset link sent to $email")),
                      );
                    }
                  },
                  child: Text(
                    "Forgot Password",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// SIGN UP SCREEN
//
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "Hi !\n", style: TextStyle(color: Colors.black87)),
                    TextSpan(text: "Welcome", style: TextStyle(color: Colors.amber[700])),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text("Let's create an account",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 25),
              TextField(
                decoration: InputDecoration(labelText: "Email", border: UnderlineInputBorder()),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: "First name", border: UnderlineInputBorder()))),
                  SizedBox(width: 15),
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: "Last name", border: UnderlineInputBorder()))),
                ],
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(labelText: "Username", border: UnderlineInputBorder()),
              ),
              SizedBox(height: 15),
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Text("Must contain a number and at least 6 characters",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              SizedBox(height: 15),
              TextField(
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              Text("Must contain a number and at least 6 characters",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text("Sign Up",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Have an account ? ",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text("Sign in",
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// HOME SCREEN WITH NAVIGATION
//


// 🔹 Home Screen with donations list
class HomePage extends StatelessWidget {
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
        toolbarHeight: 90,
        backgroundColor: Colors.amber[700],
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning, User",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text("Dasmariñas",
                    style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications, size: 26, color: Colors.black),
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
                                Chip(label: Text("Food type: ${item['food']}")),
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
}

// 🔹 Placeholder Search Page
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Center(child: Text("Search Page")),
    );
  }
}

// 🔹 Placeholder Add Food Page
class AddFoodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Food")),
      body: Center(child: Text("Add Food Page")),
    );
  }
}

// 🔹 Main HomeScreen with BottomNav + Drawer

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ✅ Donations list for Home page
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

  // ✅ Pages list (with design now)
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      _buildSearchPage(),
      _buildAddFoodPage(),
      Center(child: Text("Messages Page")),
      Center(child: Text("Profile Page")),
    ];
  }

  // -------------------- PAGES --------------------

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.amber[700],
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning, User",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text("Dasmariñas",
                    style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications, size: 26, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Food donations",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
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
                                      style:
                                          GoogleFonts.poppins(fontSize: 11),
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
                                              "Food type: ${item['food']}")),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Donations", style: GoogleFonts.poppins()),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search food or donor...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.fastfood, color: Colors.amber[700]),
                    title: Text("Burger from McDo"),
                    subtitle: Text("Dasmariñas"),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_pizza, color: Colors.amber[700]),
                    title: Text("Pizza from Balinsasayaw"),
                    subtitle: Text("Dasmariñas"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddFoodPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Food Donation", style: GoogleFonts.poppins()),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Food Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Pickup Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Food Donation Added!")),
                );
              },
              child: Text("Submit", style: GoogleFonts.poppins(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  // -------------------- BOTTOM NAV --------------------
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
        builder: (context) => BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 4) {
              Scaffold.of(context).openEndDrawer();
            } else {
              _onItemTapped(index);
            }
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 35), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: ""),
          ],
        ),
      ),
    );
  }
}

// 🔹 Example Pages



class WatchlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Watchlist")),
      body: Center(child: Text("Watchlist Page", style: TextStyle(fontSize: 24))),
    );
  }
}

class ListingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Listings")),
      body: Center(child: Text("Listings Page", style: TextStyle(fontSize: 24))),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: Center(child: Text("Account Page", style: TextStyle(fontSize: 24))),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Center(child: Text("Notification Settings Page", style: TextStyle(fontSize: 24))),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: Center(child: Text("About Page", style: TextStyle(fontSize: 24))),
    );
  }
}