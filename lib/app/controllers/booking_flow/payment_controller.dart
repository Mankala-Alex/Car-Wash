import 'dart:async';

import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  RxBool isLoading = false.obs;

  String bookingId = "";
  double amount = 0.0;

  @override
  void onInit() {
    super.onInit();

    /// Receive booking data
    final args = Get.arguments;

    bookingId = args["bookingId"];
    amount = args["amount"];
  }

  /// Pay Now
  Future<void> payNow() async {
    try {
      isLoading.value = true;

      final response = await _service.createPayment(
        bookingId: bookingId,
        amount: amount,
      );

      if (response["success"]) {
        String paymentUrl = response["payment_url"];

        /// Open WebView
        Get.toNamed(
          "/payment_webview",
          arguments: {
            "url": paymentUrl,
            "bookingId": bookingId,

            /// Forward confirmation data
            "service_name": Get.arguments["service_name"],
            "scheduled_at": Get.arguments["scheduled_at"],
            "amount": Get.arguments["amount"],
            "image": Get.arguments["image"],
            "booking_code": Get.arguments["booking_code"],
          },
        );
      } else {
        Get.snackbar(
          "Error",
          "Payment creation failed",
        );
      }
    } catch (e) {
      print("Payment Error: $e");

      Get.snackbar(
        "Error",
        "Payment failed",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
