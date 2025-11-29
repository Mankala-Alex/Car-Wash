class Servicesmodel {
  Servicesmodel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final List<String> features;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Servicesmodel.fromJson(Map<String, dynamic> json) {
    return Servicesmodel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] ?? 0,
      features: json["features"] == null
          ? []
          : List<String>.from(json["features"]!.map((x) => x)),
      isActive: json["isActive"] ?? false,
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "features": features.map((x) => x).toList(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
