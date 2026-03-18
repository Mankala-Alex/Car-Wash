class Bookinghistorymodel {
  final bool success;
  final List<Datum> bookings;

  Bookinghistorymodel({
    required this.success,
    required this.bookings,
  });

  factory Bookinghistorymodel.fromJson(Map<String, dynamic> json) {
    final list = json["bookings"] ?? [];

    return Bookinghistorymodel(
      success: json["success"] ?? false,
      bookings: List<Datum>.from(
        list.map((x) => Datum.fromJson(x)),
      ),
    );
  }
}

class Datum {
  final String id;
  final String bookingCode;
  final String customerName;
  final String vehicle;
  final String serviceId;
  final String serviceName;
  final DateTime? scheduledAt;
  final String? washerId;
  final String? washerName;
  final String status;
  final String amount;
  final int slotId;
  final String customerId;
  final List<BookingImage> images;
  final List<BookingVideo> videos;

  Datum({
    required this.id,
    required this.bookingCode,
    required this.customerName,
    required this.vehicle,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledAt,
    required this.washerId,
    required this.washerName,
    required this.status,
    required this.amount,
    required this.slotId,
    required this.customerId,
    required this.images,
    required this.videos,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"] ?? "",
      bookingCode: json["booking_code"] ?? "",
      customerName: json["customer_name"] ?? "",
      vehicle: json["vehicle"] ?? "",
      serviceId: json["service_id"] ?? "",
      serviceName: json["service_name"] ?? "",
      scheduledAt: DateTime.tryParse(json["scheduled_at"] ?? ""),
      washerId: json["washer_id"]?.toString(),
      washerName: json["washer_name"]?.toString(),
      status: json["status"] ?? "",
      amount: json["amount"] ?? "",
      slotId: json["slot_id"] ?? 0,
      customerId: json["customer_id"] ?? "",
      images: (json["images"] ?? [])
          .map<BookingImage>((x) => BookingImage.fromJson(x))
          .toList(),
      videos: (json["videos"] ?? [])
          .map<BookingVideo>((x) => BookingVideo.fromJson(x))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_code": bookingCode,
        "customer_name": customerName,
        "vehicle": vehicle,
        "service_id": serviceId,
        "service_name": serviceName,
        "scheduled_at": scheduledAt?.toIso8601String(),
        "washer_id": washerId,
        "washer_name": washerName,
        "status": status,
        "amount": amount,
        "slot_id": slotId,
        "customer_id": customerId,
        "images": images
            .map((e) => {
                  "image_url": e.url,
                  "image_type": e.type,
                })
            .toList(),
        "videos": videos
            .map((e) => {
                  "video_url": e.url,
                  "video_type": e.type,
                })
            .toList(),
      };
}

class BookingImage {
  final String url;
  final String type;

  BookingImage({
    required this.url,
    required this.type,
  });

  factory BookingImage.fromJson(Map<String, dynamic> json) {
    return BookingImage(
      url: json["image_url"] ?? "",
      type: json["image_type"] ?? "",
    );
  }
}

class BookingVideo {
  final String url;
  final String type;

  BookingVideo({
    required this.url,
    required this.type,
  });

  factory BookingVideo.fromJson(Map<String, dynamic> json) {
    return BookingVideo(
      url: json["video_url"] ?? "",
      type: json["video_type"] ?? "",
    );
  }
}
