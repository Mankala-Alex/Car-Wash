class AdvertisementModel {
  final String id;
  final String title;
  final String titleEn;
  final String titleAr;
  final String description;
  final String descriptionEn;
  final String descriptionAr;
  final String imageUrl;
  final String imageUrlSnake;
  final String status;
  final int displayOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.description,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.imageUrl,
    required this.imageUrlSnake,
    required this.status,
    required this.displayOrder,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      imageUrlSnake: json['image_url']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      displayOrder: int.tryParse(
            json['displayOrder']?.toString() ??
                json['display_order']?.toString() ??
                '0',
          ) ??
          0,
      startDate: _parseDate(json['startDate'] ?? json['start_date']),
      endDate: _parseDate(json['endDate'] ?? json['end_date']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
