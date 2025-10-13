// AddFoodPage widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../providers/food_listings_provider.dart';
import '../services/storage_service.dart';
import 'main_navigation_screen.dart';
import 'package:flutter/services.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  const AddFoodPage({super.key});

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Prepared Food';
  String _selectedExpiry = 'Today';
  String _selectedMeasurement = 'per piece';
  bool _isUrgent = false;
  bool _isSubmitting = false;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Location variables
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  final List<String> _categories = [
    'Prepared Food',
    'Fresh Produce',
    'Packaged Food',
    'Baked Goods',
    'Beverages',
    'Other'
  ];

  final List<String> _expiryOptions = [
    'Today',
    'Tomorrow',
    '2-3 days',
    '1 week',
    'More than a week'
  ];

  final List<String> _measurementOptions = [
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

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Show location picker dialog
  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Pickup Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.my_location, color: Colors.orange[600]),
              title: Text('Use Current Location'),
              subtitle: Text('Automatically detect your location'),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.orange[600]),
              title: Text('Select on Map'),
              subtitle: Text('Choose location on map'),
              onTap: () {
                Navigator.pop(context);
                _showMapPicker();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show map picker (simplified for now - will be a basic coordinate input)
  void _showMapPicker() {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 14.329620',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lngController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 120.937140',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);

              if (lat != null && lng != null) {
                setState(() {
                  _selectedLocation = LatLng(lat, lng);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter valid coordinates')),
                );
              }
            },
            child: Text('Set Location'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle Android back button - navigate to MainNavigationScreen instead of popping
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate back to Home tab instead of using Navigator.pop
                        // which was causing logout issues in tab-based navigation
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MainNavigationScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.arrow_back,
                            color: Colors.grey[700], size: 24),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Add Food Donation',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange[300]!,
                                Colors.orange[500]!
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.volunteer_activism,
                                  color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Share Food, Share Hope',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help reduce food waste by sharing with those in need',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Food Details Section
                        _buildSectionHeader('Food Details', Icons.restaurant),
                        SizedBox(height: 16),

                        _buildTextField(
                          controller: _foodNameController,
                          label: 'Food Name',
                          hint: 'e.g., Vegetable Soup, Bread Loaves',
                          icon: Icons.fastfood,
                          required: true,
                        ),

                        SizedBox(height: 16),

                        _buildDropdownField(
                          value: _selectedCategory,
                          label: 'Food Category',
                          items: _categories,
                          icon: Icons.category,
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value!),
                        ),

                        SizedBox(height: 16),

                        // Use Column instead of Row on smaller screens
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 400) {
                              // Stacked layout for smaller screens
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _quantityController,
                                          label: 'Quantity',
                                          hint: 'e.g., 10',
                                          icon: Icons.scale,
                                          keyboardType: TextInputType.number,
                                          required: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDropdownField(
                                          value: _selectedMeasurement,
                                          label: 'Measurement',
                                          items: _measurementOptions,
                                          icon: Icons.straighten,
                                          onChanged: (value) => setState(() => _selectedMeasurement = value!),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildDropdownField(
                                    value: _selectedExpiry,
                                    label: 'Best Before',
                                    items: _expiryOptions,
                                    icon: Icons.schedule,
                                    onChanged: (value) => setState(
                                        () => _selectedExpiry = value!),
                                  ),
                                ],
                              );
                            } else {
                              // Side-by-side layout for larger screens
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _quantityController,
                                      label: 'Quantity',
                                      hint: 'e.g., 10',
                                      icon: Icons.scale,
                                      keyboardType: TextInputType.number,
                                      required: true,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      value: _selectedMeasurement,
                                      label: 'Measurement',
                                      items: _measurementOptions,
                                      icon: Icons.straighten,
                                      onChanged: (value) => setState(() => _selectedMeasurement = value!),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      value: _selectedExpiry,
                                      label: 'Best Before',
                                      items: _expiryOptions,
                                      icon: Icons.schedule,
                                      onChanged: (value) => setState(
                                          () => _selectedExpiry = value!),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),

                        SizedBox(height: 16),

                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description (Optional)',
                          hint: 'Additional details about the food...',
                          icon: Icons.description,
                          maxLines: 3,
                        ),

                        SizedBox(height: 16),

                        // Image Upload Section
                        _buildImageUploadSection(),

                        SizedBox(height: 24),

                        // Pickup Information Section
                        _buildSectionHeader(
                            'Pickup Information', Icons.location_on),
                        SizedBox(height: 16),

                        _buildTextField(
                          controller: _addressController,
                          label: 'Pickup Address',
                          hint: 'Street, City, Province',
                          icon: Icons.home,
                          required: true,
                          maxLines: 2,
                        ),

                        SizedBox(height: 12),

                        // Location Picker Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedLocation != null
                                  ? Colors.green
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedLocation != null
                                ? Colors.green[50]
                                : Colors.grey[50],
                          ),
                          child: InkWell(
                            onTap: _showLocationPicker,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedLocation != null
                                        ? Icons.location_on
                                        : Icons.add_location,
                                    color: _selectedLocation != null
                                        ? Colors.green[600]
                                        : Colors.grey[600],
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedLocation != null
                                              ? 'Location Set'
                                              : 'Set Pickup Location',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedLocation != null
                                                ? Colors.green[700]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          _isLoadingLocation
                                              ? 'Getting location...'
                                              : _selectedLocation != null
                                                  ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                                                  : 'Tap to set location for map display',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isLoadingLocation)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.orange[600]!),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        _buildTextField(
                          controller: _contactController,
                          label: 'Contact Number',
                          hint: 'ex. 09123456789',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          required: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            }
                            if (value.length != 11) {
                              return 'Contact number must be exactly 11 digits';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Urgent Toggle
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isUrgent ? Colors.red[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isUrgent
                                  ? Colors.red[200]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.priority_high,
                                color: _isUrgent
                                    ? Colors.red[600]
                                    : Colors.grey[600],
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Urgent Pickup',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _isUrgent
                                            ? Colors.red[700]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Food needs to be picked up today',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: _isUrgent
                                            ? Colors.red[600]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isUrgent,
                                onChanged: (value) =>
                                    setState(() => _isUrgent = value),
                                activeColor: Colors.red[600],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _submitDonation,
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.volunteer_activism, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'Share Food Donation',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        SizedBox(height: 32),
                        // Extra bottom padding for better scrolling
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 20),
                      ],
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.camera_alt, color: Colors.orange[700], size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Food Photos (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Add photos to make your donation more appealing',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),

        // Image Grid
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  // Add more images button
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              color: Colors.grey[600], size: 32),
                          SizedBox(height: 4),
                          Text(
                            'Add More',
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

                // Display selected image
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${_selectedImages.length}/5 photos selected',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ] else ...[
          // Initial upload area
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: Colors.grey[600],
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add food photos',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Up to 5 photos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange[700], size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to post a donation.')),
      );
      return;
    }

    try {
      // Upload images to Supabase Storage
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        // Show upload progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Uploading ${_selectedImages.length} images...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );

        debugPrint('🔄 Starting upload of ${_selectedImages.length} images...');
        imageUrls = await StorageService().uploadFoodImages(_selectedImages);
        debugPrint('✅ Upload completed. Got ${imageUrls.length} URLs');

        // Clear the upload progress snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (imageUrls.length != _selectedImages.length) {
          // Some uploads failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Some images failed to upload. Continuing with ${imageUrls.length} images.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      await supabase.from('food_listings').insert({
        'title': _foodNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _addressController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'measurement': _selectedMeasurement,
        'posted_by': user.id,
        'status': 'available',
        'expiration_date': _mapExpiryToDate(_selectedExpiry),
        'images': imageUrls,
        'contact_number': _contactController.text.trim(),
        'latitude': _selectedLocation?.latitude,
        'longitude': _selectedLocation?.longitude,
        'is_urgent': _isUrgent,
        'created_at': DateTime.now().toIso8601String(),
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green[600],
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Donation Posted!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your food donation has been shared with the community. Thank you for helping reduce food waste!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Refresh the food listings provider
                      ref.invalidate(foodListingsProvider);
                      // Clear form
                      _clearForm();
                      // Close dialog
                      Navigator.of(context).pop();
                      // Navigate back to main navigation with specific index (listings page)
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MainNavigationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isSubmitting = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post donation: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post donation: $e')),
      );
    }
  }

  // Helper to map expiry option to a date string (YYYY-MM-DD)
  String _mapExpiryToDate(String expiry) {
    final now = DateTime.now();
    switch (expiry) {
      case 'Today':
        return now.toIso8601String().split('T').first;
      case 'Tomorrow':
        return now.add(Duration(days: 1)).toIso8601String().split('T').first;
      case '2-3 days':
        return now.add(Duration(days: 3)).toIso8601String().split('T').first;
      case '1 week':
        return now.add(Duration(days: 7)).toIso8601String().split('T').first;
      case 'More than a week':
        return now.add(Duration(days: 14)).toIso8601String().split('T').first;
      default:
        return now.toIso8601String().split('T').first;
    }
  }

  // Image picker methods
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text('Select multiple'),
                onTap: () {
                  Navigator.pop(context);
                  _getMultipleImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null && _selectedImages.length < 5) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _getMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (_selectedImages.length < 5) {
            _selectedImages.add(File(image.path));
          }
        }
      });

      if (images.length > 5 - (_selectedImages.length - images.length)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Only first ${5 - (_selectedImages.length - images.length)} images were added. Maximum 5 images allowed.')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Clear form after successful submission
  void _clearForm() {
    _foodNameController.clear();
    _quantityController.clear();
    _addressController.clear();
    _descriptionController.clear();
    _contactController.clear();
    setState(() {
      _selectedCategory = 'Prepared Food';
      _selectedExpiry = 'Today';
      _selectedMeasurement = 'per piece';
      _isUrgent = false;
      _isSubmitting = false;
      _selectedImages.clear();
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
