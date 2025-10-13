import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/food_listings_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  bool _isListView = true;
  String _selectedLocation = 'Dasmariñas, Cavite';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Map related variables
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _currentLocation =
      LatLng(14.329620, 120.937140); // Default: Dasmariñas center
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _createMarkers();
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
        _createMarkers();
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      _createMarkers();
    }
  }

  // Create markers for food listings
  void _createMarkers() {
    final listingsAsync = ref.read(foodListingsProvider);
    listingsAsync.when(
      data: (listings) {
        Set<Marker> markers = {};

        // Add user location marker
        markers.add(
          Marker(
            markerId: MarkerId('user_location'),
            position: _currentLocation,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Your Location',
              snippet: 'You are here',
            ),
          ),
        );

        // Add food listing markers
        for (int i = 0; i < listings.length; i++) {
          final listing = listings[i];
          final lat = listing['latitude'] ?? listing['lat'];
          final lng = listing['longitude'] ?? listing['lng'];

          if (lat != null && lng != null) {
            Color markerColor =
                _getMarkerColorForCategory(listing['category'] ?? 'Other');

            markers.add(
              Marker(
                markerId: MarkerId('food_$i'),
                position: LatLng(lat.toDouble(), lng.toDouble()),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    _getHueForColor(markerColor)),
                infoWindow: InfoWindow(
                  title: listing['title'] ?? 'Food Item',
                  snippet:
                      '${listing['description'] ?? 'Food'} - ${listing['quantity'] ?? 'Available'}',
                ),
              ),
            );
          }
        }

        if (mounted) {
          setState(() {
            _markers = markers;
          });
        }
      },
      loading: () {},
      error: (error, stack) {
        debugPrint('Error creating markers: $error');
      },
    );
  }

  // Get marker color based on food category
  Color _getMarkerColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fast food':
        return Colors.red;
      case 'filipino':
        return Colors.orange;
      case 'bakery':
        return Colors.brown;
      case 'asian':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  // Convert Color to Google Maps hue
  double _getHueForColor(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.brown) return BitmapDescriptor.hueRose;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(foodListingsProvider);
    return Scaffold(
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Search and Filter Section (unchanged)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Location Row
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.orange[600], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showLocationPicker(context),
                          child: Text(
                            _selectedLocation,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search for food, restaurants...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Category Filter and View Toggle
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryChip('All'),
                              _buildCategoryChip('Fast Food'),
                              _buildCategoryChip('Filipino'),
                              _buildCategoryChip('Bakery'),
                              _buildCategoryChip('Others'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // View Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildViewToggle(Icons.list, true),
                            _buildViewToggle(Icons.map, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: listingsAsync.when(
                data: (listings) {
                  final filtered = listings.where((listing) {
                    final name =
                        (listing["name"] ?? '').toString().toLowerCase();
                    final food =
                        (listing["food"] ?? '').toString().toLowerCase();
                    final category =
                        (listing["category"] ?? 'Others').toString();
                    final matchesSearch = _searchQuery.isEmpty ||
                        name.contains(_searchQuery.toLowerCase()) ||
                        food.contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategory == 'All' ||
                        category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();
                  return _isListView
                      ? _buildListView(filtered)
                      : _buildMapView(filtered);
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading listings')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: Colors.orange[100],
        checkmarkColor: Colors.orange[600],
        backgroundColor: Colors.grey[100],
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.orange[600] : Colors.grey[700],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isListView) {
    bool isSelected = _isListView == isListView;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isListView = isListView;
        });
        if (!_isListView) {
          _createMarkers(); // Create markers when switching to map view
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> listings) {
    if (listings.isEmpty) {
      return Center(child: Text('No listings found.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _buildFoodCard(listing);
      },
    );
  }

  Widget _buildMapView(List<Map<String, dynamic>> listings) {
    if (_isLoadingLocation) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange[600]),
            SizedBox(height: 16),
            Text(
              'Loading map...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),
        // Custom location button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _goToCurrentLocation,
            child: Icon(Icons.my_location, color: Colors.orange[600]),
          ),
        ),
        // Legend for marker colors
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                _buildLegendItem('Fast Food', Colors.red),
                _buildLegendItem('Filipino', Colors.orange),
                _buildLegendItem('Bakery', Colors.brown),
                _buildLegendItem('Asian', Colors.purple),
                _buildLegendItem('Others', Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String category, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            category,
            style: GoogleFonts.poppins(fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Go to current location
  void _goToCurrentLocation() async {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );
    }
  }

  Widget _buildFoodCard(Map<String, dynamic> listing) {
    String name = (listing["title"] ?? "Unnamed").toString();
    String category = (listing["category"] ?? "Other").toString();
    List<dynamic>? images = listing["images"] as List<dynamic>?;
    String food = (listing["description"] ?? "Unknown food").toString();
    String quantity = (listing["quantity"] ?? "N/A").toString();
    String address = (listing["location"] ?? "No address").toString();
    String time = (listing["expiration_date"] ?? "Unknown time").toString();
    // No rating in your schema, so set to 0
    double rating = 0.0;
    // status: 'available' or 'claimed'
    String status = (listing["status"] ?? "claimed").toString().toLowerCase();
    bool available = status == 'available';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _buildFoodImage(
            images: images,
            category: category,
            height: 150,
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: available ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        available ? "Available" : "Claimed",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              available ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Food and Quantity
                Text(
                  food,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  quantity,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Bottom Row
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (available)
                      ElevatedButton(
                        onPressed: () => _claimFood(listing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Claim",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Location",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            ...[
              'Dasmariñas, Cavite',
              'Imus, Cavite',
              'Bacoor, Cavite',
              'Las Piñas, Metro Manila'
            ].map((location) => ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(location),
                  onTap: () {
                    setState(() {
                      _selectedLocation = location;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLocationDetails(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing["name"] ?? "Unknown Location"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Food: ${listing["food"] ?? "Not specified"}"),
            SizedBox(height: 8),
            Text("Address: ${listing["address"] ?? "Address not available"}"),
            SizedBox(height: 8),
            Text("Distance: ${listing["distance"] ?? "Unknown"}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  // Helper method to build food image with fallbacks
  Widget _buildFoodImage(
      {required List<dynamic>? images,
      required String category,
      double? width,
      double height = 150}) {
    // Try to get first image
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]?.toString();
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        width:
            width ?? double.infinity, // Fill available width if not specified
        height: height,
        child: Container(
          color: Colors.grey[200],
          child: imageUrl != null && imageUrl.isNotEmpty
              ? _buildNetworkImageWithFallback(
                  imageUrl, category, width ?? 300.0, height)
              : _buildCategoryIcon(category),
        ),
      ),
    );
  }

  Widget _buildNetworkImageWithFallback(
      String imageUrl, String category, double width, double height) {
    // Check if it's a valid URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Validate width and height to prevent Infinity/NaN errors
      final safeWidth = (width.isFinite && width > 0) ? width.toInt() : 300;
      final safeHeight = (height.isFinite && height > 0) ? height.toInt() : 200;

      // Use optimized URL for Supabase Storage
      final optimizedUrl =
          _getOptimizedImageUrl(imageUrl, width: safeWidth, height: safeHeight);

      return Image.network(
        optimizedUrl,
        width: double.infinity, // Fill the container width
        height: double.infinity, // Fill the container height
        fit: BoxFit.cover, // Ensure image covers the entire container
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
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
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
      child: Icon(icon, color: color, size: 48),
    );
  }

  void _claimFood(Map<String, dynamic> listing) {
    // Derive a readable item name and source (poster) safely to avoid nulls in UI
    final itemName = (listing['title'] ??
            listing['food'] ??
            listing['description'] ??
            'this food')
        .toString();
    final sourceName =
        (listing['name'] ?? listing['poster_name'] ?? listing['username'] ?? '')
            .toString();
    final fromPhrase = sourceName.isNotEmpty ? ' from $sourceName' : '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Claim Food"),
        content: Text("Are you sure you want to claim $itemName$fromPhrase?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _confirmClaim(listing);
            },
            child: Text("Claim"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClaim(Map<String, dynamic> listing) async {
    Navigator.pop(context); // close dialog
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You must be signed in to claim food'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final listingId = listing['id'];
      if (listingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Listing id missing, cannot claim'),
              backgroundColor: Colors.red),
        );
        return;
      }

      // Use the new claim_food_item function
      final result = await supabase.rpc('claim_food_item', params: {
        'food_id': listingId,
        'claimer_id': user.id,
      });

      if (result == true) {
        // Also insert into food_claims table for backwards compatibility
        try {
          await supabase.from('food_claims').insert({
            'food_listing_id': listingId,
            'user_id': user.id,
          });
        } catch (e) {
          // Ignore if already exists
          debugPrint('Food claim already exists: $e');
        }

        // Attempt to update listing status in DB (ignore errors silently)
        try {
          await supabase
              .from('food_listings')
              .update({'status': 'claimed'}).eq('id', listingId);
        } catch (_) {}

        // Create notification for the donor (manual fallback if trigger doesn't work)
        try {
          final donorId = listing['posted_by'];
          if (donorId != null && donorId != user.id) {
            // Get claimer's name
            final claimerResponse = await supabase
                .from('users')
                .select('first_name, last_name')
                .eq('id', user.id)
                .single();

            final claimerName =
                '${claimerResponse['first_name'] ?? ''} ${claimerResponse['last_name'] ?? ''}'
                    .trim();
            final foodTitle = listing['title'] ?? 'Food item';

            await supabase.from('notifications').insert({
              'user_id': donorId,
              'title': 'Food Item Claimed! 🎉',
              'message': '$claimerName has claimed your "$foodTitle"',
              'type': 'food_claimed',
              'related_id': listingId,
              'is_read': false,
            });
          }
        } catch (e) {
          debugPrint('Error creating manual notification: $e');
        }
      } else {
        throw Exception('Unable to claim this food item');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Food claimed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Claim failed: $e'), backgroundColor: Colors.red),
      );
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
}
