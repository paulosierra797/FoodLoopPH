class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? birthDate;
  final String? gender;
  final bool isLocationSharingEnabled;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? lastLocationUpdate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.birthDate,
    this.gender,
    this.isLocationSharingEnabled = false,
    this.latitude,
    this.longitude,
    this.address,
    this.lastLocationUpdate,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? birthDate,
    String? gender,
    bool? isLocationSharingEnabled,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? lastLocationUpdate,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      isLocationSharingEnabled:
          isLocationSharingEnabled ?? this.isLocationSharingEnabled,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'gender': gender,
      'isLocationSharingEnabled': isLocationSharingEnabled,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      isLocationSharingEnabled: json['isLocationSharingEnabled'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      lastLocationUpdate: json['lastLocationUpdate'] != null
          ? DateTime.parse(json['lastLocationUpdate'])
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
}
