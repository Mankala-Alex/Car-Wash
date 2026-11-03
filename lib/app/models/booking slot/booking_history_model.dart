class Bookinghistorymodel {
  final bool success;
  final List<Datum> bookings;

  Bookinghistorymodel({required this.success, required this.bookings});

  factory Bookinghistorymodel.fromJson(Map<String, dynamic> json) {
    final list = json["bookings"] ?? [];

    return Bookinghistorymodel(
      success: json["success"] ?? false,
      bookings: List<Datum>.from(list.map((x) => Datum.fromJson(x))),
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

  /// Technician's contact number (from `employees.contact_number`), already
  /// normalised by the backend. Null when nobody is assigned yet or the number
  /// is missing, in which case the app hides the call button.
  final String? washerPhone;
  final String status;
  final String amount;
  final int slotId;
  final String customerId;
  final List<BookingImage> images;
  final List<BookingVideo> videos;

  /// NULL | REQUESTED | APPROVED | REJECTED — set by the cancellation flow.
  final String? cancellationStatus;

  /// Why an admin rejected the last request (shown to the customer).
  final String? cancellationRejectionReason;

  /// How many cancellation requests were rejected. The backend allows one more
  /// attempt after the first rejection; from 2 onwards the app blocks it.
  final int cancellationRejectionCount;

  /// VOIDED | REFUNDED | FAILED | NOT_REQUIRED — null while a refund is pending.
  final String? refundStatus;
  final String? refundAmount;

  /// Slot label straight from the backend (Saudi wall-clock), e.g.
  /// slotDate = "2026-11-03", slotTime = "10:00-11:00".
  /// These are the source of truth for what the customer sees, so the booking
  /// time never depends on the phone's timezone.
  final String? slotDate;
  final String? slotTime;

  /// Price breakdown of this booking, produced by the backend:
  /// service amount (excl. VAT), VAT percentage that was paid, VAT amount and
  /// the charged total. Null/0 when the backend has no pricing for it.
  final double serviceAmount;
  final double vatPercentage;
  final double vatAmount;
  final double totalAmount;

  /// Where the service happens.
  final String? address;
  final String? formattedAddress;
  final String? pincode;
  final String? landmark;
  final String? houseNumber;
  final String? addressLabel;

  /// Payment information as stored with the booking.
  final String? paymentStatus;
  final String? paymentMethod;

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
    required this.washerPhone,
    required this.status,
    required this.amount,
    required this.slotId,
    required this.customerId,
    required this.images,
    required this.videos,
    this.cancellationStatus,
    this.cancellationRejectionReason,
    this.cancellationRejectionCount = 0,
    this.refundStatus,
    this.refundAmount,
    this.slotDate,
    this.slotTime,
    this.serviceAmount = 0,
    this.vatPercentage = 0,
    this.vatAmount = 0,
    this.totalAmount = 0,
    this.address,
    this.formattedAddress,
    this.pincode,
    this.landmark,
    this.houseNumber,
    this.addressLabel,
    this.paymentStatus,
    this.paymentMethod,
  });

  /// "10:00 AM" from the slot (falls back to null when the slot is missing).
  String? get slotStartLabel {
    final raw = slotTime;
    if (raw == null || raw.trim().isEmpty) return null;

    final start = raw.split('-').first.trim();
    final parts = start.split(':');
    final hour = int.tryParse(parts.first);
    if (hour == null) return null;

    final minute = parts.length > 1 ? parts[1] : '00';
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:$minute $suffix';
  }

  /// "03 Nov 2026" from the slot date (null when the slot is missing).
  String? get slotDateLabel {
    final raw = slotDate;
    if (raw == null || raw.trim().isEmpty) return null;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final parts = raw.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12) return null;

    final dayText = day.toString().padLeft(2, '0');
    return '$dayText ${months[month - 1]} $year';
  }

  /// True while an admin has not yet decided on the cancellation request.
  bool get hasPendingCancellation =>
      (cancellationStatus ?? '').toUpperCase() == 'REQUESTED';

  /// True when the last cancellation request was rejected. The booking is
  /// cancelled at the same time, so it shows up under Past Bookings.
  bool get isCancellationRejected =>
      (cancellationStatus ?? '').toUpperCase() == 'REJECTED';

  /// True once the booking was cancelled (admin approved).
  bool get isCancelled {
    final s = status.toUpperCase();
    return s == 'CANCELLED' || s == 'CANCELED';
  }

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
      washerPhone: json["washer_phone"]?.toString(),
      status: json["status"] ?? "",
      amount: json["amount"] ?? "",
      slotId: json["slot_id"] ?? 0,
      customerId: json["customer_id"] ?? "",
      cancellationStatus: json["cancellation_status"]?.toString(),
      cancellationRejectionReason: json["cancellation_rejection_reason"]
          ?.toString(),
      cancellationRejectionCount:
          int.tryParse(
            json["cancellation_rejection_count"]?.toString() ?? "",
          ) ??
          0,
      refundStatus: json["refund_status"]?.toString(),
      refundAmount: json["refund_amount"]?.toString(),
      slotDate: json["slot_date"]?.toString(),
      slotTime: json["slot_time"]?.toString(),
      serviceAmount: _money(json["service_amount"]),
      vatPercentage: _money(json["vat_percentage"]),
      vatAmount: _money(json["vat_amount"]),
      totalAmount: _money(
        json["total_amount"],
        fallback: _money(json["amount"]),
      ),
      address: json["address"]?.toString(),
      formattedAddress: json["formatted_address"]?.toString(),
      pincode: json["pincode"]?.toString(),
      landmark: json["landmark"]?.toString(),
      houseNumber: json["house_number"]?.toString(),
      addressLabel: json["address_label"]?.toString(),
      paymentStatus: json["payment_status"]?.toString(),
      paymentMethod: json["payment_method"]?.toString(),
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
    "washer_phone": washerPhone,
    "status": status,
    "amount": amount,
    "slot_id": slotId,
    "customer_id": customerId,
    "images": images
        .map((e) => {"image_url": e.url, "image_type": e.type})
        .toList(),
    "videos": videos
        .map((e) => {"video_url": e.url, "video_type": e.type})
        .toList(),
  };
}

class BookingImage {
  final String url;
  final String type;

  BookingImage({required this.url, required this.type});

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

  BookingVideo({required this.url, required this.type});

  factory BookingVideo.fromJson(Map<String, dynamic> json) {
    return BookingVideo(
      url: json["video_url"] ?? "",
      type: json["video_type"] ?? "",
    );
  }
}

/// Money columns arrive as strings from Postgres (`numeric`), so parse both.
double _money(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? "") ?? fallback;
}
