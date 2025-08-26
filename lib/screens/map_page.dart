import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng _currentLocation =
      LatLng(14.2639, 120.9364); // Default: Dasmariñas, Cavite
  bool _isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadNearbyUsers();
  }

  Future<void> _loadUserLocation() async {
    final userService = Provider.of<UserService>(context, listen: false);

    if (userService.currentUser != null &&
        userService.currentUser!.latitude != null &&
        userService.currentUser!.longitude != null) {
      setState(() {
        _currentLocation = LatLng(
          userService.currentUser!.latitude!,
          userService.currentUser!.longitude!,
        );
        _isLocationLoading = false;
      });
    } else {
      // Try to get current location
      await userService.updateUserLocation();
      if (userService.currentUser?.latitude != null) {
        setState(() {
          _currentLocation = LatLng(
            userService.currentUser!.latitude!,
            userService.currentUser!.longitude!,
          );
        });
      }
      setState(() {
        _isLocationLoading = false;
      });
    }

    _updateMarkers();
  }

  void _loadNearbyUsers() {
    final userService = Provider.of<UserService>(context, listen: false);
    userService.loadNearbyUsers();
  }

  void _updateMarkers() {
    final userService = Provider.of<UserService>(context, listen: false);
    Set<Marker> markers = {};

    // Add current user marker
    if (userService.currentUser != null &&
        userService.currentUser!.latitude != null &&
        userService.currentUser!.longitude != null &&
        userService.currentUser!.isLocationSharingEnabled) {
      markers.add(
        Marker(
          markerId: MarkerId('current_user'),
          position: LatLng(
            userService.currentUser!.latitude!,
            userService.currentUser!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'You',
            snippet: userService.currentUser!.address ?? 'Your Location',
          ),
        ),
      );
    }

    // Add nearby users markers
    for (User user in userService.nearbyUsers) {
      if (user.isLocationSharingEnabled &&
          user.latitude != null &&
          user.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(user.id),
            position: LatLng(user.latitude!, user.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: user.fullName,
              snippet: user.address ?? 'Location shared',
              onTap: () => _showUserDetails(user),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber[700],
              child: Text(
                user.initials,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              user.fullName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '@${user.username}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.amber[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.address ?? 'Location shared',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Last seen ${_formatLastSeen(user.lastLocationUpdate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to user's food listings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('View ${user.firstName}\'s food listings'),
                  ),
                );
              },
              child: Text(
                'View Food Listings',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'recently';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToCurrentLocation() async {
    final userService = Provider.of<UserService>(context, listen: false);
    await userService.updateUserLocation();

    if (userService.currentUser?.latitude != null) {
      final newLocation = LatLng(
        userService.currentUser!.latitude!,
        userService.currentUser!.longitude!,
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 15),
      );

      setState(() {
        _currentLocation = newLocation;
      });

      _updateMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Map',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.amber[700],
        elevation: 0,
        actions: [
          Consumer<UserService>(
            builder: (context, userService, child) {
              return Switch(
                value:
                    userService.currentUser?.isLocationSharingEnabled ?? false,
                onChanged: (value) async {
                  await userService.toggleLocationSharing(value);
                  _updateMarkers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Location sharing enabled'
                            : 'Location sharing disabled',
                      ),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.black87,
              );
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLocationLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber[700]),
                  SizedBox(height: 16),
                  Text(
                    'Loading your location...',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              _loadNearbyUsers();
              _updateMarkers();

              // Show test notification
              final notificationService =
                  Provider.of<NotificationService>(context, listen: false);
              notificationService.showNewFoodNearbyNotification(
                foodName: 'Fresh Sandwiches',
                donorName: 'Nearby Cafe',
                distance: '0.3km',
              );
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.refresh, color: Colors.amber[700]),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.amber[700],
            child: Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
