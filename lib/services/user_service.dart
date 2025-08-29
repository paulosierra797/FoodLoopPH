import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;
  List<User> _nearbyUsers = [];
  bool _isLocationServiceEnabled = false;

  User? get currentUser => _currentUser;
  List<User> get nearbyUsers => _nearbyUsers;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;

  // Initialize user service
  Future<void> initialize() async {
    await _loadUserFromStorage();
    await _checkLocationPermission();
  }

  // Load user from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  // Save user to local storage
  Future<void> _saveUserToStorage() async {
    try {
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final userJson = jsonEncode(_currentUser!.toJson());
        await prefs.setString('current_user', userJson);
      }
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  // Sign up user
  Future<void> signUpUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
    );

    await _saveUserToStorage();
    notifyListeners();
  }

  // Login user (for demo purposes, we'll just load from storage)
  Future<bool> loginUser(String email, String password) async {
    await _loadUserFromStorage();
    return _currentUser != null;
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? birthDate,
    String? gender,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
      );

      await _saveUserToStorage();
      notifyListeners();
    }
  }

  // Location related methods
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isLocationServiceEnabled = false;
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isLocationServiceEnabled = false;
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isLocationServiceEnabled = false;
      notifyListeners();
      return;
    }

    _isLocationServiceEnabled = true;
    notifyListeners();
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    if (!_isLocationServiceEnabled) {
      await _checkLocationPermission();
    }

    if (!_isLocationServiceEnabled) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Update user location
  Future<void> updateUserLocation() async {
    if (_currentUser == null) return;

    final position = await getCurrentLocation();
    if (position != null) {
      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          address = '${placemark.locality}, ${placemark.administrativeArea}';
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
      }

      _currentUser = _currentUser!.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        lastLocationUpdate: DateTime.now(),
      );

      await _saveUserToStorage();
      notifyListeners();
    }
  }

  // Update user address manually
  Future<void> updateUserAddress(String address) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        address: address,
      );

      await _saveUserToStorage();
      notifyListeners();
    }
  }

  // Toggle location sharing
  Future<void> toggleLocationSharing(bool enabled) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isLocationSharingEnabled: enabled,
      );

      if (enabled) {
        await updateUserLocation();
      }

      await _saveUserToStorage();
      notifyListeners();
    }
  }

  // Simulate getting nearby users (in a real app, this would be an API call)
  void loadNearbyUsers() {
    // Demo data for nearby users
    _nearbyUsers = [
      User(
        id: '2',
        firstName: 'Carlos',
        lastName: 'Santos',
        username: 'carlossantos',
        email: 'carlos@example.com',
        phoneNumber: '09876543210',
        isLocationSharingEnabled: true,
        latitude: 14.2639, // Dasmariñas area
        longitude: 120.9364,
        address: 'Dasmariñas, Cavite',
        lastLocationUpdate: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      User(
        id: '3',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        username: 'juandc',
        email: 'juan@example.com',
        phoneNumber: '09555123456',
        isLocationSharingEnabled: true,
        latitude: 14.2700,
        longitude: 120.9400,
        address: 'Imus, Cavite',
        lastLocationUpdate: DateTime.now().subtract(Duration(minutes: 2)),
      ),
      User(
        id: '4',
        firstName: 'Ana',
        lastName: 'Rodriguez',
        username: 'anarodriguez',
        email: 'ana@example.com',
        phoneNumber: '09333789012',
        isLocationSharingEnabled: true,
        latitude: 14.2580,
        longitude: 120.9300,
        address: 'Bacoor, Cavite',
        lastLocationUpdate: DateTime.now().subtract(Duration(minutes: 10)),
      ),
    ];
    notifyListeners();
  }

  // Sign out user
  Future<void> signOut() async {
    _currentUser = null;
    _nearbyUsers = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }
}
