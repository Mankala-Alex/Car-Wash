class Offersmodel {
  Offersmodel({
    required this.id,
    required this.offerCode,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.serviceId,
    required this.serviceName,
    required this.expiryDays,
    required this.terms,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String offerCode;
  final String title;
  final String discountType;
  final int discountValue;
  final String serviceId;
  final dynamic serviceName;
  final int expiryDays;
  final String terms;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory Offersmodel.fromJson(Map<String, dynamic> json) {
    return Offersmodel(
      id: json["id"] ?? "",
      offerCode: json["offer_code"] ?? "",
      title: json["title"] ?? "",
      discountType: json["discount_type"] ?? "",
      discountValue: json["discount_value"] ?? 0,
      serviceId: json["service_id"] ?? "",
      serviceName: json["service_name"],
      expiryDays: json["expiry_days"] ?? 0,
      terms: json["terms"] ?? "",
      status: json["status"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "offer_code": offerCode,
        "title": title,
        "discount_type": discountType,
        "discount_value": discountValue,
        "service_id": serviceId,
        "service_name": serviceName,
        "expiry_days": expiryDays,
        "terms": terms,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
