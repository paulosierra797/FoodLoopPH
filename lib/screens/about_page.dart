// AboutPage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[700],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.amber[700],
              child: Row(
                children: [
                  Text(
                    "Good morning, User",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.notifications, color: Colors.black87, size: 24),
                ],
              ),
            ),
            // About Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back, size: 20),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "About",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Container(width: 36), // Balance the row
                        ],
                      ),
                      SizedBox(height: 32),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FoodLoop PH is a community-powered food-sharing mobile app designed to reduce food waste and fight hunger in the Philippines. The app connects individuals, businesses, and organizations with surplus food to nearby people who need it. By creating a simple, safe, and accessible platform, FoodLoop PH promotes kindness, sustainability, and food security.",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                "With FoodLoop PH, users can:",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildFeatureItem(
                                "Share food easily",
                                "Post surplus or leftover food with photos, details, and pickup instructions.",
                              ),
                              SizedBox(height: 12),
                              _buildFeatureItem(
                                "Discover nearby offers",
                                "Browse available food listings through map or list view.",
                              ),
                              SizedBox(height: 12),
                              _buildFeatureItem(
                                "Connect safely",
                                "Reserve items and chat with donors directly to arrange pickup.",
                              ),
                              SizedBox(height: 12),
                              _buildFeatureItem(
                                "Build community trust",
                                "Track completed pickups and leave ratings or feedback.",
                              ),
                              SizedBox(height: 24),
                              Text(
                                "FoodLoop PH supports United Nations Sustainable Development Goal 2: Zero Hunger by promoting responsible food sharing and ensuring access to safe and nutritious meals. Together, we can build stronger, waste-free, and food-secure communities.",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Colors.black87,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4, right: 12),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.amber[700],
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
