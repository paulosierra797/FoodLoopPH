import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/food_listings_provider.dart';
import 'chat_page.dart';

class ListingsPage extends ConsumerWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(foodListingsProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Listings",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(foodListingsProvider);
            },
          ),
        ],
      ),
      body: listingsAsync.when(
        data: (listings) {
          // Filter listings to show only current user's posts
          final userListings = currentUser != null 
              ? listings.where((item) => _safeString(item['posted_by']) == currentUser.id).toList()
              : listings;
              
          if (userListings.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            color: Colors.orange[600],
            onRefresh: () async {
              ref.invalidate(foodListingsProvider);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: userListings.length,
              itemBuilder: (context, index) {
                final item = userListings[index];
                return _buildListingCard(item, context, ref);
              },
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
              ),
              SizedBox(height: 16),
              Text(
                'Loading your listings...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        error: (e, st) => _buildErrorState(e.toString(), ref),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> item, BuildContext context, WidgetRef ref) {
    final title = _safeString(item['title']);
    final description = _safeString(item['description']);
    final category = _safeString(item['category']);
    final location = _safeString(item['location']);
    final quantity = _safeString(item['quantity']);
    final measurement = _safeString(item['measurement']);
    final displayQuantity = measurement.isNotEmpty ? '$quantity $measurement' : (quantity.isNotEmpty ? quantity : 'N/A');
    final status = _safeString(item['status']);
    final createdAt = _safeString(item['created_at']);
    
    // Parse date for display
    final DateTime? date = DateTime.tryParse(createdAt);
    final String timeAgo = date != null ? _getTimeAgo(date) : 'Recently';
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                ],
                
                // Details row
                Row(
                  children: [
                    _buildDetailChip(Icons.category, category, Colors.blue),
                    SizedBox(width: 8),
                    _buildDetailChip(Icons.scale, displayQuantity, Colors.green),
                  ],
                ),
                
                if (location.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                
                SizedBox(height: 12),
                
                // Footer with time and actions
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Spacer(),
                    // Add message button for claimed items
                    if (status.toLowerCase() == 'claimed') ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(60, 28),
                        ),
                        onPressed: () async {
                          debugPrint('Item data for claimed food: $item');
                          
                          // First try to use claimed_by field directly from the item
                          final claimedById = item['claimed_by']?.toString();
                          if (claimedById != null && claimedById.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  otherUserId: claimedById,
                                  otherUserName: 'User', // We'll get the name from the chat
                                  listingId: item['id']?.toString(),
                                  listingTitle: item['title']?.toString(),
                                ),
                              ),
                            );
                            return;
                          }
                          
                          // Fallback: Try to get claimer info from the database
                          try {
                            final claimerInfo = await _getClaimerInfo(item['id']);
                            if (claimerInfo != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    otherUserId: claimerInfo['claimer_id'] ?? '',
                                    otherUserName: claimerInfo['claimer_name'] ?? 'User',
                                    listingId: item['id']?.toString(),
                                    listingTitle: item['title']?.toString(),
                                  ),
                                ),
                              );
                              return;
                            }
                          } catch (e) {
                            debugPrint('Error fetching claimer info: $e');
                          }
                          
                          final claimerId = item['claimer_id']?.toString();
                          final claimerName = item['claimer_name']?.toString() ?? 'User';
                          debugPrint('Claimer ID: $claimerId, Claimer Name: $claimerName');
                          if (claimerId != null && claimerId.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  otherUserId: claimerId,
                                  otherUserName: claimerName,
                                  listingId: item['id']?.toString(),
                                  listingTitle: item['title']?.toString(),
                                ),
                              ),
                            );
                          } else {
                            // Show dialog to manually find the claimer or provide alternative
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Contact Claimer'),
                                content: Text('The claimer information is not available in the database yet. You can check your Messages tab to see if they\'ve contacted you, or wait for them to message you first.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Navigate to messages tab (assuming it's index 4 in main navigation)
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                        '/',
                                        (route) => false,
                                        arguments: 4, // Messages tab index
                                      );
                                    },
                                    child: Text('Go to Messages'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Message',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildActionButtons(item, context, ref),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    if (text.isEmpty) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> item, BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, size: 20, color: Colors.orange[600]),
          onPressed: () => _editListing(item, context, ref),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: Icon(Icons.delete, size: 20, color: Colors.red[600]),
          onPressed: () => _deleteListing(item, context, ref),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.orange[600],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Food Listings Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start sharing food donations with your community!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(foodListingsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions
  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Future<Map<String, String>?> _getClaimerInfo(dynamic listingId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Try to use the same RPC function that gets claimed foods, but in reverse
      // to find who claimed a specific listing
      final response = await supabase.rpc('get_listing_claimer', params: {
        'listing_id': listingId,
      });
      
      if (response != null && response.isNotEmpty) {
        final claimerData = response[0];
        return {
          'claimer_id': claimerData['claimer_id']?.toString() ?? '',
          'claimer_name': claimerData['claimer_name']?.toString() ?? 'User',
        };
      }
    } catch (e) {
      debugPrint('Error in _getClaimerInfo: $e');
      
      // Fallback: Try direct query to food_claims or similar table
      try {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('food_claims')
            .select('claimer_id, users!food_claims_claimer_id_fkey(first_name, last_name)')
            .eq('food_listing_id', listingId)
            .eq('status', 'approved')
            .maybeSingle();
        
        if (response != null) {
          final userInfo = response['users'];
          return {
            'claimer_id': response['claimer_id']?.toString() ?? '',
            'claimer_name': userInfo != null 
                ? '${userInfo['first_name'] ?? ''} ${userInfo['last_name'] ?? ''}'.trim()
                : 'User',
          };
        }
      } catch (e2) {
        debugPrint('Fallback query also failed: $e2');
      }
    }
    
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'claimed':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
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

  void _editListing(Map<String, dynamic> item, BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController(text: _safeString(item['title']));
    final descriptionController = TextEditingController(text: _safeString(item['description']));
    final quantityController = TextEditingController(text: _safeString(item['quantity']));
    
    final measurementOptions = [
      'per piece',
      'kg',
      'grams',
      'liters',
      'ml',
      'servings',
      'portions',
      'packs',
      'boxes',
    ];
    
    String selectedMeasurement = _safeString(item['measurement']);
    if (!measurementOptions.contains(selectedMeasurement)) {
      selectedMeasurement = 'per piece'; // Default to first option
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Edit Listing',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Form fields
                _buildEnhancedTextField(
                  controller: titleController,
                  label: 'Title',
                  icon: Icons.title,
                  hint: 'Enter food title',
                ),
                
                SizedBox(height: 16),
                
                _buildEnhancedTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  hint: 'Describe your food item',
                  maxLines: 3,
                ),
                
                SizedBox(height: 16),
                
                // Quantity and Measurement row - responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 350) {
                      // Stack vertically on very small screens
                      return Column(
                        children: [
                          _buildEnhancedTextField(
                            controller: quantityController,
                            label: 'Quantity',
                            icon: Icons.numbers,
                            hint: 'e.g., 5',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedDropdown(
                            value: selectedMeasurement,
                            label: 'Measurement',
                            icon: Icons.straighten,
                            items: measurementOptions,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedMeasurement = newValue;
                                });
                              }
                            },
                          ),
                        ],
                      );
                    } else {
                      // Side by side layout for larger screens
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildEnhancedTextField(
                              controller: quantityController,
                              label: 'Quantity',
                              icon: Icons.numbers,
                              hint: 'e.g., 5',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildEnhancedDropdown(
                              value: selectedMeasurement,
                              label: 'Measurement',
                              icon: Icons.straighten,
                              items: measurementOptions,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMeasurement = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                
                SizedBox(height: 24),
                
                // Action buttons - responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 350) {
                      // Stack vertically on very small screens
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Changes',
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
                      );
                    } else {
                      // Side by side layout for larger screens
                      return Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Save Changes',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        await Supabase.instance.client
            .from('food_listings')
            .update({
              'title': titleController.text.trim(),
              'description': descriptionController.text.trim(),
              'quantity': quantityController.text.trim(),
              'measurement': selectedMeasurement,
            })
            .eq('id', item['id']);
        ref.invalidate(foodListingsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Listing updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update listing: $e')),
        );
      }
    }
  }

  void _deleteListing(Map<String, dynamic> item, BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${_safeString(item['title'])}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('food_listings')
            .delete()
            .eq('id', item['id']);
        
        // Refresh the listings
        ref.invalidate(foodListingsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Listing deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete listing: $e')),
        );
      }
    }
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEnhancedDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
