import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Extracts a human readable error message from an exception thrown by
/// [ApiService] calls.
///
/// Dio throws a [DioException] for any non-2xx status code (400, 401, 422, 500...),
/// so the backend message lives in `e.response?.data` and NOT in the
/// returned `Response` object. Without this helper the UI falls back to a
/// generic message (e.g. "Signup failed") and the real reason sent by the
/// server is lost.
///
/// [fallback] is returned when no server message can be found.
///
/// IMPORTANT: this never returns technical text such as
/// `DioException [connection timeout]: The request connection took longer than…`
/// — customers only see short, human friendly sentences.
String apiErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    // 1) Prefer a message the backend actually sent.
    final serverMessage = _serverMessageFrom(error.response?.data);
    if (serverMessage != null) return serverMessage;

    // 2) Otherwise map the failure type to a friendly sentence.
    switch (error.type) {
      case DioExceptionType.badResponse:
        return _messageForStatusCode(error.response?.statusCode, fallback);

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Server did not answer in time (slow network / server not reachable).
        return "request_took_too_long".tr;

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        // No connection at all / DNS failure / socket error.
        return "connection_problem_try_again".tr;

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
        return fallback;
    }
  }

  // Any other thrown object is an internal/programming error. Showing
  // `toString()` to the customer is never useful, so use the fallback.
  //
  // Exception: `ApiService` throws `Exception("No Internet")` after showing the
  // offline popup — that one still deserves a friendly network sentence.
  final text = error.toString().toLowerCase();
  if (text.contains("no internet") || text.contains("socketexception")) {
    return "connection_problem_try_again".tr;
  }

  return fallback;
}

/// Reads `{message}` / `{error}` / `{msg}` or validation `{errors: {...}}`.
String? _serverMessageFrom(dynamic data) {
  if (data is Map) {
    final message = data["message"] ?? data["error"] ?? data["msg"];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    // Validation errors: { "errors": { "phone": ["..."] } }
    final errors = data["errors"];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        final text = first.first.toString().trim();
        if (text.isNotEmpty) return text;
      }
      if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }
  }

  if (data is String && data.trim().isNotEmpty) {
    return data.trim();
  }

  return null;
}

/// Friendly message for responses that carried no readable body.
String _messageForStatusCode(int? statusCode, String fallback) {
  if (statusCode == null) return fallback;

  if (statusCode == 401) return "session_expired_login".tr;
  if (statusCode == 408 || statusCode == 504) {
    return "request_took_too_long".tr;
  }
  if (statusCode == 429 || statusCode >= 500) {
    return "server_busy_try_again".tr;
  }

  return fallback;
}

/// The backend answers an early "resend OTP" with 429 and
/// `{ retry_after_seconds: N }`. Returning N lets the screen keep counting down
/// instead of pretending the cooldown already finished.
int? apiRetryAfterSeconds(Object error) {
  if (error is! DioException) return null;

  final data = error.response?.data;
  if (data is! Map) return null;

  final value = data['retry_after_seconds'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

/// Machine readable OTP failure code (`OTP_EXPIRED`, `OTP_INVALID`,
/// `OTP_ATTEMPTS_EXCEEDED`, `OTP_NOT_FOUND`, `OTP_RESEND_TOO_SOON`...).
String? apiErrorCode(Object error) {
  if (error is! DioException) return null;

  final data = error.response?.data;
  if (data is! Map) return null;

  final code = data['code'];
  return code?.toString();
}
