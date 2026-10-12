class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String technicianId;
  final String technicianName;
  final String bookingCode;
  final String serviceName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.technicianId,
    required this.technicianName,
    required this.bookingCode,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];

    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      technicianId: (json['technician_id'] ?? '').toString(),
      technicianName: (json['technician_name'] ?? '').toString(),
      bookingCode: (json['booking_code'] ?? '').toString(),
      serviceName: (json['service_name'] ?? '').toString(),
      rating: ratingValue is num
          ? ratingValue.toInt()
          : int.tryParse(ratingValue?.toString() ?? '') ?? 0,
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  static ReviewModel? fromResponse(dynamic data) {
    if (data == null) return null;

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return ReviewModel.fromJson(first);
      }
      if (first is Map) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(first));
      }
      return null;
    }

    if (data is Map) {
      final payload = Map<String, dynamic>.from(data);

      final keysToCheck = [
        'review',
        'data',
        'result',
        'reviews',
        'booking_review',
      ];

      for (final key in keysToCheck) {
        final value = payload[key];
        if (value is Map) {
          return ReviewModel.fromJson(Map<String, dynamic>.from(value));
        }
        if (value is List && value.isNotEmpty && value.first is Map) {
          return ReviewModel.fromJson(
            Map<String, dynamic>.from(value.first),
          );
        }
      }

      if (payload.containsKey('id') ||
          payload.containsKey('booking_id') ||
          payload.containsKey('rating')) {
        return ReviewModel.fromJson(payload);
      }
    }

    return null;
  }
}
