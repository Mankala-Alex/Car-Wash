import 'dart:async';

import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController controller;

  final PaymentService service = PaymentService();

  late String paymentUrl;
  late String bookingId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;

    paymentUrl = args["url"];
    bookingId = args["bookingId"];

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            print("Redirect URL: ${request.url}");

            /// Detect callback URL
            if (request.url.contains("payment/callback")) {
              print("Payment callback detected");

              checkPayment();

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(paymentUrl),
      );
  }

  /// Check payment result
  Future<void> checkPayment() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final status = await service.checkPaymentStatus(bookingId);

      print("Payment Status: $status");

      if (status == "PAID") {
        errorToast(
          "payment_successful".tr,
        );

        Get.offAllNamed(
          Routes.confirmationpageview,
          arguments: Get.arguments,
        );
      }

      if (status == "FAILED") {
        errorToast(
          "payment_failed".tr,
        );

        Get.back();
      }
    } catch (e) {
      print("Status check error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "payment".tr,
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
