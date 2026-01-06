class Customer {
  final String id;
  final String customerCode;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;

  Customer({
    required this.id,
    required this.customerCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"] ?? "",
      customerCode: json["customer_code"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
    );
  }
}
