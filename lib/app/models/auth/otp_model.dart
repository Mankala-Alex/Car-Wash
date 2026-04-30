import 'package:car_wash_customer_app/app/models/auth/customer_model.dart';

class Otpmodel {
  final bool success;
  final bool verified;
  final String message;
  final Customer? customer;
  final String? token;

  Otpmodel({
    required this.success,
    required this.verified,
    required this.message,
    this.customer,
    this.token,
  });

  factory Otpmodel.fromJson(Map<String, dynamic> json) {
    return Otpmodel(
      success: json["success"] ?? false,
      verified: json["verified"] ?? false,
      message: json["message"] ?? "",
      token: json["token"],
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }
}
