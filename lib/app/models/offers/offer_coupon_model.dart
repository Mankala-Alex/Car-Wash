/// Price split of a booking with a coupon applied.
///
/// Every number comes from the backend (`POST /api/offers/coupons/validate`)
/// so the device never computes VAT or discounts itself.
class CouponPriceBreakdown {
  const CouponPriceBreakdown({
    required this.servicePrice,
    required this.discountAmount,
    required this.taxableAmount,
    required this.vatPercentage,
    required this.vatAmount,
    required this.totalAmount,
  });

  /// Service price WITHOUT VAT.
  final double servicePrice;

  /// Money taken off the service price.
  final double discountAmount;

  /// servicePrice - discountAmount (what VAT is computed on).
  final double taxableAmount;

  final double vatPercentage;
  final double vatAmount;

  /// taxableAmount + vatAmount — what the customer pays.
  final double totalAmount;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0.0;
  }

  factory CouponPriceBreakdown.fromJson(Map<String, dynamic> json) {
    return CouponPriceBreakdown(
      servicePrice: _toDouble(json["service_price"]),
      discountAmount: _toDouble(json["discount_amount"]),
      taxableAmount: _toDouble(json["taxable_amount"]),
      vatPercentage: _toDouble(json["vat_percentage"]),
      vatAmount: _toDouble(json["vat_amount"]),
      totalAmount: _toDouble(json["total_amount"]),
    );
  }

  bool get hasDiscount => discountAmount > 0;
}

/// One offer that can be used as a coupon at booking time.
class OfferCouponModel {
  const OfferCouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.terms,
    required this.termsEn,
    required this.termsAr,
    required this.discountType,
    required this.discountValue,
    required this.daysOfWeek,
    required this.daysLabel,
    required this.slotStartTimes,
    required this.discountAmount,
    required this.totalAmount,
  });

  final String id;

  /// The offer code the backend validates (`offers.offer_code`).
  final String code;

  final String title;
  final String titleEn;
  final String titleAr;
  final String terms;
  final String termsEn;
  final String termsAr;

  /// `percentage` or `fixed`.
  final String discountType;
  final double discountValue;

  /// 0 = Sunday ... 6 = Saturday. Empty = every day.
  final List<int> daysOfWeek;
  final String daysLabel;

  /// Slot start times like `10:00`. Empty = any time.
  final List<String> slotStartTimes;

  /// Preview for the service that was selected (from the list endpoint).
  final double discountAmount;
  final double totalAmount;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0.0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? "")
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static List<int> _toIntList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => int.tryParse(item?.toString() ?? ""))
          .whereType<int>()
          .toList();
    }
    return const [];
  }

  factory OfferCouponModel.fromJson(Map<String, dynamic> json) {
    return OfferCouponModel(
      id: json["id"]?.toString() ?? "",
      code: (json["coupon_code"] ?? json["code"] ?? "").toString(),
      title: (json["title_en"] ?? json["title"] ?? "").toString(),
      titleEn: (json["title_en"] ?? json["title"] ?? "").toString(),
      titleAr: (json["title_ar"] ?? "").toString(),
      terms: (json["terms_en"] ?? json["terms"] ?? "").toString(),
      termsEn: (json["terms_en"] ?? json["terms"] ?? "").toString(),
      termsAr: (json["terms_ar"] ?? "").toString(),
      discountType: (json["discount_type"] ?? "percentage").toString(),
      discountValue: _toDouble(json["discount_value"]),
      daysOfWeek: _toIntList(json["days_of_week"]),
      daysLabel: (json["days_label"] ?? "").toString(),
      slotStartTimes: _toStringList(json["slot_start_times"]),
      discountAmount: _toDouble(json["discount_amount"]),
      totalAmount: _toDouble(json["total_amount"]),
    );
  }

  bool get isFixedAmount => discountType.toLowerCase() == "fixed";

  /// "20%" or "SAR 5".
  String get discountLabel {
    final value = discountValue % 1 == 0
        ? discountValue.toStringAsFixed(0)
        : discountValue.toStringAsFixed(2);

    return isFixedAmount ? "SAR $value" : "$value%";
  }

  /// Human readable restriction summary ("Sunday, Monday · 10:00").
  String get restrictionsLabel {
    final parts = <String>[];
    if (daysLabel.isNotEmpty) parts.add(daysLabel);
    if (slotStartTimes.isNotEmpty) parts.add(slotStartTimes.join(", "));
    return parts.join(" · ");
  }
}
