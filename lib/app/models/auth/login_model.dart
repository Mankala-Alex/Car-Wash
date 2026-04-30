import 'package:car_wash_customer_app/app/models/auth/customer_model.dart';

class Loginmodel {
  final bool success;
  final bool exists;
  final String message;
  final String? id;
  final Customer? customer;

  Loginmodel({
    required this.success,
    required this.exists,
    required this.message,
    this.id,
    this.customer,
  });

  factory Loginmodel.fromJson(Map<String, dynamic> json) {
    return Loginmodel(
      success: json["success"] ?? false,
      exists: json["exists"] ?? false,
      message: json["message"] ?? "",
      id: json["id"],
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }
}
