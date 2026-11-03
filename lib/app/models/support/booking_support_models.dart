/// Models for the booking-specific Help & Support flow.
///
/// Every value comes from the backend (which reads the authoritative booking
/// row), so the app never guesses booking or payment state.
library;

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// Customer-facing summary of the booking the help flow belongs to.
class BookingSupportSummary {
  const BookingSupportSummary({
    required this.id,
    required this.bookingCode,
    this.serviceNameEn = '',
    this.serviceNameAr = '',
    this.scheduledAt,
    this.status = '',
    this.statusLabelEn = '',
    this.statusLabelAr = '',
    this.paymentStatus,
    this.paymentStatusLabelEn = '',
    this.paymentStatusLabelAr = '',
    this.amount = 0,
    this.hasTechnician = false,
    this.technicianName,
    this.canRequestCancellation = false,
  });

  final String id;
  final String bookingCode;
  final String serviceNameEn;
  final String serviceNameAr;
  final DateTime? scheduledAt;
  final String status;
  final String statusLabelEn;
  final String statusLabelAr;
  final String? paymentStatus;
  final String paymentStatusLabelEn;
  final String paymentStatusLabelAr;
  final double amount;
  final bool hasTechnician;
  final String? technicianName;
  final bool canRequestCancellation;

  String serviceName(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) {
      return serviceNameAr.isNotEmpty ? serviceNameAr : serviceNameEn;
    }
    return serviceNameEn.isNotEmpty ? serviceNameEn : serviceNameAr;
  }

  String statusLabel(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) {
      return statusLabelAr.isNotEmpty ? statusLabelAr : statusLabelEn;
    }
    return statusLabelEn.isNotEmpty ? statusLabelEn : statusLabelAr;
  }

  String paymentLabel(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) {
      return paymentStatusLabelAr.isNotEmpty
          ? paymentStatusLabelAr
          : paymentStatusLabelEn;
    }
    return paymentStatusLabelEn.isNotEmpty
        ? paymentStatusLabelEn
        : paymentStatusLabelAr;
  }

  factory BookingSupportSummary.fromJson(Map<String, dynamic> json) {
    return BookingSupportSummary(
      id: json['id']?.toString() ?? '',
      bookingCode:
          json['booking_code']?.toString() ?? json['id']?.toString() ?? '',
      serviceNameEn: json['service_name_en']?.toString() ??
          json['service_name']?.toString() ??
          '',
      serviceNameAr: json['service_name_ar']?.toString() ?? '',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      statusLabelEn: json['status_label_en']?.toString() ?? '',
      statusLabelAr: json['status_label_ar']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString(),
      paymentStatusLabelEn: json['payment_status_label_en']?.toString() ?? '',
      paymentStatusLabelAr: json['payment_status_label_ar']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      hasTechnician: json['has_technician'] == true,
      technicianName: json['technician_name']?.toString(),
      canRequestCancellation: json['can_request_cancellation'] == true,
    );
  }
}

/// One booking help question.
class BookingHelpQuestion {
  const BookingHelpQuestion({
    required this.id,
    required this.category,
    required this.questionEn,
    required this.questionAr,
    this.screenRoute,
  });

  final String id;
  final String category;
  final String questionEn;
  final String questionAr;
  final String? screenRoute;

  String localizedQuestion(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return questionAr.isNotEmpty ? questionAr : questionEn;
    return questionEn.isNotEmpty ? questionEn : questionAr;
  }

  factory BookingHelpQuestion.fromJson(Map<String, dynamic> json) {
    return BookingHelpQuestion(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      questionEn: json['question_en']?.toString() ?? '',
      questionAr: json['question_ar']?.toString() ?? '',
      screenRoute: json['screen_route']?.toString(),
    );
  }
}

/// A booking help category with the questions the backend allows right now.
class BookingHelpCategory {
  const BookingHelpCategory({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    this.icon = 'other',
    this.questions = const [],
  });

  final String id;
  final String labelEn;
  final String labelAr;
  final String icon;
  final List<BookingHelpQuestion> questions;

  String localizedLabel(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return labelAr.isNotEmpty ? labelAr : labelEn;
    return labelEn.isNotEmpty ? labelEn : labelAr;
  }

  factory BookingHelpCategory.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];

    return BookingHelpCategory(
      id: json['id']?.toString() ?? '',
      labelEn: json['label_en']?.toString() ?? '',
      labelAr: json['label_ar']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'other',
      questions: rawQuestions is List
          ? rawQuestions
              .whereType<Map>()
              .map(
                (item) => BookingHelpQuestion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}

/// `GET /api/support/bookings/:id/help`
class BookingHelpPayload {
  const BookingHelpPayload({required this.booking, required this.categories});

  final BookingSupportSummary booking;
  final List<BookingHelpCategory> categories;

  factory BookingHelpPayload.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] is Map
        ? BookingSupportSummary.fromJson(
            Map<String, dynamic>.from(json['booking'] as Map),
          )
        : null;

    final categories = json['categories'];

    return BookingHelpPayload(
      booking: booking ?? const BookingSupportSummary(id: '', bookingCode: ''),
      categories: categories is List
          ? categories
              .whereType<Map>()
              .map(
                (item) => BookingHelpCategory.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }

  BookingHelpQuestion? findQuestion(String questionId) {
    for (final category in categories) {
      for (final question in category.questions) {
        if (question.id == questionId) return question;
      }
    }
    return null;
  }

  BookingHelpCategory? categoryOf(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }
}

/// `GET /api/support/bookings/:id/help/:questionId`
class BookingHelpAnswer {
  const BookingHelpAnswer({
    required this.booking,
    required this.questionId,
    required this.questionEn,
    required this.questionAr,
    required this.answerEn,
    required this.answerAr,
    this.steps = const [],
    this.screenRoute,
    this.urgent = false,
    this.canRequestCancellation = false,
    this.refundEligible = false,
  });

  final BookingSupportSummary booking;
  final String questionId;
  final String questionEn;
  final String questionAr;
  final String answerEn;
  final String answerAr;
  final List<Map<String, String>> steps;
  final String? screenRoute;

  /// Urgent issues skip the troubleshooting loop and offer a human agent.
  final bool urgent;
  final bool canRequestCancellation;
  final bool refundEligible;

  String localizedAnswer(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return answerAr.isNotEmpty ? answerAr : answerEn;
    return answerEn.isNotEmpty ? answerEn : answerAr;
  }

  List<String> localizedSteps(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');

    return steps
        .map((step) {
          final primary = isArabic ? step['ar'] : step['en'];
          final fallback = isArabic ? step['en'] : step['ar'];
          final value = (primary ?? '').trim().isNotEmpty ? primary : fallback;
          return (value ?? '').trim();
        })
        .where((value) => value.isNotEmpty)
        .toList();
  }

  factory BookingHelpAnswer.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] is Map
        ? BookingSupportSummary.fromJson(
            Map<String, dynamic>.from(json['booking'] as Map),
          )
        : const BookingSupportSummary(id: '', bookingCode: '');
    final question = json['question'] is Map
        ? Map<String, dynamic>.from(json['question'] as Map)
        : <String, dynamic>{};
    final answer = json['answer'] is Map
        ? Map<String, dynamic>.from(json['answer'] as Map)
        : <String, dynamic>{};
    final rawSteps = json['steps'];

    return BookingHelpAnswer(
      booking: booking,
      questionId: question['id']?.toString() ?? '',
      questionEn: question['question_en']?.toString() ?? '',
      questionAr: question['question_ar']?.toString() ?? '',
      answerEn: answer['en']?.toString() ?? '',
      answerAr: answer['ar']?.toString() ?? '',
      steps: rawSteps is List
          ? rawSteps
              .whereType<Map>()
              .map(
                (step) => {
                  'en': step['en']?.toString() ?? '',
                  'ar': step['ar']?.toString() ?? '',
                },
              )
              .toList()
          : const [],
      screenRoute: json['screen_route']?.toString(),
      urgent: json['urgent'] == true,
      canRequestCancellation: json['can_request_cancellation'] == true,
      refundEligible: json['refund_eligible'] == true,
    );
  }
}

/// Compact booking reference attached to a support conversation.
class SupportBookingRef {
  const SupportBookingRef({
    required this.bookingCode,
    this.status = '',
    this.serviceName = '',
    this.scheduledAt,
    this.amount = 0,
    this.paymentStatus,
  });

  final String bookingCode;
  final String status;
  final String serviceName;
  final DateTime? scheduledAt;
  final double amount;
  final String? paymentStatus;

  factory SupportBookingRef.fromJson(Map<String, dynamic> json) {
    return SupportBookingRef(
      bookingCode: json['booking_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? ''),
      amount: _asDouble(json['amount']),
      paymentStatus: json['payment_status']?.toString(),
    );
  }
}
