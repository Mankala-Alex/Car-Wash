class CouponModel {
  final bool success;
  final CouponData? data;

  CouponModel({required this.success, this.data});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      success: json["success"] ?? false,
      data: json["data"] == null ? null : CouponData.fromJson(json["data"]),
    );
  }
}

class CouponData {
  final String couponCode;
  final String status;
  final int discountPercent;
  final DateTime expiresAt;
  final bool isExpired;

  CouponData({
    required this.couponCode,
    required this.status,
    required this.discountPercent,
    required this.expiresAt,
    required this.isExpired,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      couponCode: json["coupon_code"] ?? "",
      status: json["status"] ?? "",
      discountPercent: json["discount_percent"] ?? 0,
      expiresAt: DateTime.parse(json["expires_at"]),
      isExpired: json["is_expired"] ?? false,
    );
  }
}
