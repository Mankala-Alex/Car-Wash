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
String apiErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map) {
      // Most common shapes: { "message": "..." } / { "error": "..." }
      final message = data["message"] ?? data["error"] ?? data["msg"];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      // Validation errors: { "errors": { "phone": ["..."] } }
      final errors = data["errors"];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
        if (first is String && first.trim().isNotEmpty) {
          return first.trim();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    // No body at all → give a hint about the status code.
    if (error.response?.statusCode == 401) {
      return "session_expired_login".tr;
    }
  }

  // Plain `Exception("No Internet")` or any unexpected error.
  final text = error.toString().replaceFirst("Exception: ", "").trim();
  if (text.isNotEmpty && text != "null") return text;

  return fallback;
}
