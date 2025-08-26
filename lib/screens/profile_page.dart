// ProfilePage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  String _selectedGender = 'Male';
  File? _profileImage;
  bool _isLoading = false;
  List<String> _existingUsernames = [
    'john_doe',
    'maria_santos',
    'admin',
    'user123'
  ]; // Simulated existing usernames

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userService = Provider.of<UserService>(context, listen: false);
    final user = userService.currentUser;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _birthController.text = user.birthDate ?? '';
      _selectedGender = user.gender ?? 'Male';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show options to pick from camera or gallery
      final result = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Picture',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt,
                            size: 50, color: Colors.amber[700]),
                        SizedBox(height: 8),
                        Text('Camera', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library,
                            size: 50, color: Colors.amber[700]),
                        SizedBox(height: 8),
                        Text('Gallery', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );

      if (result != null) {
        final XFile? image = await picker.pickImage(source: result);
        if (image != null) {
          setState(() {
            _profileImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  bool _isUsernameAvailable(String username) {
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = userService.currentUser;

    // Allow keeping the same username
    if (currentUser?.username == username) {
      return true;
    }

    // Check against existing usernames
    return !_existingUsernames.contains(username.toLowerCase());
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(Duration(days: 6570)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

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
            // Profile Content
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
                    children: [
                      // Header with back button and profile avatar
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
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Icon(Icons.person,
                                        size: 35, color: Colors.grey[600])
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[700],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: Icon(Icons.edit,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(width: 36), // Balance the row
                        ],
                      ),
                      SizedBox(height: 24),
                      // Title
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 32),
                      // Form
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                  "First Name", _firstNameController),
                              SizedBox(height: 16),
                              _buildTextField("Last Name", _lastNameController),
                              SizedBox(height: 16),
                              _buildUsernameField(),
                              SizedBox(height: 16),
                              _buildTextField("Email", _emailController,
                                  enabled: false,
                                  helperText: "Email cannot be changed"),
                              SizedBox(height: 16),
                              _buildTextField("Phone Number", _phoneController),
                              SizedBox(height: 16),
                              // Birth and Sex row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Birth",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: _selectDate,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey[300]!),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _birthController
                                                            .text.isEmpty
                                                        ? "Select date"
                                                        : _birthController.text,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: _birthController
                                                              .text.isEmpty
                                                          ? Colors.grey[500]
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.calendar_today,
                                                    size: 18,
                                                    color: Colors.grey[500]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Sex",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedGender,
                                              isExpanded: true,
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey[500]),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                              items: ['Male', 'Female']
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedGender = newValue!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              // Save button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber[700],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Profile updated successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    "Save Changes",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            helperText: helperText,
            helperStyle:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          validator: enabled
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter username';
            }
            if (!_isUsernameAvailable(value)) {
              return 'Username is already taken';
            }
            return null;
          },
          onChanged: (value) {
            // Trigger validation on change
            _formKey.currentState?.validate();
          },
        ),
      ],
    );
  }
}
