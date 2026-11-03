import 'package:get/get.dart';

/// One service a coupon can be redeemed for.
///
/// Returned inside `eligible_services` by `GET /api/coupons/my`.
class CouponEligibleService {
  final String serviceId;

  /// `null` on the backend → stored as an empty string.
  final String serviceName;

  /// Arabic service name (empty when the service has none).
  final String serviceNameAr;

  const CouponEligibleService({
    required this.serviceId,
    this.serviceName = '',
    this.serviceNameAr = '',
  });

  bool get hasName =>
      serviceName.trim().isNotEmpty || serviceNameAr.trim().isNotEmpty;

  /// Name in the app language, falling back to English.
  String get displayName {
    if (Get.locale?.languageCode.toLowerCase() == 'ar' &&
        serviceNameAr.trim().isNotEmpty) {
      return serviceNameAr.trim();
    }
    return serviceName.trim().isNotEmpty
        ? serviceName.trim()
        : serviceNameAr.trim();
  }

  factory CouponEligibleService.fromJson(Map<String, dynamic> json) {
    return CouponEligibleService(
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      serviceNameAr: json['service_name_ar']?.toString() ?? '',
    );
  }
}

/// A customer coupon as returned by `GET /api/coupons/my`.
///
/// `/coupons/my` and `/coupons/details` share the same payload shape, so this
/// single model is used by both the My Coupons screen and the coupon details
/// screen.
///
/// Field notes (verified against the backend `formatCoupon()`):
/// * `discount_percent` is a JSON number that may contain decimals (e.g. 12.5).
/// * `expires_at`, `awarded_at`, `activated_at`, `used_at`, `campaign_*` and
///   `service_*` are nullable. Legacy coupons have no campaign.
/// * `is_expired` is only `true` while the stored status is still `ACTIVE`;
///   [status] is therefore the authoritative state.
class CouponsListModel {
  /// Code shown to the customer / QR-scanned by the partner app.
  final String couponCode;

  /// Booking that **earned** the coupon (empty when the backend sends null).
  final String bookingCode;

  /// Raw backend status: `ACTIVE`, `USED`, `EXPIRED` (legacy: `IN_PROGRESS`).
  final String status;

  /// `CAMPAIGN` for campaign coupons, `STANDARD`/`WELCOME` on legacy rows.
  final String couponType;

  /// Campaign name snapshot taken at award time.
  final String couponTitle;

  /// Arabic campaign name snapshot (empty when the admin did not add one).
  final String couponTitleAr;

  /// Campaign description in English / Arabic (may be empty).
  final String description;
  final String descriptionAr;

  final String campaignId;
  final String campaignName;

  /// Arabic campaign name, used when the app is in Arabic.
  final String campaignNameAr;

  /// Service that earned the coupon.
  final String serviceId;
  final String serviceName;

  /// Every service the coupon can be redeemed for. Empty for legacy coupons.
  final List<CouponEligibleService> eligibleServices;

  /// Campaign discount snapshot. Decimal-safe.
  final double discountPercent;

  final DateTime? awardedAt;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Partner that redeemed the coupon.
  ///
  /// The backend does not select this column for `/coupons/my`, so it is
  /// effectively always empty there.
  final String partnerId;

  /// Raw backend `is_expired` flag (see class docs for its limitation).
  final bool expiredFlag;

  CouponsListModel({
    required this.couponCode,
    this.bookingCode = '',
    required this.status,
    this.couponType = '',
    this.couponTitle = '',
    this.couponTitleAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.campaignId = '',
    this.campaignName = '',
    this.campaignNameAr = '',
    this.serviceId = '',
    this.serviceName = '',
    this.eligibleServices = const [],
    this.discountPercent = 0,
    this.awardedAt,
    this.activatedAt,
    this.expiresAt,
    this.usedAt,
    this.createdAt,
    this.updatedAt,
    this.partnerId = '',
    this.expiredFlag = false,
  });

  String get _normalizedStatus => status.trim().toUpperCase();

  /// Legacy coupons were issued before campaigns existed.
  bool get isLegacy => campaignId.isEmpty;

  bool get isCampaign => couponType.trim().toUpperCase() == 'CAMPAIGN';

  bool get hasEligibleServices => eligibleServices.isNotEmpty;

  bool get isUsed => _normalizedStatus == 'USED';

  bool get isPending => _normalizedStatus == 'IN_PROGRESS';

  /// Expired because the backend says so, or because the campaign validity
  /// window has passed.
  bool get isExpired {
    if (_normalizedStatus == 'EXPIRED') return true;
    if (expiredFlag) return true;
    final expiry = expiresAt;
    return expiry != null && !expiry.isAfter(DateTime.now());
  }

  /// A stored `USED`/`EXPIRED` coupon is never usable, even when the backend
  /// reports `is_expired: false` for it.
  bool get isActive => _normalizedStatus == 'ACTIVE' && !isExpired;

  /// Used / expired coupons are shown in the history section.
  bool get isHistory => !isActive;

  /// Title to show on cards: campaign snapshot, campaign name, or the discount.
  ///
  /// Follows the app language: Arabic is used when it exists and the customer
  /// switched the app to Arabic, otherwise the English text is shown.
  String get displayTitle {
    final arabic = _isArabicLocale;

    if (arabic && couponTitleAr.trim().isNotEmpty) return couponTitleAr.trim();
    if (arabic && campaignNameAr.trim().isNotEmpty) {
      return campaignNameAr.trim();
    }

    if (couponTitle.trim().isNotEmpty) return couponTitle.trim();
    if (campaignName.trim().isNotEmpty) return campaignName.trim();
    return '$discountLabel% OFF';
  }

  /// Description in the current app language (empty when the admin left it out).
  String get displayDescription {
    if (_isArabicLocale && descriptionAr.trim().isNotEmpty) {
      return descriptionAr.trim();
    }
    return description.trim();
  }

  static bool get _isArabicLocale {
    try {
      final code = Get.locale?.languageCode ?? 'en';
      return code.toLowerCase().startsWith('ar');
    } catch (_) {
      return false;
    }
  }

  /// `50` → "50", `12.5` → "12.5", `33.333` → "33.33".
  String get discountLabel => _formatPercent(discountPercent);

  /// Localization key for the status badge.
  String get statusKey {
    switch (_normalizedStatus) {
      case 'ACTIVE':
        return 'coupon_status_active';
      case 'USED':
        return 'coupon_status_used';
      case 'EXPIRED':
        return 'coupon_status_expired';
      case 'IN_PROGRESS':
        return 'coupon_status_pending';
      default:
        return 'coupon_status_unknown';
    }
  }

  /// Service names the coupon can be used for (may be empty).
  List<String> get eligibleServiceNames => eligibleServices
      .where((service) => service.hasName)
      .map((service) => service.displayName)
      .toList();

  /// Fallback label for legacy coupons that only carry `service_name`.
  String get eligibleServicesLabel {
    final names = eligibleServiceNames;
    if (names.isNotEmpty) return names.join(', ');
    return serviceName.trim();
  }

  factory CouponsListModel.fromJson(Map<String, dynamic> json) {
    return CouponsListModel(
      couponCode: json['coupon_code']?.toString() ?? '',
      bookingCode: json['booking_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      couponType: json['coupon_type']?.toString() ?? '',
      couponTitle: json['coupon_title']?.toString() ?? '',
      couponTitleAr: json['coupon_title_ar']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      campaignId: json['campaign_id']?.toString() ?? '',
      campaignName: json['campaign_name']?.toString() ?? '',
      campaignNameAr: json['campaign_name_ar']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      eligibleServices: _toEligibleServices(json['eligible_services']),
      discountPercent: _toDouble(json['discount_percent']),
      awardedAt: _toDate(json['awarded_at']),
      activatedAt: _toDate(json['activated_at']),
      expiresAt: _toDate(json['expires_at']),
      usedAt: _toDate(json['used_at']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      partnerId: json['partner_id']?.toString() ?? '',
      expiredFlag: json['is_expired'] == true,
    );
  }

  static List<CouponEligibleService> _toEligibleServices(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) =>
              CouponEligibleService.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty || raw == 'null') return null;
    return DateTime.tryParse(raw);
  }

  static String _formatPercent(double value) {
    final rounded = double.parse(value.toStringAsFixed(2));
    var text = rounded.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '');
      text = text.replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }
}
