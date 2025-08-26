// ProfilePage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supabase_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  String _sex = '';

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    return response;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found'));
          }
          final data = snapshot.data!;
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _birthController.text = data['birth'] ?? '';
          _sex = data['sex'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.edit, size: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _birthController,
                                decoration: InputDecoration(
                                  labelText: 'Birth',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _sex.isNotEmpty ? _sex : null,
                                decoration: InputDecoration(labelText: 'Sex', border: OutlineInputBorder()),
                                items: ['Male', 'Female', 'Other']
                                    .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _sex = val ?? '';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              final user = supabase.auth.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No user found.')),
                                );
                                return;
                              }
                              if (_formKey.currentState!.validate()) {
                                final updateData = {
                                  'first_name': _firstNameController.text.trim(),
                                  'last_name': _lastNameController.text.trim(),
                                  'username': _usernameController.text.trim(),
                                  'email': _emailController.text.trim(),
                                  'phone_number': _phoneController.text.trim(),
                                  'birth': _birthController.text.trim(),
                                  'sex': _sex,
                                };
                                supabase
                                    .from('users')
                                    .update(updateData)
                                    .eq('id', user.id)
                                    .execute()
                                    .then((response) {
                                  if (response.status == 200 || response.status == 204) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Profile updated successfully!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to update profile.')),
                                    );
                                  }
                                });
                              }
                            },
                            child: Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
