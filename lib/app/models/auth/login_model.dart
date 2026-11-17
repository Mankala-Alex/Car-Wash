import 'package:car_wash_customer_app/app/models/auth/customer_model.dart';

class Loginmodel {
  final bool success;
  final bool exists;
  final String message;
  final String? id;
  final Customer? customer;

  /// Normalised number returned by the backend (+966XXXXXXXXX).
  final String phone;

  /// True when the backend created the account on the fly (no signup screen).
  final bool isNewCustomer;

  /// OTP validity / resend cooldown, both driven by the server response.
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final int otpLength;

  Loginmodel({
    required this.success,
    required this.exists,
    required this.message,
    this.id,
    this.customer,
    this.phone = '',
    this.isNewCustomer = false,
    this.expiresInSeconds = 300,
    this.resendAfterSeconds = 60,
    this.otpLength = 6,
  });

  factory Loginmodel.fromJson(Map<String, dynamic> json) {
    return Loginmodel(
      success: json["success"] ?? false,
      exists: json["exists"] ?? false,
      message: json["message"] ?? "",
      id: json["id"],
      customer: json["customer"] == null
          ? null
          : Customer.fromJson(json["customer"]),
      phone: (json["phone"] ?? "").toString(),
      isNewCustomer: json["is_new_customer"] == true,
      expiresInSeconds: _asInt(json["expires_in_seconds"], 300),
      resendAfterSeconds: _asInt(json["resend_after_seconds"], 60),
      otpLength: _asInt(json["otp_length"], 6),
    );
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
