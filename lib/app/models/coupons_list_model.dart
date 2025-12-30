class CouponsListModel {
  final String couponCode;
  final String status;
  final int discountPercent;
  final DateTime expiresAt;
  final bool isExpired;

  CouponsListModel({
    required this.couponCode,
    required this.status,
    required this.discountPercent,
    required this.expiresAt,
    required this.isExpired,
  });

  factory CouponsListModel.fromJson(Map<String, dynamic> json) {
    return CouponsListModel(
      couponCode: json['coupon_code'],
      status: json['status'],
      discountPercent: json['discount_percent'],
      expiresAt: DateTime.parse(json['expires_at']),
      isExpired: json['is_expired'],
    );
  }
}
