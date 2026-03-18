class SavedLocation {
  final String id;
  final String label; // Home, Work, Other
  final String address;
  final double latitude;
  final double longitude;
  final String houseNo;
  final String? landmark; // Optional
  final String phoneNumber;

  SavedLocation({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.houseNo,
    this.landmark,
    required this.phoneNumber,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'houseNo': houseNo,
      'landmark': landmark,
      'phoneNumber': phoneNumber,
    };
  }

  // Create from JSON
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] ?? '',
      label: json['label'] ?? 'Other',
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      houseNo: json['houseNo'] ?? '',
      landmark: json['landmark'],
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  // Copy with method for updates
  SavedLocation copyWith({
    String? id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? houseNo,
    String? landmark,
    String? phoneNumber,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      houseNo: houseNo ?? this.houseNo,
      landmark: landmark ?? this.landmark,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
