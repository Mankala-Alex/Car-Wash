class Signupmodel {
  Signupmodel({
    required this.success,
    required this.message,
    required this.customer,
    required this.token,
  });

  final bool success;
  final String message;
  final Customer? customer;
  final String token;

  factory Signupmodel.fromJson(Map<String, dynamic> json) {
    return Signupmodel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      customer:
          json["customer"] == null ? null : Customer.fromJson(json["customer"]),
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "customer": customer?.toJson(),
        "token": token,
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
