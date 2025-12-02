class Servicesmodel {
  Servicesmodel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final bool isActive;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Servicesmodel.fromJson(Map<String, dynamic> json) {
    return Servicesmodel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: (json["price"] is int)
          ? (json["price"] as int).toDouble()
          : (json["price"] is double)
              ? json["price"]
              : 0.0,
      features: json["features"] == null
          ? []
          : List<String>.from(json["features"].map((x) => x)),
      isActive: json["is_active"] ?? false,       // FIXED
      imageUrl: json["image_url"] ?? "",          // FIXED
      createdAt: DateTime.tryParse(json["created_at"] ?? ""), // FIXED
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""), // FIXED
    );
  }
}
