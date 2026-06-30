class PlaceDetailsModel {
  final double latitude;
  final double longitude;
  final String address;
  final String name;

  PlaceDetailsModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.name,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsModel(
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      address: json["address"] ?? "",
      name: json["name"] ?? "",
    );
  }
}
