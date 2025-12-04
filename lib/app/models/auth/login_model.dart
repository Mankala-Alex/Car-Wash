class Loginmodel {
  Loginmodel({
    required this.success,
    required this.otp,
    required this.customerId,
    required this.message,
    required this.customer,
  });

  final bool success;
  final String otp;
  final String customerId;
  final String message;
  final Customer? customer;

  factory Loginmodel.fromJson(Map<String, dynamic> json) {
    return Loginmodel(
      success: json["success"] ?? false,
      otp: json["otp"] ?? "",
      customerId: json["customerId"] ?? "",
      message: json["message"] ?? "",
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "otp": otp,
        "customerId": customerId,
        "message": message,
        "customer": customer?.toJson(),
      };
}

class Customer {
  Customer({
    required this.id,
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.joinDate,
    required this.lastVisit,
    required this.totalVisits,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String firstName;
  final String lastName;
  final dynamic email;
  final String mobile;
  final dynamic joinDate;
  final dynamic lastVisit;
  final int totalVisits;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"] ?? "",
      customerId: json["customerId"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"],
      mobile: json["mobile"] ?? "",
      joinDate: json["joinDate"],
      lastVisit: json["lastVisit"],
      totalVisits: json["totalVisits"] ?? 0,
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "customerId": customerId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "mobile": mobile,
        "joinDate": joinDate,
        "lastVisit": lastVisit,
        "totalVisits": totalVisits,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
