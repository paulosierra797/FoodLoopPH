// AddFoodPage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  
  String _selectedCategory = 'Prepared Food';
  String _selectedExpiry = 'Today';
  bool _isUrgent = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.grey[700], size: 24),
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
                padding: EdgeInsets.all(16),
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
                            colors: [Colors.orange[300]!, Colors.orange[500]!],
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
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),

                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _quantityController,
                              label: 'Quantity',
                              hint: 'e.g., 10 servings, 5 kg',
                              icon: Icons.scale,
                              required: true,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              value: _selectedExpiry,
                              label: 'Best Before',
                              items: _expiryOptions,
                              icon: Icons.schedule,
                              onChanged: (value) => setState(() => _selectedExpiry = value!),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Additional details about the food...',
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      SizedBox(height: 24),

                      // Pickup Information Section
                      _buildSectionHeader('Pickup Information', Icons.location_on),
                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Pickup Address',
                        hint: 'Street, City, Province',
                        icon: Icons.home,
                        required: true,
                        maxLines: 2,
                      ),

                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _contactController,
                        label: 'Contact Number',
                        hint: '+63 9XX XXX XXXX',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),

                      SizedBox(height: 16),

                      // Urgent Toggle
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isUrgent ? Colors.red[50] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isUrgent ? Colors.red[200]! : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              color: _isUrgent ? Colors.red[600] : Colors.grey[600],
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
                                      color: _isUrgent ? Colors.red[700] : Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'Food needs to be picked up today',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _isUrgent ? Colors.red[600] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isUrgent,
                              onChanged: (value) => setState(() => _isUrgent = value),
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
                          onPressed: _submitDonation,
                          child: Row(
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

                      SizedBox(height: 24),
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
          validator: required ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
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

  void _submitDonation() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
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
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous page
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
    }
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
