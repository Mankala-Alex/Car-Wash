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

  bool _checkingPayment = false;

  Future<void> checkPayment() async {
    if (_checkingPayment) return;

    _checkingPayment = true;

    try {
      // Check payment status repeatedly for up to 60 seconds.
      for (int i = 0; i < 30; i++) {
        if (!mounted) return;

        final status = await service.checkPaymentStatus(bookingId);

        print("Payment status attempt ${i + 1}: $status");

        if (status == "PAID") {
          if (!mounted) return;

          successToast("payment_successful".tr);

          Get.offAllNamed(
            Routes.confirmationpageview,
            arguments: Get.arguments,
          );
          return;
        }

        if (status == "FAILED") {
          if (!mounted) return;

          errorToast("payment_failed".tr);
          Get.back();
          return;
        }

        // Still INITIATED or pending: try again.
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        errorToast(
          "Payment is still processing. Please check your booking status.",
        );
      }
    } catch (e) {
      print("Status check error: $e");

      if (mounted) {
        errorToast(
          "Could not verify payment status. Please check your booking.",
        );
      }
    } finally {
      _checkingPayment = false;
    }
  }

  /// Check payment result
  // Future<void> checkPayment() async {
  //   try {
  //     await Future.delayed(const Duration(seconds: 3));

  //     final status = await service.checkPaymentStatus(bookingId);

  //     print("Payment Status: $status");

  //     if (status == "PAID") {
  //       errorToast(
  //         "payment_successful".tr,
  //       );

  //       Get.offAllNamed(
  //         Routes.confirmationpageview,
  //         arguments: Get.arguments,
  //       );
  //     }

  //     if (status == "FAILED") {
  //       errorToast(
  //         "payment_failed".tr,
  //       );

  //       Get.back();
  //     }
  //   } catch (e) {
  //     print("Status check error: $e");
  //   }
  // }

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
