import 'package:my_new_app/app/models/auth/customer_model.dart';

class Loginmodel {
  final bool success;
  final bool exists;
  final String message;
  final Customer? customer;
  final String id;
  final String token;

  Loginmodel({
    required this.success,
    required this.exists,
    required this.message,
    required this.customer,
    required this.id,
    required this.token,
  });

  factory Loginmodel.fromJson(Map<String, dynamic> json) {
    return Loginmodel(
      success: json["success"] ?? false,
      exists: json["exists"] ?? false,
      message: json["message"] ?? "",
      id: json["id"] ?? "",
      token: json["token"] ?? "",
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }
}
