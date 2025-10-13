// HomePage widget (donations list) - Simplified
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'add_food_page.dart';
import 'explore_page_full.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Simple greeting header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Consumer<UserService>(
                  builder: (context, userService, child) {
                    final userName =
                        userService.currentUser?.firstName ?? "User";
                    return Text(
                      "Good Day, $userName",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddFoodPage()),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExplorePage()),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExplorePage()),
                          );
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
                        final donation = donations[index];
                        return _buildDonationCard(donation);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              donation["img"]!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.food_bank, color: Colors.grey[400]),
                );
              },
            ),
          ),
          SizedBox(width: 16),
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
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  donation["address"]!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Available",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
