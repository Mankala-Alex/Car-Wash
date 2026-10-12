import 'package:get/get.dart';

class Servicesmodel {
  Servicesmodel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.features,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  // Keep these for backward compatibility
  final String name;
  final String description;

  // Bilingual fields
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;

  final double price;
  final List<String> features;
  final bool isActive;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Servicesmodel.fromJson(Map<String, dynamic> json) {
    return Servicesmodel(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      nameEn: json["name_en"]?.toString() ?? "",
      nameAr: json["name_ar"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      descriptionEn: json["description_en"]?.toString() ?? "",
      descriptionAr: json["description_ar"]?.toString() ?? "",
      price: json["price"] is num ? (json["price"] as num).toDouble() : 0.0,
      features: json["features"] == null
          ? []
          : List<String>.from(
              (json["features"] as List).map(
                (x) => x.toString(),
              ),
            ),
      isActive: json["is_active"] ?? json["isActive"] ?? false,
      imageUrl: json["image_url"]?.toString() ?? "",
      createdAt: DateTime.tryParse(
        json["created_at"]?.toString() ?? "",
      ),
      updatedAt: DateTime.tryParse(
        json["updated_at"]?.toString() ?? "",
      ),
    );
  }

  // Get service name according to current app language
  String getLocalizedName() {
    final languageCode = Get.locale?.languageCode ?? 'en';

    if (languageCode.toLowerCase().startsWith('ar')) {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }

    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  // Get service description according to current app language
  String getLocalizedDescription() {
    final languageCode = Get.locale?.languageCode ?? 'en';

    if (languageCode.toLowerCase().startsWith('ar')) {
      return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    }

    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }
}
