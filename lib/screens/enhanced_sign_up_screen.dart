import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'dart:async';

class EnhancedSignUpScreen extends StatefulWidget {
  const EnhancedSignUpScreen({super.key});

  @override
  _EnhancedSignUpScreenState createState() => _EnhancedSignUpScreenState();
}

class _EnhancedSignUpScreenState extends State<EnhancedSignUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Enhanced validation states
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  String _usernameMessage = '';
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    if (strength <= 0.3) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 0.6) {
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else if (strength <= 0.8) {
      strengthText = 'Good';
      strengthColor = Colors.blue;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  void _checkUsernameAvailability(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() => _isCheckingUsername = true);

      Timer(Duration(seconds: 1), () {
        final unavailableUsernames = [
          'admin',
          'user',
          'test',
          'foodloop',
          'demo'
        ];
        final isAvailable =
            !unavailableUsernames.contains(username.toLowerCase());

        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = isAvailable;
          _usernameMessage = isAvailable
              ? 'Username is available!'
              : 'Username is already taken';
        });
      });
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    // Only allow letters and spaces, no numbers
    if (!RegExp(r'^[a-zA-Z]+([a-zA-Z\s]*[a-zA-Z])?$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    if (!_isUsernameAvailable && !_isCheckingUsername) {
      return 'Username is already taken';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Philippine phone number validation (09xxxxxxxxx, exactly 11 digits)
    if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
      return 'Phone number must start with 09 and be exactly 11 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              _passwordStrengthText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _passwordStrengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to the Terms and Conditions'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please choose a different username'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Check if user already exists
      try {
        await supabase
            .from('users')
            .select()
            .eq('email', email)
            .single();
            
        // If we get here, user exists
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This email is already registered. Please sign in instead.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
        
      } catch (_) {
        // No user found, continue with registration
      }

      // 1. Register user with Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': _usernameController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
        }
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Sign up failed.');

      // Insert user details into the Supabase users table
      await supabase.from('users').insert({
        'id': user.id,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      });

      // Do NOT insert into users table here. Wait for email verification and login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Registration successful! Please check your email to verify your account.'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1), // Light cream
              Color(0xFFE8F5E8), // Very light green
              Color(0xFFF1F8E9), // Light green-white
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.grey[800], size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400, // Responsive max-width for forms
                            minWidth: 280, // Minimum width for mobile
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 10), // Move logo higher
                                // Simple Logo Section
                                Center(
                                  child: Column(
                                    children: [
                                      // FoodLoop PH Logo with Correct Colors
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.yellow[50] ??
                                                  Colors.yellow
                                                      .shade50, // Safe fallback
                                              Colors.amber[50] ??
                                                  Colors.amber
                                                      .shade50, // Changed from amber[25]
                                              Colors.yellow[100] ??
                                                  Colors.yellow
                                                      .shade100, // Safe fallback
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                            BoxShadow(
                                              color: Colors.yellow
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Food",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .black, // Food in black
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Loop",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber[700] ??
                                                      Colors.amber
                                                          .shade700, // Loop in yellowish
                                                ),
                                              ),
                                              TextSpan(
                                                text: " PH",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.amber[700] ??
                                                      Colors.amber
                                                          .shade700, // PH in yellowish
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12), // Reduced spacing
                                      Text(
                                        "Share Food. Fight Waste. Feed Communities.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 20), // Reduced spacing
                                      Text(
                                        'Sign Up',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Join FoodLoop PH and make a difference',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32),

                                // Name Fields Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        validator: _validateName,
                                        style:
                                            GoogleFonts.poppins(fontSize: 16),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-zA-Z\s]')),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'First Name',
                                          hintText: 'Enter your first name',
                                          prefixIcon: Icon(Icons.person_outline,
                                              color: Colors.grey[600]),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.orange[400]!,
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lastNameController,
                                        validator: _validateName,
                                        style:
                                            GoogleFonts.poppins(fontSize: 16),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-zA-Z\s]')),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'Last Name',
                                          hintText: 'Enter your last name',
                                          prefixIcon: Icon(Icons.person_outline,
                                              color: Colors.grey[600]),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.orange[400]!,
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email address',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange[400]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Username Field
                                TextFormField(
                                  controller: _usernameController,
                                  validator: _validateUsername,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _checkUsernameAvailability(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Choose a unique username',
                                    prefixIcon: Icon(Icons.alternate_email,
                                        color: Colors.grey[600]),
                                    suffixIcon: _isCheckingUsername
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          )
                                        : _usernameController.text.isNotEmpty
                                            ? Icon(
                                                _isUsernameAvailable
                                                    ? Icons.check_circle
                                                    : Icons.error,
                                                color: _isUsernameAvailable
                                                    ? Colors.green
                                                    : Colors.red,
                                              )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange[400]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    helperText:
                                        _usernameController.text.isNotEmpty
                                            ? _usernameMessage
                                            : null,
                                    helperStyle: GoogleFonts.poppins(
                                      color: _isUsernameAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Phone Field
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: 'e.g., 09123456789',
                                    prefixIcon: Icon(Icons.phone_outlined,
                                        color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange[400]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: _validatePassword,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  onChanged: (value) =>
                                      _checkPasswordStrength(value),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'At least 8 characters',
                                    prefixIcon: Icon(Icons.lock_outlined,
                                        color: Colors.grey[600]),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword =
                                            !_obscurePassword);
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange[400]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                ),
                                if (_passwordController.text.isNotEmpty)
                                  _buildPasswordStrengthIndicator(),
                                SizedBox(height: 20),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  validator: _validateConfirmPassword,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    hintText: 'Re-enter your password',
                                    prefixIcon: Icon(Icons.lock_outlined,
                                        color: Colors.grey[600]),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureConfirmPassword =
                                            !_obscureConfirmPassword);
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange[400]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Terms and Conditions
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _agreedToTerms,
                                        onChanged: (value) => setState(() =>
                                            _agreedToTerms = value ?? false),
                                        activeColor: Colors.orange[400],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showTermsAndConditions(context),
                                        child: Text(
                                          'I agree to the Terms and Conditions',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.orange[700],
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32),

                                // Sign Up Button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[400],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Sign Up',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 32),

                                // Sign In Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.orange[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ), // Form closing
                        ), // ConstrainedBox closing
                      ), // SingleChildScrollView closing
                    ), // Center closing
                  ), // FadeTransition closing
                ), // SlideTransition closing
              ), // Expanded closing
            ], // Column closing
          ), // SafeArea child closing
        ), // Container child closing
      ), // body parameter closing
    ); // Scaffold closing
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms & Conditions',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FoodLoop PH Terms of Service',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Last updated: ${DateTime.now().year}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTermsSection('1. ACCEPTANCE OF TERMS',
                      'By accessing and using FoodLoop PH, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.'),
                  _buildTermsSection('2. FOOD SAFETY & RESPONSIBILITY',
                      'Users are solely responsible for the safety, quality, and condition of food items they offer or consume through our platform. FoodLoop PH does not guarantee the safety or quality of food items. Users must comply with local health regulations and use their best judgment when sharing or consuming food. We strongly recommend checking expiration dates, storage conditions, and allergen information.'),
                  _buildTermsSection('3. USER CONDUCT',
                      'Users must: (a) Provide accurate and truthful information, (b) Use the platform only for lawful purposes, (c) Respect other users and maintain a positive community environment, (d) Not share unsafe, expired, or contaminated food, (e) Not engage in commercial food sales without proper permits, (f) Report any safety concerns immediately.'),
                  _buildTermsSection('4. PRIVACY POLICY',
                      'We collect and use personal information in accordance with Philippine Data Privacy Act of 2012. This includes your name, contact information, location data, and usage patterns. We do not share personal information with third parties except as required by law or with your explicit consent. Users have the right to access, correct, or delete their personal data.'),
                  _buildTermsSection('5. LIABILITY DISCLAIMER',
                      'FoodLoop PH is a platform that facilitates food sharing between users. We are not responsible for: (a) Food-related illnesses or injuries, (b) Property damage or loss, (c) User disputes or disagreements, (d) The quality, safety, or legality of food items, (e) User compliance with local regulations. Users participate at their own risk and agree to hold FoodLoop PH harmless from any claims.'),
                  _buildTermsSection('6. INTELLECTUAL PROPERTY',
                      'All content, features, and functionality of FoodLoop PH are owned by us and protected by international copyright, trademark, and other intellectual property laws. Users may not reproduce, distribute, or create derivative works without written permission.'),
                  _buildTermsSection('7. ACCOUNT TERMINATION',
                      'We reserve the right to suspend or terminate user accounts that violate these terms, engage in unsafe practices, or disrupt the community. Users may delete their accounts at any time through the app settings.'),
                  _buildTermsSection('8. MODIFICATIONS',
                      'We reserve the right to modify these terms at any time. Users will be notified of significant changes via email or app notifications. Continued use after modifications constitutes acceptance of new terms.'),
                  _buildTermsSection('9. GOVERNING LAW',
                      'These terms are governed by the laws of the Republic of the Philippines. Any disputes will be resolved through arbitration in Metro Manila, Philippines.'),
                  _buildTermsSection('10. CONTACT INFORMATION',
                      'For questions about these terms, contact us at legal@foodloopph.com or through our in-app support system.'),
                  SizedBox(height: 16),
                  Text(
                    'By using FoodLoop PH, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'I Understand',
                style: GoogleFonts.poppins(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
