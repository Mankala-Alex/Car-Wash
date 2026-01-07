class Bookinghistorymodel {
  Bookinghistorymodel({
    required this.success,
    required this.data,
  });

  final bool success;
  final List<Datum> data;

  factory Bookinghistorymodel.fromJson(Map<String, dynamic> json) {
    return Bookinghistorymodel(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<Datum>.from(
              json["data"].map((x) => Datum.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.map((x) => x.toJson()).toList(),
      };
}

// =======================================================
// SINGLE BOOKING ITEM
// =======================================================

class Datum {
  Datum({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.customerName,
    required this.vehicle,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledAt,
    required this.washerId,
    required this.washerName,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.slotId,
    required this.beforeImages,
    required this.afterImages,
  });

  final String id;
  final String bookingCode;
  final String customerId;
  final String customerName;
  final String vehicle;
  final String serviceId;
  final String serviceName;
  final String? scheduledAt;
  final String washerId;
  final String washerName;
  final String status;
  final String amount;
  final DateTime? createdAt;
  final dynamic updatedAt;
  final int slotId;

  /// ✅ IMAGE LISTS
  final List<String> beforeImages;
  final List<String> afterImages;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"] ?? "",
      bookingCode: json["booking_code"] ?? "",
      customerId: json["customer_id"]?.toString() ?? "",
      customerName: json["customer_name"] ?? "",
      vehicle: json["vehicle"] ?? "",
      serviceId: json["service_id"]?.toString() ?? "",
      serviceName: json["service_name"] ?? "",
      scheduledAt: json["scheduled_at"],
      washerId: json["washer_id"]?.toString() ?? "",
      washerName: json["washer_name"]?.toString() ?? "",
      status: json["status"] ?? "",
      amount: json["amount"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: json["updated_at"],
      slotId: json["slot_id"] ?? 0,

      /// ✅ SAFE IMAGE PARSING
      beforeImages: json["before_images"] == null
          ? []
          : List<String>.from(json["before_images"]),
      afterImages: json["after_images"] == null
          ? []
          : List<String>.from(json["after_images"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_code": bookingCode,
        "customer_id": customerId,
        "customer_name": customerName,
        "vehicle": vehicle,
        "service_id": serviceId,
        "service_name": serviceName,
        "scheduled_at": scheduledAt,
        "washer_id": washerId,
        "washer_name": washerName,
        "status": status,
        "amount": amount,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt,
        "slot_id": slotId,
        "before_images": beforeImages,
        "after_images": afterImages,
      };
}
