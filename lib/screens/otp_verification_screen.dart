import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = '';
    });

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final supabase = Supabase.instance.client;

      // Verify OTP for password recovery
      final response = await supabase.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.user != null && response.session != null) {
        // OTP verified successfully, navigate to password reset
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: widget.email,
                accessToken: response.session!.accessToken,
              ),
            ),
          );
        }
      } else {
        _showError('Invalid OTP code. Please try again.');
      }
    } catch (e) {
      _showError('Invalid OTP code. Please check and try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    // Clear all OTP fields on error
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _resendOTP() async {
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resetPasswordForEmail(
        widget.email,
        redirectTo: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('New OTP sent to your email'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
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
                                  Icons.mail_lock,
                                  size: 60,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Title and subtitle
                            Text(
                              "Verify your\nemail",
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
                                  TextSpan(text: "We sent a 6-digit code to "),
                                  TextSpan(
                                    text: widget.email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  TextSpan(
                                      text: ". Enter it below to continue."),
                                ],
                              ),
                            ),

                            SizedBox(height: 40),

                            // OTP Input Fields
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) {
                                      return Container(
                                        width: 45,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _errorMessage.isNotEmpty
                                                ? Colors.red
                                                : _controllers[index]
                                                        .text
                                                        .isNotEmpty
                                                    ? Colors.amber[600]!
                                                    : Colors.grey[300]!,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          maxLength: 1,
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                          decoration: InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (value) =>
                                              _onDigitChanged(index, value),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),

                            if (_errorMessage.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red[600], size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 40),

                            // Verify Button
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
                                onPressed: _isLoading ? null : _verifyOTP,
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "Verify Code",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // Resend Code
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Didn't receive the code?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _isResending ? null : _resendOTP,
                                    child: _isResending
                                        ? SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.amber[700]!,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            "Resend Code",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),

                            Spacer(),

                            // Footer
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Want to try a different email? ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Go Back",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.amber[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
