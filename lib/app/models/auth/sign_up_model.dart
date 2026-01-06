import 'package:my_new_app/app/models/auth/customer_model.dart';

class Signupmodel {
  final bool success;
  final String message;
  final Customer? customer;
  final String id;
  final String token;

  Signupmodel({
    required this.success,
    required this.message,
    required this.customer,
    required this.id,
    required this.token,
  });

  factory Signupmodel.fromJson(Map<String, dynamic> json) {
    return Signupmodel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      id: json["id"] ?? "",
      token: json["token"] ?? "",
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }
}
