class Bookingslotmodel {
  Bookingslotmodel({
    required this.success,
    required this.data,
  });

  final bool success;
  final Data? data;

  factory Bookingslotmodel.fromJson(Map<String, dynamic> json) {
    return Bookingslotmodel(
      success: json["success"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
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

    // NEW FIELDS
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.address,
    required this.houseNumber,
    required this.landmark,
    required this.addressLabel,
  });

  final String id;
  final String bookingCode;
  final String customerId; // ← UUID
  final String customerName;
  final String vehicle;
  final String serviceId; // ← STRING
  final String serviceName;
  final String? scheduledAt;
  final String washerId;
  final String washerName;
  final String status;
  final String amount;
  final DateTime? createdAt;
  final dynamic updatedAt;
  final int slotId;
  final double? latitude;
  final double? longitude;

  final String? formattedAddress;
  final String? address;
  final String? houseNumber;
  final String? addressLabel;
  final String? landmark;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? "",
      bookingCode: json["booking_code"] ?? "",
      customerId: json["customer_id"]?.toString() ?? "",
      customerName: json["customer_name"] ?? "",
      vehicle: json["vehicle"] ?? "",
      serviceId: json["service_id"]?.toString() ?? "",
      serviceName: json["service_name"] ?? "",
      scheduledAt: json["scheduled_at"] ?? "",
      washerId: json["washer_id"]?.toString() ?? "",
      washerName: json["washer_name"]?.toString() ?? "",
      status: json["status"] ?? "",
      amount: json["amount"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: json["updated_at"],
      slotId: json["slot_id"] ?? 0,
      latitude: json["latitude"] != null
          ? (json["latitude"] as num).toDouble()
          : null,
      longitude: json["longitude"] != null
          ? (json["longitude"] as num).toDouble()
          : null,
      formattedAddress: json["formatted_address"],
      address: json["address"],
      houseNumber: json["house_number"],
      landmark: json["landmark"],
      addressLabel: json["address_label"],
    );
  }
}
