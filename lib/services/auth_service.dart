import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../utils/password_validator.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _sessionToken;
  Timer? _sessionTimer;

  // User database - starts empty, users must register
  final Map<String, Map<String, dynamic>> _users = {};

  // OTP storage (in production, this would be server-side)
  final Map<String, Map<String, dynamic>> _otpStorage = {};

  // Rate limiting for failed login attempts
  final Map<String, Map<String, dynamic>> _loginAttempts = {};

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;

  // Generate OTP
  String _generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Send OTP via email (mock implementation)
  Future<bool> sendOTPToEmail(String email) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      final otp = _generateOTP();
      _otpStorage[email] = {
        'otp': otp,
        'timestamp': DateTime.now(),
        'attempts': 0,
      };
      
      // In production, send actual email here
      print('OTP sent to $email: $otp'); // For testing purposes
      return true;
    } catch (e) {
      return false;
    }
  }

  // Send OTP via SMS (mock implementation)
  Future<bool> sendOTPToPhone(String phone) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      final otp = _generateOTP();
      _otpStorage[phone] = {
        'otp': otp,
        'timestamp': DateTime.now(),
        'attempts': 0,
      };
      
      // In production, send actual SMS here
      print('OTP sent to $phone: $otp'); // For testing purposes
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String identifier, String enteredOTP) async {
    try {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      
      final otpData = _otpStorage[identifier];
      if (otpData == null) return false;
      
      final storedOTP = otpData['otp'];
      final timestamp = otpData['timestamp'] as DateTime;
      final attempts = otpData['attempts'] as int;
      
      // Check if OTP is expired (5 minutes)
      if (DateTime.now().difference(timestamp).inMinutes > 5) {
        _otpStorage.remove(identifier);
        return false;
      }
      
      // Check if too many attempts
      if (attempts >= 3) {
        _otpStorage.remove(identifier);
        return false;
      }
      
      // Increment attempts
      _otpStorage[identifier]!['attempts'] = attempts + 1;
      
      // Verify OTP
      if (storedOTP == enteredOTP) {
        _otpStorage.remove(identifier); // Remove used OTP
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      final emailKey = email.toLowerCase();
      
      // Check for rate limiting
      if (_isAccountLocked(emailKey)) {
        return AuthResult(success: false, message: 'Your account is temporarily locked due to multiple failed login attempts. Please try again later.');
      }
      
      // Check for empty fields
      if (email.trim().isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'Please fill in all required fields.');
      }
      
      // Validate email format - must be Gmail
      if (!email.endsWith('@gmail.com')) {
        return AuthResult(success: false, message: 'Only Gmail addresses (@gmail.com) are allowed');
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
        return AuthResult(success: false, message: 'Please enter a valid Gmail address');
      }
      
      // Check if user exists and validate credentials
      final userData = _users[emailKey];
      if (userData == null || userData['password'] != password) {
        _recordFailedAttempt(emailKey);
        return AuthResult(success: false, message: 'Invalid credentials. Please try again.');
      }
      
      // Check if account is verified
      if (!userData['isVerified']) {
        return AuthResult(success: false, message: 'Account not verified. Please check your email.');
      }
      
      // Clear failed attempts on successful login
      _loginAttempts.remove(emailKey);
      
      // Generate session token
      _sessionToken = _generateSessionToken();
      _currentUser = email;
      _isAuthenticated = true;
      
      // Start session timer (24 hours)
      _startSessionTimer();
      
      notifyListeners();
      
      return AuthResult(
        success: true, 
        message: 'Login successful',
        user: UserData(
          email: email,
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          phone: userData['phone'],
        ),
      );
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred. Please try again.');
    }
  }

  // Check if account is temporarily locked
  bool _isAccountLocked(String email) {
    final attempts = _loginAttempts[email];
    if (attempts == null) return false;
    
    final count = attempts['count'] as int;
    final lastAttempt = attempts['lastAttempt'] as DateTime;
    
    // Lock account for 15 minutes after 5 failed attempts
    if (count >= 5) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
      return timeSinceLastAttempt.inMinutes < 15;
    }
    
    return false;
  }

  // Record failed login attempt
  void _recordFailedAttempt(String email) {
    final now = DateTime.now();
    final attempts = _loginAttempts[email];
    
    if (attempts == null) {
      _loginAttempts[email] = {
        'count': 1,
        'lastAttempt': now,
      };
    } else {
      final lastAttempt = attempts['lastAttempt'] as DateTime;
      final timeSinceLastAttempt = now.difference(lastAttempt);
      
      // Reset count if more than 15 minutes have passed
      if (timeSinceLastAttempt.inMinutes >= 15) {
        _loginAttempts[email] = {
          'count': 1,
          'lastAttempt': now,
        };
      } else {
        _loginAttempts[email] = {
          'count': (attempts['count'] as int) + 1,
          'lastAttempt': now,
        };
      }
    }
  }

  // Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      // Check if user already exists
      if (_users.containsKey(email.toLowerCase())) {
        return AuthResult(success: false, message: 'Email already registered');
      }
      
      // Validate email format - must be Gmail
      if (!email.endsWith('@gmail.com')) {
        return AuthResult(success: false, message: 'Only Gmail addresses (@gmail.com) are allowed');
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
        return AuthResult(success: false, message: 'Please enter a valid Gmail address');
      }
      
      // Validate first name - no numbers allowed
      if (firstName.trim().isEmpty) {
        return AuthResult(success: false, message: 'First name is required');
      }
      if (RegExp(r'[0-9]').hasMatch(firstName)) {
        return AuthResult(success: false, message: 'First name cannot contain numbers');
      }
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
        return AuthResult(success: false, message: 'First name can only contain letters and spaces');
      }
      
      // Validate last name - no numbers allowed
      if (lastName.trim().isEmpty) {
        return AuthResult(success: false, message: 'Last name is required');
      }
      if (RegExp(r'[0-9]').hasMatch(lastName)) {
        return AuthResult(success: false, message: 'Last name cannot contain numbers');
      }
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
        return AuthResult(success: false, message: 'Last name can only contain letters and spaces');
      }
      
      // Validate password strength using new validator
      final passwordValidation = PasswordValidator.validate(password);
      if (!passwordValidation.isValid) {
        final unmetRequirements = passwordValidation.requirements
            .where((req) => !req.isMet)
            .map((req) => req.text)
            .join(', ');
        return AuthResult(success: false, message: 'Password requirements not met: $unmetRequirements');
      }
      
      // Validate phone number
      if (!RegExp(r'^\d{11}$').hasMatch(phone)) {
        return AuthResult(success: false, message: 'Invalid phone number format');
      }
      
      // Create new user
      _users[email.toLowerCase()] = {
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'isVerified': false, // Require verification
      };
      
      return AuthResult(
        success: true, 
        message: 'Account created successfully! Please verify your email.',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Registration failed. Please try again.');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      final userData = _users[email.toLowerCase()];
      if (userData == null) return false;
      
      // Validate new password using password validator
      final passwordValidation = PasswordValidator.validate(newPassword);
      if (!passwordValidation.isValid) return false;
      
      // Update password
      _users[email.toLowerCase()]!['password'] = newPassword;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _sessionToken = null;
    _sessionTimer?.cancel();
    notifyListeners();
  }

  // Check if session is expired
  bool isSessionExpired() {
    return !_isAuthenticated && _sessionToken != null;
  }

  // Handle session expiry
  void handleSessionExpiry() {
    if (_isAuthenticated) {
      logout();
      // This should trigger a UI update to show session expired message
    }
  }

  // Generate session token
  String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'session_${timestamp}_$random';
  }

  // Start session timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(hours: 24), () {
      handleSessionExpiry();
    });
  }

  // Extend session
  void extendSession() {
    if (_isAuthenticated) {
      _startSessionTimer();
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _users.containsKey(email.toLowerCase());
  }

  // Verify account (email verification)
  Future<bool> verifyAccount(String email) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      
      final userData = _users[email.toLowerCase()];
      if (userData == null) return false;
      
      _users[email.toLowerCase()]!['isVerified'] = true;
      return true;
    } catch (e) {
      return false;
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final UserData? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class UserData {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  UserData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });
}
