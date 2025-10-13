// ProfilePage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/user_service_provider.dart';
import 'package:flutter/services.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Set<String> _existingUsernames = {};
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  String _selectedGender = 'Male';
  File? _profileImage;
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
    _fetchExistingUsernames();
  }

  Future<void> _fetchExistingUsernames() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('users').select('username');
      setState(() {
        _existingUsernames = response
            .map((u) => (u['username'] ?? '').toString().toLowerCase())
            .where((u) => u.isNotEmpty)
            .toSet();
      });
    } catch (e) {
      debugPrint('Failed to fetch usernames: $e');
    }
  }

  void _loadUserData() {
    final userService = ref.read(userServiceProvider);
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
    final userService = ref.read(userServiceProvider);
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
    final userService = ref.watch(userServiceProvider);
    final user = userService.currentUser;

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
                    user != null
                      ? "Good Day, ${user.firstName.isNotEmpty ? user.firstName : user.username}"
                      : "Good Day, User",
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header with back button and profile avatar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.arrow_back, size: 20, color: Colors.grey[700]),
                            ),
                          ),
                          Spacer(),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(Icons.person,
                                          size: 40, color: Colors.grey[600])
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[700],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.camera_alt,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(width: 48), // Balance the row
                        ],
                      ),
                      SizedBox(height: 24),
                      // Title and subtitle
                      Column(
                        children: [
                          Text(
                            "Edit Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Update your personal information",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField("First Name", _firstNameController),
                            _buildTextField("Last Name", _lastNameController),
                            _buildUsernameField(),
                            _buildTextField("Email", _emailController, enabled: false),
                            _buildPhoneNumberField(),
                            _buildBirthDateField(context),
                            _buildGenderDropdown(),
                            SizedBox(height: 24),
                            _buildSaveButton(context),
                          ],
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

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
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
              return "Contact number is required";
            }
            if (value.length != 11 || !value.startsWith("09")) {
              return "Contact number must be 11 digits and start with '09'";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Birth Date",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _birthController,
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                hintText: "Select your birth date",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Birth date is required";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
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
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
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
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm Update'),
                content: Text('Are you sure you want to update your profile information?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.amber[700]),
                    child: Text('Update'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(userServiceProvider).updateUserProfile(
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                username: _usernameController.text.trim(),
                email: _emailController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                birthDate: _birthController.text.trim(),
                gender: _selectedGender,
              );
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
    );
  }
}