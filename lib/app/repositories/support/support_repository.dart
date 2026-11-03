import 'package:dio/dio.dart';

import '../../models/support/booking_support_models.dart';
import '../../models/support/support_models.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

/// Help Center (FAQ) + live support chat APIs.
///
/// Mirrors the backend routes in `backend/routes/support.js`; conversation
/// endpoints require the customer JWT, FAQ reads are public.
class SupportRepository {
  // ================= Help Center =================

  Future<List<FaqCategory>> fetchCategories() async {
    final response = await ApiService.get(
      EndPoints.apiSupportFaqCategories,
      requireAuthToken: false,
    );

    final data = response.data;
    final list = (data is Map ? data['categories'] : data) as List? ?? [];

    return list
        .whereType<Map>()
        .map((json) => FaqCategory.fromJson(Map<String, dynamic>.from(json)))
        .where((category) => category.id.isNotEmpty)
        .toList();
  }

  Future<List<FaqQuestion>> fetchQuestions(String categoryId) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportFaqCategories}/$categoryId/questions',
      requireAuthToken: false,
    );

    final data = response.data;
    final list = (data is Map ? data['questions'] : data) as List? ?? [];

    return list
        .whereType<Map>()
        .map((json) => FaqQuestion.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<FaqQuestion?> fetchQuestion(String questionId) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportFaqQuestions}/$questionId',
      requireAuthToken: false,
    );

    final data = response.data;
    final question = data is Map ? data['question'] : null;

    if (question is! Map) return null;

    return FaqQuestion.fromJson(Map<String, dynamic>.from(question));
  }

  /// Records "this solved / did not solve my problem" for reporting.
  Future<void> sendFaqFeedback(String questionId, bool helpful) async {
    await ApiService.post(
      '${EndPoints.apiSupportFaqQuestions}/$questionId/feedback',
      {'helpful': helpful},
      requireAuthToken: false,
    );
  }

  // ================= Conversations =================

  /// Returns the active conversation, or null when there is none.
  Future<SupportConversation?> getActiveConversation() async {
    final response = await ApiService.get(
      EndPoints.apiSupportConversation,
      requireAuthToken: true,
    );

    final data = response.data;
    final conversation = data is Map ? data['conversation'] : null;

    if (conversation is! Map) return null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation),
    );
  }

  /// Creates the conversation, or returns the existing open one.
  Future<SupportConversation> startConversation({
    String? category,
    String? source,
    String? questionId,
    String? questionEn,
    String? questionAr,
    String? lastAttemptedSolution,
    String? bookingId,
    String? priority,
  }) async {
    final response = await ApiService.post(EndPoints.apiSupportConversation, {
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (questionId != null) 'question_id': questionId,
      if (questionEn != null) 'question_en': questionEn,
      if (questionAr != null) 'question_ar': questionAr,
      if (lastAttemptedSolution != null)
        'last_attempted_solution': lastAttemptedSolution,
      if (bookingId != null) 'booking_id': bookingId,
      if (priority != null) 'priority': priority,
    }, requireAuthToken: true);

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation as Map),
    );
  }

  /// Paginated message history (chronological order).
  Future<({List<SupportMessage> messages, bool hasMore})> fetchMessages(
    String conversationId, {
    int limit = 50,
    String? before,
  }) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportConversations}/$conversationId/messages',
      params: {'limit': limit, if (before != null) 'before': before},
      requireAuthToken: true,
    );

    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : {};
    final list = data['messages'] as List? ?? [];

    return (
      messages: list
          .whereType<Map>()
          .map(
            (json) => SupportMessage.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList(),
      hasMore: data['has_more'] == true,
    );
  }

  /// Sends a message. `clientMessageId` makes retries idempotent.
  Future<SupportMessage> sendMessage(
    String conversationId,
    String message,
    String clientMessageId,
  ) async {
    final response = await ApiService.post(
      '${EndPoints.apiSupportConversations}/$conversationId/messages',
      {'message': message, 'client_message_id': clientMessageId},
      requireAuthToken: true,
    );

    final data = response.data is Map ? response.data['message'] : null;

    return SupportMessage.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> markRead(String conversationId) async {
    await ApiService.post(
      '${EndPoints.apiSupportConversations}/$conversationId/read',
      {},
      requireAuthToken: true,
    );
  }

  Future<SupportConversation> closeConversation(String conversationId) async {
    final response = await ApiService.post(
      '${EndPoints.apiSupportConversations}/$conversationId/close',
      {},
      requireAuthToken: true,
    );

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation as Map),
    );
  }

  Future<SupportConversation> reopenConversation(String conversationId) async {
    final response = await ApiService.post(
      '${EndPoints.apiSupportConversations}/$conversationId/reopen',
      {},
      requireAuthToken: true,
    );

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation as Map),
    );
  }

  /// Reads the backend error message so the UI can show something useful.
  static String errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['error'] ?? data['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }
      }
    }

    return fallback;
  }

  // ================= Booking-specific help =================

  /// Categories + questions that apply to this booking right now.
  Future<BookingHelpPayload> fetchBookingHelp(String bookingId) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportBookings}/$bookingId/help',
      requireAuthToken: true,
    );

    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return BookingHelpPayload.fromJson(data);
  }

  /// Answer composed from the authoritative booking/payment state.
  Future<BookingHelpAnswer> fetchBookingAnswer(
    String bookingId,
    String questionId,
  ) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportBookings}/$bookingId/help/$questionId',
      requireAuthToken: true,
    );

    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return BookingHelpAnswer.fromJson(data);
  }

  /// Active chat for this booking, or null when there is none yet.
  Future<SupportConversation?> getBookingConversation(String bookingId) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportBookings}/$bookingId/conversation',
      requireAuthToken: true,
    );

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    if (conversation is! Map) return null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation),
    );
  }

  /// Creates (or reuses) the conversation linked to this booking.
  Future<SupportConversation> startBookingConversation(
    String bookingId, {
    String? category,
    String? questionId,
    String? questionEn,
    String? questionAr,
    String? lastAttemptedSolution,
    String? priority,
  }) async {
    final response = await ApiService.post(
      '${EndPoints.apiSupportBookings}/$bookingId/conversation',
      {
        'source': 'booking_help',
        if (category != null) 'category': category,
        if (questionId != null) 'question_id': questionId,
        if (questionEn != null) 'question_en': questionEn,
        if (questionAr != null) 'question_ar': questionAr,
        if (lastAttemptedSolution != null)
          'last_attempted_solution': lastAttemptedSolution,
        if (priority != null) 'priority': priority,
      },
      requireAuthToken: true,
    );

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation as Map),
    );
  }

  /// One conversation by id (used when the help flow already created it).
  Future<SupportConversation> fetchConversation(String conversationId) async {
    final response = await ApiService.get(
      '${EndPoints.apiSupportConversations}/$conversationId',
      requireAuthToken: true,
    );

    final conversation = (response.data is Map)
        ? response.data['conversation']
        : null;

    return SupportConversation.fromJson(
      Map<String, dynamic>.from(conversation as Map),
    );
  }
}
