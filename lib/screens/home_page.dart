// HomePage widget (donations list) - Riverpod version
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_service_provider.dart';
import '../providers/food_listings_provider.dart';
import '../providers/dashboard_metrics_provider.dart';

// Provider for managing tab navigation
final tabNavigationProvider = StateNotifierProvider<TabNavigationNotifier, int>((ref) {
  return TabNavigationNotifier();
});

class TabNavigationNotifier extends StateNotifier<int> {
  TabNavigationNotifier() : super(0);
  
  void changeTab(int index) {
    // Always trigger a change, even if it's the same index
    if (state == index) {
      // Force a temporary change to trigger listeners
      state = -1;
    }
    state = index;
  }
  
  void updateTab(int index) {
    // Direct update without forcing change logic
    state = index;
  }
}

String _getTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final listingsAsync = ref.watch(foodListingsProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);
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
                Text(
                  "Good Day, ${userService.currentUser?.firstName ?? "User"}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Section (unchanged)
          Container(
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                metricsAsync.when(
                  data: (m) => Row(
                    children: [
                      Expanded(
                        child: _buildDashboardCard(
                          m.totalDonations.toString(),
                          "Total Donations",
                          Icons.local_dining,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDashboardCard(
                          m.activeListings.toString(),
                          "Active Listings",
                          Icons.restaurant_menu,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDashboardCard(
                          m.peopleHelped.toString(),
                          "People that Help",
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Row(
                    children: [
                      Expanded(
                          child: _buildDashboardCard('—', 'Total Donations',
                              Icons.local_dining, Colors.green)),
                      SizedBox(width: 12),
                      Expanded(
                          child: _buildDashboardCard('—', 'Active Listings',
                              Icons.restaurant_menu, Colors.orange)),
                      SizedBox(width: 12),
                      Expanded(
                          child: _buildDashboardCard('—', 'People that Help',
                              Icons.people, Colors.blue)),
                    ],
                  ),
                  error: (e, st) {
                    // Log the error and show fallback values
                    debugPrint('Dashboard metrics error: $e');
                    return Row(
                      children: [
                        Expanded(
                            child: _buildDashboardCard('0', 'Total Donations',
                                Icons.local_dining, Colors.green)),
                        SizedBox(width: 12),
                        Expanded(
                            child: _buildDashboardCard('0', 'Active Listings',
                                Icons.restaurant_menu, Colors.orange)),
                        SizedBox(width: 12),
                        Expanded(
                            child: _buildDashboardCard('0', 'People that Help',
                                Icons.people, Colors.blue)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Featured Food Listings Section (dynamic)
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Featured Food Listings",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Switch to Explore tab (index 1) using the provider
                          ref.read(tabNavigationProvider.notifier).changeTab(1);
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
                    child: listingsAsync.when(
                      data: (listings) {
                        if (listings.isEmpty) {
                          return Center(
                            child: Text(
                              'No food listings yet.',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          );
                        }
                        // Show up to 5 latest listings
                        final featured = listings.take(5).toList();
                        return ListView.builder(
                          itemCount: featured.length,
                          itemBuilder: (context, index) {
                            final item = featured[index];
                            return _buildFeaturedListingCard(context, item);
                          },
                        );
                      },
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (e, st) =>
                          Center(child: Text('Error loading listings')),
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

  Widget _buildDashboardCard(
      String value, String label, IconData icon, Color color) {
    return Container(
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListingCard(BuildContext context, Map<String, dynamic> item) {
    // Map Supabase fields to card fields
    final title = (item['title'] ?? 'No Title').toString();
    final description = (item['description'] ?? '').toString();
    final location = (item['location'] ?? '').toString();
    final quantity = (item['quantity'] ?? '').toString();
    final img = (item['images'] != null &&
            item['images'] is List &&
            (item['images'] as List).isNotEmpty)
        ? (item['images'][0] ?? '').toString()
        : '';
    final status = (item['status'] ?? '').toString();
    final createdAt = (item['created_at'] ?? '').toString();
    final DateTime? date = DateTime.tryParse(createdAt);
    final String timeAgo = date != null ? _getTimeAgo(date) : 'Recently';

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
            child: img.isNotEmpty
                ? Image.network(
                    img,
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
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(Icons.food_bank, color: Colors.grey[400]),
                  ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.restaurant, size: 12, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      quantity,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                if (location.isNotEmpty)
                  Text(
                    location,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.isNotEmpty ? status : "available",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              if (status.toLowerCase() == 'available' || status.isEmpty)
                SizedBox(
                  width: 80,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Claim Food Item',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to claim "${item['title'] ?? 'this item'}"?',
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Item claimed successfully!',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Claim',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Claim",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
