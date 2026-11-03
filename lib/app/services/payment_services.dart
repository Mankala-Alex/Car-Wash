import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/models/payment/saved_card_model.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class PaymentService {
  Future<Map<String, dynamic>> createPayment({
    required String customerId,
    required String customerName,
    required String vehicle,
    required String serviceId,
    required String serviceName,
    required int slotId,
    required String scheduledAt,
    required double amount,
    double? latitude,
    double? longitude,
    String? pincode,
    String? city,
    String? formattedAddress,
    String? address,
    String? houseNumber,
    String? landmark,
    String? addressLabel,
    bool saveCard = false,
    int? savedCardId,
  }) async {
    try {
      final requestBody = {
        "customer_id": customerId,
        "customer_name": customerName,
        "vehicle": vehicle,
        "service_id": serviceId,
        "service_name": serviceName,
        "slot_id": slotId,
        "scheduled_at": scheduledAt,
        "amount": amount,
        "latitude": latitude,
        "longitude": longitude,
        "pincode": pincode,
        "city": city,
        "formatted_address": formattedAddress,
        "address": address,
        "house_number": houseNumber,
        "landmark": landmark,
        "address_label": addressLabel,
        // Tokenization: `save_card` only applies to a newly typed card, while
        // `saved_card_id` tells the backend to reuse a stored Paymob token.
        "save_card": saveCard,
        "saved_card_id": savedCardId,
      };

      print("========================================");
      print("💳 PAYMENT CREATE REQUEST");
      print("ENDPOINT: ${EndPoints.apiPaymentCreate}");
      print("Pincode: $pincode | City: $city");
      print("BODY: $requestBody");
      print("========================================");

      final response = await ApiService.post(
        EndPoints.apiPaymentCreate,
        requestBody,
        requireAuthToken: true,
      );

      print("========================================");
      print("💳 PAYMENT CREATE RESPONSE");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print("========================================");
      print("❌ PAYMENT CREATE DIO ERROR");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("========================================");

      throw Exception(
        "Payment create failed: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );
    } catch (e) {
      print("❌ PAYMENT CREATE ERROR: $e");
      throw Exception("Payment create failed: $e");
    }
  }

  /// Returns the cards the signed-in customer saved with Paymob.
  ///
  /// Expected shape:
  /// ```json
  /// { "success": true,
  ///   "cards": [ { "id": 3, "masked_pan": "xxxx-1111",
  ///                "card_brand": "VISA", "is_default": true } ] }
  /// ```
  /// The Paymob token itself never leaves the backend — only `id` is used.
  Future<List<SavedCardModel>> fetchSavedCards() async {
    try {
      final response = await ApiService.get(
        EndPoints.apiSavedCards,
        requireAuthToken: true,
      );

      print("========================================");
      print("💳 SAVED CARDS RESPONSE");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      final data = response.data;

      if (data is! Map) return [];

      final cards = data["cards"];

      if (cards is! List) return [];

      return cards
          .whereType<Map>()
          .map((card) => SavedCardModel.fromJson(
                Map<String, dynamic>.from(card),
              ))
          .where((card) => card.id > 0)
          .toList();
    } on DioException catch (e) {
      // A logged-out / expired session must not break checkout: the customer
      // can still pay by typing the card.
      print(
        "⚠️ SAVED CARDS ERROR: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );

      return [];
    } catch (e) {
      print("⚠️ SAVED CARDS ERROR: $e");
      return [];
    }
  }

  /// Removes a saved card from the account.
  ///
  /// Returns true only when the backend confirms the deletion, so the UI never
  /// hides a card that still exists on the server.
  Future<bool> deleteSavedCard(int cardId) async {
    try {
      final response = await ApiService.delete(
        "${EndPoints.apiSavedCards}/$cardId",
        requireAuthToken: true,
      );

      print("========================================");
      print("🗑️ DELETE SAVED CARD");
      print("Card ID: $cardId");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      final data = response.data;

      return data is Map && data["success"] == true;
    } on DioException catch (e) {
      print(
        "❌ DELETE SAVED CARD ERROR: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );

      return false;
    } catch (e) {
      print("❌ DELETE SAVED CARD ERROR: $e");
      return false;
    }
  }

  /// Returns the payment methods the backend currently has enabled.
  ///
  /// Expected shape:
  /// ```json
  /// { "success": true,
  ///   "payment_methods": { "card": { "enabled": true },
  ///                        "apple_pay": { "enabled": true } } }
  /// ```
  /// Nothing is assumed about Apple Pay: it is offered only when the backend
  /// reports it as enabled.
  Future<Map<String, dynamic>> fetchPaymentMethods() async {
    try {
      final response = await ApiService.get(
        EndPoints.apiPaymentMethods,
        requireAuthToken: true,
      );

      print("========================================");
      print("💳 PAYMENT METHODS RESPONSE");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      final data = response.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception("Unexpected payment methods response: ${response.data}");
    } on DioException catch (e) {
      print("❌ PAYMENT METHODS ERROR: "
          "${e.response?.statusCode} - ${e.response?.data}");

      throw Exception(
        "Payment methods failed: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );
    }
  }

  /// Creates a Paymob payment intention for Apple Pay.
  ///
  /// A successful response only means the intention was created — the payment
  /// is NOT complete until `/payment/status/attempt/:id` reports `PAID`.
  ///
  /// The request mirrors [createPayment]'s booking + location payload because
  /// the backend re-validates the service area on this endpoint too.
  Future<Map<String, dynamic>> createApplePayPayment({
    required String customerId,
    required String customerName,
    required String vehicle,
    required String serviceId,
    required String serviceName,
    required int slotId,
    required String scheduledAt,
    required double amount,
    double? latitude,
    double? longitude,
    String? pincode,
    String? city,
    String? formattedAddress,
    String? address,
    String? houseNumber,
    String? landmark,
    String? addressLabel,
  }) async {
    try {
      final requestBody = {
        "customer_id": customerId,
        "customer_name": customerName,
        "vehicle": vehicle,
        "service_id": serviceId,
        "service_name": serviceName,
        "slot_id": slotId,
        "scheduled_at": scheduledAt,
        "amount": amount,
        "latitude": latitude,
        "longitude": longitude,
        "pincode": pincode,
        "city": city,
        "formatted_address": formattedAddress,
        "address": address,
        "house_number": houseNumber,
        "landmark": landmark,
        "address_label": addressLabel,
      };

      print("========================================");
      print("🍎 APPLE PAY CREATE REQUEST");
      print("ENDPOINT: ${EndPoints.apiApplePayCreate}");
      print("Pincode: $pincode | City: $city");
      print("BODY: $requestBody");
      print("========================================");

      final response = await ApiService.post(
        EndPoints.apiApplePayCreate,
        requestBody,
        requireAuthToken: true,
      );

      print("========================================");
      print("🍎 APPLE PAY CREATE RESPONSE");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      final data = response.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception("Unexpected Apple Pay response: ${response.data}");
    } on DioException catch (e) {
      print("========================================");
      print("❌ APPLE PAY CREATE DIO ERROR");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("========================================");

      throw Exception(
        "Apple Pay create failed: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );
    } catch (e) {
      print("❌ APPLE PAY CREATE ERROR: $e");
      throw Exception("Apple Pay create failed: $e");
    }
  }

  Future<String?> checkPaymentStatus(
    String bookingId,
  ) async {
    try {
      final response = await ApiService.get(
        "${EndPoints.apiPaymentStatus}/$bookingId",
        requireAuthToken: true,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data["payment_status"]?.toString();
      }

      return null;
    } catch (e) {
      throw Exception(
        "Payment status failed: $e",
      );
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatusByAttempt(
    String paymentAttemptId,
  ) async {
    try {
      final response = await ApiService.get(
        "${EndPoints.apiPaymentStatusByAttempt}/$paymentAttemptId",
        requireAuthToken: true,
      );

      print("========================================");
      print("💳 PAYMENT ATTEMPT STATUS");
      print("Attempt ID: $paymentAttemptId");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");
      print("========================================");

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          response.data,
        );
      }

      return {};
    } catch (e) {
      print(
        "❌ Payment attempt status error: $e",
      );

      throw Exception(
        "Payment attempt status failed: $e",
      );
    }
  }
}
// import 'package:dio/dio.dart';

// class PaymentService {
//   final Dio _dio = Dio();

//   // Change base URL if needed
//   //final String baseUrl = "https://www.washgate4carwash.com/api";
//   final String baseUrl = "http://10.0.2.2:3000/api";

//   Future<Map<String, dynamic>> createPayment({
//     required String customerId,
//     required String customerName,
//     required String vehicle,
//     required String serviceId,
//     required String serviceName,
//     required int slotId,
//     required String scheduledAt,
//     required double amount,
//     double? latitude,
//     double? longitude,
//     String? formattedAddress,
//     String? address,
//     String? houseNumber,
//     String? landmark,
//     String? addressLabel,
//   }) async {
//     try {
//       final url = "$baseUrl/payment/create";

//       final requestBody = {
//         "customer_id": customerId,
//         "customer_name": customerName,
//         "vehicle": vehicle,
//         "service_id": serviceId,
//         "service_name": serviceName,
//         "slot_id": slotId,
//         "scheduled_at": scheduledAt,
//         "amount": amount,
//         "latitude": latitude,
//         "longitude": longitude,
//         "formatted_address": formattedAddress,
//         "address": address,
//         "house_number": houseNumber,
//         "landmark": landmark,
//         "address_label": addressLabel,
//       };

//       print("========================================");
//       print("💳 PAYMENT CREATE REQUEST");
//       print("URL: $url");
//       print("BODY: $requestBody");
//       print("========================================");

//       final response = await _dio.post(
//         url,
//         data: requestBody,
//       );

//       print("========================================");
//       print("💳 PAYMENT CREATE RESPONSE");
//       print("Status: ${response.statusCode}");
//       print("Data: ${response.data}");
//       print("========================================");

//       return Map<String, dynamic>.from(response.data);
//     } on DioException catch (e) {
//       print("========================================");
//       print("❌ PAYMENT CREATE DIO ERROR");
//       print("URL: ${e.requestOptions.uri}");
//       print("Request data: ${e.requestOptions.data}");
//       print("Status: ${e.response?.statusCode}");
//       print("Response: ${e.response?.data}");
//       print("========================================");

//       throw Exception(
//         "Payment create failed: "
//         "${e.response?.statusCode} - ${e.response?.data}",
//       );
//     } catch (e) {
//       print("❌ PAYMENT CREATE ERROR: $e");
//       throw Exception("Payment create failed: $e");
//     }
//   }
//   // Future<Map<String, dynamic>> createPayment({
//   //   required String bookingId,
//   //   required double amount,
//   // }) async {
//   //   try {
//   //     final url = "$baseUrl/payment/create";

//   //     print("========================================");
//   //     print("💳 PAYMENT CREATE REQUEST");
//   //     print("URL: $url");
//   //     print("Booking ID: $bookingId");
//   //     print("Amount: $amount");
//   //     print("========================================");

//   //     final response = await _dio.post(
//   //       url,
//   //       data: {
//   //         "booking_id": bookingId,
//   //         "amount": amount,
//   //       },
//   //     );

//   //     print("========================================");
//   //     print("💳 PAYMENT CREATE RESPONSE");
//   //     print("Status: ${response.statusCode}");
//   //     print("Data: ${response.data}");
//   //     print("========================================");

//   //     return Map<String, dynamic>.from(response.data);
//   //   } on DioException catch (e) {
//   //     print("========================================");
//   //     print("❌ PAYMENT CREATE DIO ERROR");
//   //     print("URL: ${e.requestOptions.uri}");
//   //     print("Method: ${e.requestOptions.method}");
//   //     print("Request data: ${e.requestOptions.data}");
//   //     print("Status: ${e.response?.statusCode}");
//   //     print("Response data: ${e.response?.data}");
//   //     print("Response headers: ${e.response?.headers}");
//   //     print("DioException type: ${e.type}");
//   //     print("DioException message: ${e.message}");
//   //     print("DioException error: ${e.error}");
//   //     print("========================================");

//   //     throw Exception(
//   //       "Payment create failed: "
//   //       "${e.response?.statusCode} - ${e.response?.data} - ${e.message}",
//   //     );
//   //   } catch (e) {
//   //     print("❌ PAYMENT CREATE ERROR: $e");
//   //     throw Exception("Payment create failed: $e");
//   //   }
//   // }

//   // /// Create Payment
//   // Future<Map<String, dynamic>> createPayment({
//   //   required String bookingId,
//   //   required double amount,
//   // }) async {
//   //   try {
//   //     final response = await _dio.post(
//   //       "$baseUrl/payment/create",
//   //       data: {"booking_id": bookingId, "amount": amount},
//   //     );

//   //     return response.data;
//   //   } catch (e) {
//   //     throw Exception("Payment create failed: $e");
//   //   }
//   // }

//   /// Check Payment Status
//   // Future<String> checkPaymentStatus(String bookingId) async {
//   //   try {
//   //     final response = await _dio.get(
//   //       "$baseUrl/payment/status/$bookingId",
//   //     );

//   //     return response.data["payment_status"];
//   //   } catch (e) {
//   //     throw Exception("Payment status failed: $e");
//   //   }
//   // }
//   Future<String?> checkPaymentStatus(String bookingId) async {
//     try {
//       final response = await _dio.get(
//         "$baseUrl/payment/status/$bookingId",
//       );

//       final data = response.data;

//       if (data is Map<String, dynamic>) {
//         return data["payment_status"]?.toString();
//       }

//       return null;
//     } catch (e) {
//       throw Exception("Payment status failed: $e");
//     }
//   }

//   Future<Map<String, dynamic>> checkPaymentStatusByAttempt(
//     String paymentAttemptId,
//   ) async {
//     try {
//       final response = await _dio.get(
//         "$baseUrl/payment/status/attempt/$paymentAttemptId",
//       );

//       print("========================================");
//       print("💳 PAYMENT ATTEMPT STATUS");
//       print("Attempt ID: $paymentAttemptId");
//       print("Status: ${response.statusCode}");
//       print("Data: ${response.data}");
//       print("========================================");

//       if (response.data is Map<String, dynamic>) {
//         return Map<String, dynamic>.from(
//           response.data,
//         );
//       }

//       return {};
//     } catch (e) {
//       print(
//         "❌ Payment attempt status error: $e",
//       );

//       throw Exception(
//         "Payment attempt status failed: $e",
//       );
//     }
//   }
// }
