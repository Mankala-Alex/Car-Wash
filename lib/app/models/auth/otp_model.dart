import 'package:my_new_app/app/models/auth/customer_model.dart';

class Otpmodel {
  final bool success;
  final String message;
  final Customer? customer;
  final String token;

  Otpmodel({
    required this.success,
    required this.message,
    required this.customer,
    required this.token,
  });

  factory Otpmodel.fromJson(Map<String, dynamic> json) {
    return Otpmodel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      token: json["token"] ?? "",
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }
}
