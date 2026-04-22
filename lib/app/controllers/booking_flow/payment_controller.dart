import 'dart:async';

import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  RxBool isLoading = false.obs;

  String bookingId = "";
  double amount = 0.0;

  /// NEW fields
  String serviceName = "";
  String scheduledAt = "";
  String image = "";
  String bookingCode = "";

  String get formattedDate {
    final dt = DateTime.tryParse(scheduledAt);
    if (dt == null) return "";
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt.toLocal());
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    bookingId = args["bookingId"];
    amount = args["amount"];

    /// NEW
    serviceName = args["service_name"] ?? "";
    scheduledAt = args["scheduled_at"] ?? "";
    image = args["image"] ?? "";
    bookingCode = args["booking_code"] ?? "";
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

        Get.toNamed(
          "/payment_webview",
          arguments: {
            "url": paymentUrl,
            "bookingId": bookingId,

            /// Forward confirmation data
            "service_name": serviceName,
            "scheduled_at": scheduledAt,
            "amount": amount,
            "image": image,
            "booking_code": bookingCode,
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
