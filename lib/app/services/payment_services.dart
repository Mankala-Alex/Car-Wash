import 'package:dio/dio.dart';

class PaymentService {
  final Dio _dio = Dio();

  // Change base URL if needed
  final String baseUrl = "https://www.aguawash.com/api";

  /// Create Payment
  Future<Map<String, dynamic>> createPayment({
    required String bookingId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        "$baseUrl/payment/create",
        data: {"booking_id": bookingId, "amount": amount},
      );

      return response.data;
    } catch (e) {
      throw Exception("Payment create failed: $e");
    }
  }

  /// Check Payment Status
  Future<String> checkPaymentStatus(String bookingId) async {
    try {
      final response = await _dio.get(
        "$baseUrl/payment/status/$bookingId",
      );

      return response.data["payment_status"];
    } catch (e) {
      throw Exception("Payment status failed: $e");
    }
  }
}
