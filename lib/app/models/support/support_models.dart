/// Models for the Help Center and the live support chat.
///
/// All FAQ content comes from the backend (`/api/support/faq/...`) in both
/// languages; the app only picks one, so answers can change without an app
/// release.
library;

import 'booking_support_models.dart';

/// One Help Center category (Booking Issues, Payment Issues, ...).
class FaqCategory {
  const FaqCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.icon = 'help',
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String icon;

  /// Category name in the current app language.
  String localizedName(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return nameAr.isNotEmpty ? nameAr : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      id: json['id']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'help',
    );
  }
}

/// A question in a category, optionally carrying its answer.
class FaqQuestion {
  const FaqQuestion({
    required this.id,
    required this.categoryId,
    required this.questionEn,
    required this.questionAr,
    this.answerEn = '',
    this.answerAr = '',
    this.screenRoute,
    this.troubleshooting = const [],
    this.categoryNameEn = '',
    this.categoryNameAr = '',
  });

  final String id;
  final String categoryId;
  final String questionEn;
  final String questionAr;
  final String answerEn;
  final String answerAr;

  /// Optional in-app destination the answer can open (e.g. `booking_history`).
  final String? screenRoute;

  /// Extra troubleshooting steps: `[{en, ar}]`.
  final List<Map<String, String>> troubleshooting;

  final String categoryNameEn;
  final String categoryNameAr;

  String localizedQuestion(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return questionAr.isNotEmpty ? questionAr : questionEn;
    return questionEn.isNotEmpty ? questionEn : questionAr;
  }

  String localizedAnswer(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return answerAr.isNotEmpty ? answerAr : answerEn;
    return answerEn.isNotEmpty ? answerEn : answerAr;
  }

  String localizedCategory(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) {
      return categoryNameAr.isNotEmpty ? categoryNameAr : categoryNameEn;
    }
    return categoryNameEn.isNotEmpty ? categoryNameEn : categoryNameAr;
  }

  List<String> localizedSteps(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');

    return troubleshooting
        .map((step) {
          final primary = isArabic ? step['ar'] : step['en'];
          final fallback = isArabic ? step['en'] : step['ar'];

          // Treat an empty translation the same as a missing one.
          final value = (primary ?? '').trim().isNotEmpty ? primary : fallback;

          return (value ?? '').trim();
        })
        .where((value) => value.isNotEmpty)
        .toList();
  }

  factory FaqQuestion.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['troubleshooting'];

    return FaqQuestion(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      questionEn: json['question_en']?.toString() ?? '',
      questionAr: json['question_ar']?.toString() ?? '',
      answerEn: json['answer_en']?.toString() ?? '',
      answerAr: json['answer_ar']?.toString() ?? '',
      screenRoute: json['screen_route']?.toString(),
      troubleshooting: rawSteps is List
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
      categoryNameEn: (json['category'] is Map)
          ? (json['category']['name_en']?.toString() ?? '')
          : '',
      categoryNameAr: (json['category'] is Map)
          ? (json['category']['name_ar']?.toString() ?? '')
          : '',
    );
  }
}

/// A support conversation between the customer and the support team.
class SupportConversation {
  const SupportConversation({
    required this.id,
    required this.status,
    this.category,
    this.assignedAdminName,
    this.customerUnreadCount = 0,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.createdAt,
    this.bookingId,
    this.bookingCode,
    this.booking,
  });

  final String id;
  final String status;
  final String? category;
  final String? assignedAdminName;
  final int customerUnreadCount;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  /// Authoritative booking link of the conversation (null for general help).
  final String? bookingId;
  final String? bookingCode;
  final SupportBookingRef? booking;

  bool get isClosed => status.toUpperCase() == 'CLOSED';
  bool get isResolved => status.toUpperCase() == 'RESOLVED';
  bool get hasAgent => (assignedAdminName ?? '').trim().isNotEmpty;

  SupportConversation copyWith({
    String? status,
    String? assignedAdminName,
    int? customerUnreadCount,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
  }) {
    return SupportConversation(
      id: id,
      status: status ?? this.status,
      category: category,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      customerUnreadCount: customerUnreadCount ?? this.customerUnreadCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt,
      bookingId: bookingId,
      bookingCode: bookingCode,
      booking: booking,
    );
  }

  factory SupportConversation.fromJson(Map<String, dynamic> json) {
    return SupportConversation(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      category: json['category']?.toString(),
      assignedAdminName: json['assigned_admin_name']?.toString(),
      customerUnreadCount: _asInt(json['customer_unread_count']),
      lastMessagePreview: json['last_message_preview']?.toString(),
      lastMessageAt: DateTime.tryParse(
        json['last_message_at']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      bookingId: json['booking_id']?.toString(),
      bookingCode: json['booking_code']?.toString(),
      booking: json['booking'] is Map
          ? SupportBookingRef.fromJson(
              Map<String, dynamic>.from(json['booking'] as Map),
            )
          : null,
    );
  }
}

/// A single chat message.
class SupportMessage {
  SupportMessage({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.message,
    this.senderName,
    this.createdAt,
    this.readAt,
    this.status = SupportMessageStatus.sent,
    this.clientMessageId,
  });

  final String id;
  final String conversationId;

  /// `customer` | `agent` | `system`
  final String senderType;
  final String message;
  final String? senderName;
  final DateTime? createdAt;
  final DateTime? readAt;

  /// Local delivery state (only meaningful for messages this device sent).
  final SupportMessageStatus status;
  final String? clientMessageId;

  bool get isMine => senderType == 'customer';
  bool get isSystem => senderType == 'system';

  SupportMessage copyWith({
    SupportMessageStatus? status,
    String? id,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return SupportMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderType: senderType,
      message: message,
      senderName: senderName,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
      clientMessageId: clientMessageId,
    );
  }

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderType: json['sender_type']?.toString() ?? 'agent',
      message: json['message']?.toString() ?? '',
      senderName: json['sender_name']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      clientMessageId: json['client_message_id']?.toString(),
    );
  }
}

/// Delivery state of a message this device sent.
enum SupportMessageStatus { sending, sent, failed }

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
