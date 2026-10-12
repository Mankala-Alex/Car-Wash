import 'package:get/get.dart';

class LegalDocumentModel {
  final String id;
  final String type;

  final String titleEn;
  final String contentEn;

  final String titleAr;
  final String contentAr;

  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LegalDocumentModel({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.contentEn,
    required this.titleAr,
    required this.contentAr,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      titleEn: json["title_en"]?.toString() ?? "",
      contentEn: json["content_en"]?.toString() ?? "",
      titleAr: json["title_ar"]?.toString() ?? "",
      contentAr: json["content_ar"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      createdAt: DateTime.tryParse(
        json["created_at"]?.toString() ?? "",
      ),
      updatedAt: DateTime.tryParse(
        json["updated_at"]?.toString() ?? "",
      ),
    );
  }

  String getLocalizedTitle() {
    final languageCode = Get.locale?.languageCode ?? 'en';

    if (languageCode.toLowerCase().startsWith('ar')) {
      return titleAr.isNotEmpty ? titleAr : titleEn;
    }

    return titleEn.isNotEmpty ? titleEn : titleAr;
  }

  String getLocalizedContent() {
    final languageCode = Get.locale?.languageCode ?? 'en';

    if (languageCode.toLowerCase().startsWith('ar')) {
      return contentAr.isNotEmpty ? contentAr : contentEn;
    }

    return contentEn.isNotEmpty ? contentEn : contentAr;
  }
}
