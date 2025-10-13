import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
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

  // Sample food listings data with coordinates
  final List<Map<String, dynamic>> _allFoodListings = [
    {
      "name": "McDonald's Dasmariñas",
      "address": "SM City Dasmariñas, Governor's Drive, Dasmariñas, Cavite",
      "food": "Burgers & Fries",
      "time": "2 hours ago",
      "img":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
      "rating": 4.5,
      "distance": "1.2 km",
      "category": "Fast Food",
      "available": true,
      "quantity": "5 sets available",
      "expires": "6 hours",
      "latitude": 14.329620,
      "longitude": 120.937140
    },
    {
      "name": "Jollibee Paliparan",
      "address": "Paliparan Road, Dasmariñas, Cavite",
      "food": "Chicken & Rice",
      "time": "4 hours ago",
      "img":
          "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400",
      "rating": 4.8,
      "distance": "2.1 km",
      "category": "Fast Food",
      "available": true,
      "quantity": "3 sets available",
      "expires": "4 hours",
      "latitude": 14.342850,
      "longitude": 120.943210
    },
    {
      "name": "KFC Tejeros",
      "address": "Tejeros Convention, Rosario, Cavite",
      "food": "Fried Chicken",
      "time": "6 hours ago",
      "img":
          "https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400",
      "rating": 4.3,
      "distance": "3.5 km",
      "category": "Fast Food",
      "available": false,
      "quantity": "Claimed",
      "expires": "2 hours",
      "latitude": 14.295430,
      "longitude": 120.859640
    },
    {
      "name": "Bread Talk Bacoor",
      "address": "SM City Bacoor, Aguinaldo Highway, Bacoor, Cavite",
      "food": "Fresh Bread & Pastries",
      "time": "3 hours ago",
      "img": "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400",
      "rating": 4.6,
      "distance": "4.2 km",
      "category": "Bakery",
      "available": true,
      "quantity": "10+ items available",
      "expires": "12 hours",
      "latitude": 14.459740,
      "longitude": 120.982870
    },
    {
      "name": "Mang Inasal Imus",
      "address": "Imus City, Cavite",
      "food": "Grilled Chicken",
      "time": "5 hours ago",
      "img":
          "https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400",
      "rating": 4.4,
      "distance": "2.8 km",
      "category": "Filipino",
      "available": true,
      "quantity": "2 sets available",
      "expires": "8 hours",
      "latitude": 14.429810,
      "longitude": 120.936950
    },
  ];

  List<Map<String, dynamic>> get _filteredListings {
    return _allFoodListings.where((listing) {
      bool matchesSearch = _searchQuery.isEmpty ||
          listing["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing["food"].toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory = _selectedCategory == 'All' ||
          listing["category"] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

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
    Set<Marker> markers = {};

    // Add user location marker
    markers.add(
      Marker(
        markerId: MarkerId('user_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'You are here',
        ),
      ),
    );

    // Add food listing markers
    for (int i = 0; i < _filteredListings.length; i++) {
      final listing = _filteredListings[i];
      final lat = listing['latitude'];
      final lng = listing['longitude'];

      if (lat != null && lng != null) {
        Color markerColor = _getMarkerColorForCategory(listing['category']);

        markers.add(
          Marker(
            markerId: MarkerId('food_$i'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                _getHueForColor(markerColor)),
            infoWindow: InfoWindow(
              title: listing['name'],
              snippet: '${listing['food']} - ${listing['quantity']}',
              onTap: () => _showFoodDetails(listing),
            ),
            onTap: () => _showFoodDetails(listing),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
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
      default:
        return Colors.green;
    }
  }

  // Convert Color to Google Maps hue
  double _getHueForColor(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.brown) return BitmapDescriptor.hueRose;
    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Search and Filter Section
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
                        if (!_isListView) {
                          _createMarkers(); // Update map markers when search changes
                        }
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
                            _buildViewToggle(Icons.list, true, 'List'),
                            _buildViewToggle(Icons.map, false, 'Map'),
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
              child: _isListView ? _buildListView() : _buildMapView(),
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
          if (!_isListView) {
            _createMarkers(); // Update map markers when category changes
          }
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

  Widget _buildViewToggle(IconData icon, bool isListView, String label) {
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredListings.length,
      itemBuilder: (context, index) {
        final listing = _filteredListings[index];
        return _buildFoodCard(listing);
      },
    );
  }

  Widget _buildMapView() {
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

  // Show food details when marker is tapped
  void _showFoodDetails(Map<String, dynamic> listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: listing['img'] != null
                            ? Image.network(
                                listing['img'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCategoryIconForBottomSheet(
                                      listing['category']);
                                },
                              )
                            : _buildCategoryIconForBottomSheet(
                                listing['category']),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Restaurant name and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: listing['available']
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            listing['available'] ? 'Available' : 'Claimed',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: listing['available']
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Food details
                    Text(
                      listing['food'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      listing['quantity'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Address
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing['address'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Time and rating
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Text(
                          listing['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 24),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          listing['rating'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // Claim button
                    if (listing['available'])
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _claimFood(listing);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Claim This Food',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIconForBottomSheet(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'fast food':
        icon = Icons.fastfood;
        color = Colors.red[600]!;
        break;
      case 'filipino':
        icon = Icons.restaurant;
        color = Colors.orange[600]!;
        break;
      case 'bakery':
        icon = Icons.bakery_dining;
        color = Colors.brown[600]!;
        break;
      default:
        icon = Icons.food_bank;
        color = Colors.green[600]!;
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
      child: Icon(icon, color: color, size: 64),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> listing) {
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
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              listing["img"],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.image, color: Colors.grey[400], size: 40),
                  ),
                );
              },
            ),
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
                        listing["name"],
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
                        color: listing["available"]
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        listing["available"] ? "Available" : "Claimed",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: listing["available"]
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Food and Quantity
                Text(
                  listing["food"],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  listing["quantity"],
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
                        listing["address"],
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
                          listing["rating"].toString(),
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
                          listing["time"],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (listing["available"])
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

  void _claimFood(Map<String, dynamic> listing) {
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
    Navigator.pop(context);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sign in required to claim'),
              backgroundColor: Colors.red),
        );
        return;
      }
      final listingId = listing['id'];
      if (listingId == null) {
        setState(() {
          listing['available'] = false;
          listing['quantity'] = 'Claimed';
        });
      } else {
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

          setState(() {
            listing['available'] = false;
            listing['quantity'] = 'Claimed';
            listing['status'] = 'claimed';
          });

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
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Food claimed successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Claim failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
