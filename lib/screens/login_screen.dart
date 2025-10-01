import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_navigation_screen.dart';
import 'forgot_password_page.dart';
import 'enhanced_sign_up_screen.dart';
import '../services/user_service.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final supabase = Supabase.instance.client;

    // Debug: Log sign-in attempt
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    debugPrint('🔐 SIGN-IN ATTEMPT:');
    debugPrint('Email: $email');
    debugPrint('Password length: ${password.length}');
    debugPrint('Supabase client ready for sign-in');

    // Check if user exists in users table first
    try {
      debugPrint('🔍 Checking if user exists in users table...');
      final userCheck = await supabase
          .from('users')
          .select('email, id')
          .eq('email', email)
          .maybeSingle();

      if (userCheck != null) {
        debugPrint('✅ User found in users table: ${userCheck['id']}');
      } else {
        debugPrint('❌ User NOT found in users table');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking users table: $e');
    }

    try {
      debugPrint('🚀 Calling supabase.auth.signInWithPassword...');
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Debug: Log detailed response info
      debugPrint('Supabase signIn response: $response');
      try {
        debugPrint('Supabase signIn user: ${response.user}');
        debugPrint('Supabase signIn session: ${response.session}');
      } catch (_) {}

      // Check current client state after sign-in
      try {
        final currentUser = supabase.auth.currentUser;
        final currentSession = supabase.auth.currentSession;
        debugPrint('supabase.auth.currentUser: $currentUser');
        debugPrint('supabase.auth.currentSession: $currentSession');
      } catch (_) {}

      if (response.user != null) {
        await _saveCredentials();

        // Update last sign in time in database
        try {
          await supabase.from('users').update({
            'last_sign_in_at': DateTime.now().toIso8601String(),
          }).eq('id', response.user!.id);
          debugPrint('✅ Updated last sign in time');
        } catch (e) {
          debugPrint('⚠️ Failed to update last sign in time: $e');
        }

        // Sync user data from Supabase to local storage
        debugPrint('🔄 Attempting to sync user from Supabase...');
        try {
          await UserService().syncUserFromSupabase();
          debugPrint('✅ User sync completed successfully');
        } catch (e) {
          debugPrint('⚠️ Failed to sync user from Supabase: $e');
        }

        // Check if the user is an admin
        // Fetch user role from the users table
        final userId = response.user!.id;
        final userResponse = await supabase
            .from('users')
            .select('role')
            .eq('id', userId)
            .single();

        final isAdmin = userResponse['role'] == 'admin';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(isAdmin ? 'Welcome Admin!' : 'Welcome to FoodLoop PH!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
<<<<<<< HEAD
        debugPrint('✅ SUCCESS: Navigating to MainNavigationScreen');
=======

>>>>>>> 3c5e93d5baa68a56df3bcf5dadfab265540a68d2
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin
                ? const AdminDashboardScreen()
                : const MainNavigationScreen(),
          ),
        );
      } else {
        debugPrint('❌ FAILED: response.user is null');
        setState(() {
          _errorMessage =
              'Invalid email or password. Please check your credentials and try again.';
        });
      }
    } on AuthException catch (e) {
      debugPrint('🚨 AuthException caught: ${e.message}');
      debugPrint('AuthException statusCode: ${e.statusCode}');
      debugPrint('AuthException full error: $e');
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e, stackTrace) {
      debugPrint('💥 Unexpected exception caught: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Unexpected error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Basic format check only - don't reveal if email exists
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Don't reveal password length requirements for security
    return null;
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
                        SizedBox(height: 30), // Move logo higher
                        // Simple Logo Section with Gradient
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
                                              .shade50, // Light yellowish background
                                      Colors.amber[50] ??
                                          Colors.amber
                                              .shade50, // Very light amber (fixed from amber[25])
                                      Colors.yellow[100] ??
                                          Colors.yellow
                                              .shade100, // Slightly deeper yellow
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.1),
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
                                          color: Colors.black, // Food in black
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
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Welcome back to FoodLoop PH',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        // Security Notice & Error Message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red[200]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.security,
                                    color: Colors.red[600], size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              borderSide: BorderSide(color: Colors.grey[300]!),
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
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
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
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
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
                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) =>
                                        setState(() => _rememberMe = value!),
                                    activeColor: Colors.orange[400],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        // Login Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
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
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 40),
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EnhancedSignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ), // Added missing closing parenthesis for Container
      ),
    );
  }
}
