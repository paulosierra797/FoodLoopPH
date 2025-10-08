
// HomePage widget (donations list) - Riverpod version
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_service_provider.dart';
import '../providers/food_listings_provider.dart';
import 'explore_page_full.dart';

  // Helper method to build food image with fallbacks
  Widget _buildFoodImage({
    required List<dynamic>? images, 
    required String category, 
    double width = 60, 
    double height = 60
  }) {
    // Try to get first image
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]?.toString();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: imageUrl != null && imageUrl.isNotEmpty
            ? _buildNetworkImageWithFallback(imageUrl, category, width, height)
            : _buildCategoryIcon(category),
      ),
    );
  }

  Widget _buildNetworkImageWithFallback(String imageUrl, String category, double width, double height) {
    // Check if it's a valid URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Use optimized URL for Supabase Storage
      final optimizedUrl = _getOptimizedImageUrl(imageUrl, width: width.toInt(), height: height.toInt());
      
      return Image.network(
        optimizedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $imageUrl - $error');
          return _buildCategoryIcon(category);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange[600],
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // If it's not a valid URL (like our simulated filenames), show category icon
      return _buildCategoryIcon(category);
    }
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;
    
    switch (category.toLowerCase()) {
      case 'prepared food':
        icon = Icons.restaurant;
        color = Colors.orange[600]!;
        break;
      case 'fresh produce':
        icon = Icons.eco;
        color = Colors.green[600]!;
        break;
      case 'packaged food':
        icon = Icons.inventory;
        color = Colors.blue[600]!;
        break;
      case 'baked goods':
        icon = Icons.bakery_dining;
        color = Colors.brown[600]!;
        break;
      case 'beverages':
        icon = Icons.local_drink;
        color = Colors.purple[600]!;
        break;
      default:
        icon = Icons.food_bank;
        color = Colors.grey[600]!;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, color: color, size: 24),
    );
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

  // Helper method to get optimized image URL for Supabase Storage
  String _getOptimizedImageUrl(String originalUrl, {int? width, int? height}) {
    if (originalUrl.contains('/storage/v1/object/public/')) {
      // This is a Supabase Storage URL, add optimization parameters
      final uri = Uri.parse(originalUrl);
      final queryParams = <String, String>{};
      
      if (width != null) queryParams['width'] = width.toString();
      if (height != null) queryParams['height'] = height.toString();
      queryParams['quality'] = '80';
      queryParams['format'] = 'webp';
      
      return uri.replace(queryParameters: queryParams).toString();
    }
    return originalUrl;
  }

class HomePage extends ConsumerWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final listingsAsync = ref.watch(foodListingsProvider);
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
                  "Good morning, ${userService.currentUser?.firstName ?? "User"}",
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
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        "142",
                        "Total Donations",
                        Icons.local_dining,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDashboardCard(
                        "38",
                        "Active Listings",
                        Icons.restaurant_menu,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDashboardCard(
                        "89",
                        "People Helped",
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                  ],
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
                    child: listingsAsync.when(
                      data: (listings) {
                        if (listings.isEmpty) {
                          return Center(
                            child: Text(
                              'No food listings yet.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                          );
                        }
                        // Show up to 5 latest listings
                        final featured = listings.take(5).toList();
                        return ListView.builder(
                          itemCount: featured.length,
                          itemBuilder: (context, index) {
                            final item = featured[index];
                            return _buildFeaturedListingCard(item);
                          },
                        );
                      },
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Error loading listings')),
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

  Widget _buildFeaturedListingCard(Map<String, dynamic> item) {
    // Map Supabase fields to card fields
    final title = (item['title'] ?? 'No Title').toString();
    final description = (item['description'] ?? '').toString();
    final location = (item['location'] ?? '').toString();
    final quantity = (item['quantity'] ?? '').toString();
    final category = (item['category'] ?? '').toString();
    final images = item['images'] as List<dynamic>?;
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
          _buildFoodImage(
            images: images,
            category: category,
            width: 60,
            height: 60,
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.isNotEmpty ? status : "Available",
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
