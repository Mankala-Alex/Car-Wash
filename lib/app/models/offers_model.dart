class Offersmodel {
  Offersmodel({
    required this.id,
    required this.offerCode,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.discountType,
    required this.discountValue,
    required this.serviceId,
    required this.serviceIds,
    required this.serviceName,
    required this.expiryDays,
    required this.terms,
    required this.termsEn,
    required this.termsAr,
    required this.daysOfWeek,
    required this.slotStartTimes,
    required this.maxUsesPerCustomer,
    required this.maxTotalUses,
    required this.imageUrl,
    required this.popupEnabled,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String offerCode;
  final String title;
  final String titleEn;
  final String titleAr;
  final String discountType;
  final int discountValue;
  final String serviceId;

  /// Every service the coupon may be used on (multi-select in the portal).
  final List<String> serviceIds;

  final dynamic serviceName;
  final int expiryDays;
  final String terms;
  final String termsEn;
  final String termsAr;

  /// 0 = Sunday … 6 = Saturday. Empty = valid every day.
  final List<int> daysOfWeek;

  /// Slot start times like "10:00". Empty = valid at any time.
  final List<String> slotStartTimes;

  final int maxUsesPerCustomer;

  /// `null` = unlimited.
  final int? maxTotalUses;

  /// Banner of the offer (`/uploads/offers/...`).
  final String imageUrl;

  /// True when the admin flagged this offer as the new-customer login popup.
  final bool popupEnabled;

  final String status;
  final String createdAt;
  final String updatedAt;

  /// Postgres numerics arrive as doubles; keep the field an int without
  /// throwing when the value is e.g. 99.0 or "99".
  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  static List<int> _asIntList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => int.tryParse(item?.toString() ?? ""))
          .whereType<int>()
          .toList();
    }
    return const [];
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? "")
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _text(dynamic value) => value == null ? "" : value.toString();

  factory Offersmodel.fromJson(Map<String, dynamic> json) {
    final singleService = _text(json["service_id"]);
    final multiService = _asStringList(json["service_ids"]);

    return Offersmodel(
      id: _text(json["id"]),
      offerCode: _text(json["offer_code"]),
      title: _text(json["title_en"] ?? json["title"]),
      titleEn: _text(json["title_en"] ?? json["title"]),
      titleAr: _text(json["title_ar"]),
      discountType: _text(json["discount_type"]),
      discountValue: _asInt(json["discount_value"]),
      serviceId: singleService,
      serviceIds: multiService.isNotEmpty
          ? multiService
          : (singleService.isEmpty ? const <String>[] : [singleService]),
      serviceName: json["service_name"],
      expiryDays: _asInt(json["expiry_days"]),
      terms: _text(json["terms_en"] ?? json["terms"]),
      termsEn: _text(json["terms_en"] ?? json["terms"]),
      termsAr: _text(json["terms_ar"]),
      daysOfWeek: _asIntList(json["days_of_week"]),
      slotStartTimes: _asStringList(json["slot_start_times"]),
      maxUsesPerCustomer: _asInt(json["max_uses_per_customer"], fallback: 1),
      maxTotalUses: json["max_total_uses"] == null
          ? null
          : _asInt(json["max_total_uses"]),
      imageUrl: _text(json["image_url"] ?? json["imageUrl"]),
      popupEnabled:
          json["popup_enabled"] == true || json["popupEnabled"] == true,
      status: _text(json["status"]),
      createdAt: _text(json["created_at"]),
      updatedAt: _text(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "offer_code": offerCode,
    "title": title,
    "title_en": titleEn,
    "title_ar": titleAr,
    "discount_type": discountType,
    "discount_value": discountValue,
    "service_id": serviceId,
    "service_ids": serviceIds,
    "service_name": serviceName,
    "expiry_days": expiryDays,
    "terms": terms,
    "terms_en": termsEn,
    "terms_ar": termsAr,
    "days_of_week": daysOfWeek,
    "slot_start_times": slotStartTimes,
    "max_uses_per_customer": maxUsesPerCustomer,
    "max_total_uses": maxTotalUses,
    "image_url": imageUrl,
    "popup_enabled": popupEnabled,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
