import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _isListView = true;
  String _selectedLocation = 'Dasmariñas, Cavite';

  // Sample food listings data
  final List<Map<String, dynamic>> _foodListings = [
    {
      "name": "McDonald's Dasmariñas",
      "address": "SM City Dasmariñas, Governor's Drive, Dasmariñas, Cavite",
      "food": "Burgers & Fries",
      "time": "2 hours ago",
      "img": "https://i.imgur.com/jX0Xn5G.png",
      "rating": 4.5,
      "distance": "1.2 km"
    },
    {
      "name": "Jollibee Dasmariñas",
      "address": "Aguinaldo Highway, Dasmariñas, Cavite",
      "food": "Fried Chicken",
      "time": "3 hours ago",
      "img": "https://i.imgur.com/IDQK9tC.png",
      "rating": 4.3,
      "distance": "0.8 km"
    },
    {
      "name": "Pizza Hut",
      "address": "Robinsons Place Dasmariñas, Dasmariñas, Cavite",
      "food": "Pizza & Pasta",
      "time": "1 hour ago",
      "img": "https://i.imgur.com/pizza.png",
      "rating": 4.2,
      "distance": "2.1 km"
    },
    {
      "name": "KFC Dasmariñas",
      "address": "SM City Dasmariñas, Dasmariñas, Cavite",
      "food": "Fried Chicken",
      "time": "4 hours ago",
      "img": "https://i.imgur.com/kfc.png",
      "rating": 4.1,
      "distance": "1.5 km"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        title: Text(
          'Explore',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Location and View Toggle
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.amber[700],
            child: Column(
              children: [
                // Location Row
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showLocationPicker(context),
                        child: Text(
                          _selectedLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16),

                // Search Bar
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for food, restaurants...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // View Toggle and Filters
                Row(
                  children: [
                    // List/Map Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isListView = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isListView
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'List',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _isListView
                                      ? Colors.amber[700]
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isListView = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isListView
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Map',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: !_isListView
                                      ? Colors.amber[700]
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    // Filter Icons
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showTypeFilter,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.restaurant_menu,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showSortByFilter,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                Icon(Icons.sort, color: Colors.white, size: 20),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showDistanceFilter,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.near_me,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
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
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _foodListings.length,
      itemBuilder: (context, index) {
        final listing = _foodListings[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber[600], size: 14),
                              SizedBox(width: 4),
                              Text(
                                listing['rating'].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      listing['food'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing['address'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          listing['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Text(
                          listing['distance'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  Widget _buildMapView() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Map View',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Map integration coming soon!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 10),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Location',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  'Dasmariñas, Cavite',
                  'Imus, Cavite',
                  'Bacoor, Cavite',
                  'Las Piñas, Metro Manila',
                  'Muntinlupa, Metro Manila',
                ]
                    .map((location) => ListTile(
                          leading:
                              Icon(Icons.location_on, color: Colors.amber[700]),
                          title: Text(
                            location,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedLocation = location;
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Close',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter() {
    // Implement type filter dialog
  }

  void _showSortByFilter() {
    // Implement sort by filter dialog
  }

  void _showDistanceFilter() {
    // Implement distance filter dialog
  }
}
