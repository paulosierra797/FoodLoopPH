import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Sample food listings data
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
      "expires": "6 hours"
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
      "expires": "4 hours"
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
      "expires": "2 hours"
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
      "expires": "12 hours"
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
      "expires": "8 hours"
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
    return Container(
      child: Stack(
        children: [
          // Map placeholder
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "Map View",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Interactive map coming soon",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Map markers (simulated)
          ...List.generate(_filteredListings.length, (index) {
            return Positioned(
              top: 100.0 + (index * 50),
              left: 50.0 + (index * 40),
              child: GestureDetector(
                onTap: () => _showLocationDetails(_filteredListings[index]),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.restaurant, color: Colors.white, size: 16),
                ),
              ),
            );
          }),
        ],
      ),
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

  void _showLocationDetails(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing["name"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Food: ${listing["food"]}"),
            SizedBox(height: 8),
            Text("Address: ${listing["address"]}"),
            SizedBox(height: 8),
            Text("Distance: ${listing["distance"]}"),
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

  void _claimFood(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Claim Food"),
        content: Text(
            "Are you sure you want to claim ${listing["food"]} from ${listing["name"]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                listing["available"] = false;
                listing["quantity"] = "Claimed";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Food claimed successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Claim"),
          ),
        ],
      ),
    );
  }
}
