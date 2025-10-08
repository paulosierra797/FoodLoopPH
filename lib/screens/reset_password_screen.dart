import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String accessToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.accessToken,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Password strength indicators
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  late AnimationController _animationController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _resetSuccessful = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _successController = AnimationController(
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

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
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

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Update password using the session from OTP verification
      final response = await supabase.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text.trim(),
        ),
      );

      if (response.user != null) {
        // Password reset successful
        setState(() {
          _resetSuccessful = true;
        });
        _successController.forward();

        // Auto-navigate to login after success animation
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          }
        });
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1), // Light cream
              Color(0xFFFFE082), // Light amber
              Color(0xFFE8F5E8), // Very light green
              Color(0xFFF1F8E9), // Light green-white
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button (only show if not successful)
              if (!_resetSuccessful)
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _resetSuccessful
                        ? _buildSuccessView()
                        : _buildResetForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40),

        // Illustration
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_reset,
              size: 60,
              color: Colors.amber[700],
            ),
          ),
        ),

        SizedBox(height: 40),

        // Title and subtitle
        Text(
          "Create new\npassword",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            height: 1.2,
          ),
        ),
        SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            children: [
              TextSpan(
                  text:
                      "Your new password must be different from your previous password for "),
              TextSpan(
                text: widget.email,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
              TextSpan(text: "."),
            ],
          ),
        ),

        SizedBox(height: 40),

        // Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              // New Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  validator: _validatePassword,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey[800]),
                  onChanged: _checkPasswordStrength,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 14),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.amber[600]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(
                            () => _obscureNewPassword = !_obscureNewPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
              ),

              if (_newPasswordController.text.isNotEmpty)
                _buildPasswordStrengthIndicator(),

              SizedBox(height: 20),

              // Confirm Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey[800]),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 14),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.amber[600]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.amber.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Reset Password",
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

        SizedBox(height: 40),

        // Password Requirements
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Password Requirements:",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 8),
              _buildRequirement("At least 8 characters",
                  _newPasswordController.text.length >= 8),
              _buildRequirement("One uppercase letter",
                  RegExp(r'[A-Z]').hasMatch(_newPasswordController.text)),
              _buildRequirement("One lowercase letter",
                  RegExp(r'[a-z]').hasMatch(_newPasswordController.text)),
              _buildRequirement("One number",
                  RegExp(r'[0-9]').hasMatch(_newPasswordController.text)),
            ],
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.15), // Add top spacing
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.check,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: 40),

        Text(
          'Password Reset\nSuccessful!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
            height: 1.2,
          ),
        ),

        SizedBox(height: 16),

        Text(
          'Your password has been successfully reset. You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),

        SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.green.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              "Back to Login",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 40), // Add bottom spacing
      ],
    );
  }
}
