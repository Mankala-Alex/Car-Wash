class InstoresModel {
  InstoresModel({
    required this.id,
    required this.partnerCode,
    required this.companyName,
    required this.ownerName,
    required this.crNumber,
    required this.phoneNumber,
    required this.streetName,
    required this.district,
    required this.city,
    required this.country,
    required this.zip,
    required this.documents,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  final String id;
  final String partnerCode;
  final String companyName;
  final String ownerName;
  final String crNumber;
  final String phoneNumber;
  final String streetName;
  final String district;
  final String city;
  final String country;
  final String zip;
  final dynamic documents;
  final Location? location;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String imageUrl;

  factory InstoresModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json["location"] is Map
        ? json["location"] as Map<String, dynamic>
        : null;
    final imageValue = json["image_url"] ?? json["company_image"] ?? "";

    return InstoresModel(
      id: json["id"] ?? "",
      partnerCode: json["partner_code"] ?? "",
      companyName: json["company_name"] ?? "",
      ownerName: json["owner_name"] ?? "",
      crNumber: json["cr_number"] ?? "",
      phoneNumber: json["phone_number"] ?? "",
      streetName: json["street_name"] ?? "",
      district: json["district"] ?? "",
      city: json["city"] ?? "",
      country: json["country"] ?? "",
      zip: json["zip"] ?? json["zip_code"] ?? "",
      documents: json["documents"] ?? [],
      location: locationJson == null ? null : Location.fromJson(locationJson),
      status: (json["status"] ?? "").toString(),
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      imageUrl: imageValue.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "partner_code": partnerCode,
        "company_name": companyName,
        "owner_name": ownerName,
        "cr_number": crNumber,
        "phone_number": phoneNumber,
        "street_name": streetName,
        "district": district,
        "city": city,
        "country": country,
        "zip": zip,
        "documents": documents,
        "location": location?.toJson(),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "image_url": imageUrl,
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json["lat"] as num?)?.toDouble() ?? 0.0,
      lng: (json["lng"] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}
