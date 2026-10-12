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
  late String paymentAttemptId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    paymentUrl = args["url"]?.toString() ?? "";

    paymentAttemptId = args["paymentAttemptId"]?.toString() ?? "";

    print("========================================");
    print("💳 PAYMENT WEBVIEW");
    print("Payment Attempt ID: $paymentAttemptId");
    print("Payment URL: $paymentUrl");
    print("========================================");

    if (paymentAttemptId.isEmpty) {
      print("❌ Payment attempt ID is missing");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          errorToast("Payment initialization failed");
          Get.back();
        }
      });

      return;
    }

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      );

    final uri = Uri.tryParse(paymentUrl);

    if (uri == null ||
        !(uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      print("❌ Invalid payment URL: $paymentUrl");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          errorToast("Invalid payment URL");
          Get.back();
        }
      });

      return;
    }

    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          print("🌐 Redirect URL: ${request.url}");

          if (request.url.contains(
                "ksa.paymob.com/api/acceptance/post_pay",
              ) ||
              request.url.contains(
                "/api/payment/callback",
                //"washgate4carwash.com/api/payment/callback",
              )) {
            print("✅ Paymob payment redirect detected");

            checkPayment();

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          print("🌐 WebView page started: $url");
        },
        onPageFinished: (url) {
          print("🌐 WebView page finished: $url");
        },
        onWebResourceError: (error) {
          print(
            "❌ WebView error: "
            "${error.description} "
            "(code: ${error.errorCode})",
          );

          errorToast(
            "Could not load payment page.",
          );
        },
      ),
    );

    controller.loadRequest(uri);
  }

  bool _checkingPayment = false;

  Future<void> checkPayment() async {
    if (_checkingPayment) return;

    _checkingPayment = true;

    try {
      print("========================================");
      print("🔍 CHECKING PAYMENT");
      print("Attempt ID: $paymentAttemptId");
      print("========================================");

      // Check payment status repeatedly
      // for up to 60 seconds.
      for (int i = 0; i < 30; i++) {
        if (!mounted) return;

        final result = await service.checkPaymentStatusByAttempt(
          paymentAttemptId,
        );

        final status = result["payment_status"]?.toString();

        final bookingId = result["booking_id"]?.toString();

        final bookingReference = result["booking_reference"]?.toString();

        print(
          "Payment status attempt ${i + 1}: "
          "$status",
        );

        print(
          "Booking ID: $bookingId",
        );

        print(
          "Booking Reference: $bookingReference",
        );

        // ========================================
        // PAYMENT SUCCESS
        // ========================================

        if (status == "PAID") {
          if (!mounted) return;

          print("========================================");
          print("✅ PAYMENT SUCCESSFUL");
          print("Booking ID: $bookingId");
          print("Booking Reference: $bookingReference");
          print("========================================");

          successToast(
            "payment_successful".tr,
          );

          final currentArgs = Map<String, dynamic>.from(
            Get.arguments ?? {},
          );

          // Add backend-created booking information
          currentArgs["bookingId"] = bookingId;
          currentArgs["booking_reference"] = bookingReference;

          Get.offAllNamed(
            Routes.confirmationpageview,
            arguments: currentArgs,
          );

          return;
        }

        // ========================================
        // PAYMENT FAILED
        // ========================================

        if (status == "FAILED") {
          if (!mounted) return;

          print("❌ PAYMENT FAILED");

          errorToast(
            "payment_failed".tr,
          );

          Get.back();

          return;
        }

        // Still INITIATED / PENDING
        await Future.delayed(
          const Duration(seconds: 2),
        );
      }

      // ========================================
      // TIMEOUT
      // ========================================

      if (mounted) {
        errorToast(
          "Payment is still processing. "
          "Please check your booking status.",
        );
      }
    } catch (e) {
      print(
        "❌ Status check error: $e",
      );

      if (mounted) {
        errorToast(
          "Could not verify payment status. "
          "Please check your booking.",
        );
      }
    } finally {
      _checkingPayment = false;
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
} // import 'dart:async';

  // import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
  // import 'package:car_wash_customer_app/app/routes/app_routes.dart';
  // import 'package:car_wash_customer_app/app/services/payment_services.dart';
  // import 'package:flutter/material.dart';
  // import 'package:get/get.dart';
  // import 'package:webview_flutter/webview_flutter.dart';

  // class PaymentWebView extends StatefulWidget {
  //   const PaymentWebView({super.key});

  //   @override
  //   State<PaymentWebView> createState() => _PaymentWebViewState();
  // }

  // class _PaymentWebViewState extends State<PaymentWebView> {
  //   late WebViewController controller;

  //   final PaymentService service = PaymentService();

  //   late String paymentUrl;
  //   late String bookingId;

  //   @override
  //   void initState() {
  //     super.initState();

  //     final args = Get.arguments;

  //     paymentUrl = args["url"];
  //     bookingId = args["bookingId"];

  //     controller = WebViewController()
  //       ..setJavaScriptMode(JavaScriptMode.unrestricted);

  //     // Validate URL before loading
  //     final uri = Uri.tryParse(paymentUrl ?? "");
  //     if (uri == null ||
  //         !(uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
  //       print("Invalid payment URL: $paymentUrl");
  //       errorToast("Invalid payment URL");
  //       // go back to previous screen
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted) Get.back();
  //       });
  //       return;
  //     }

  //     controller.setNavigationDelegate(
  //       NavigationDelegate(
  //         onNavigationRequest: (request) {
  //           print("Redirect URL: ${request.url}");

  //           if (request.url.contains(
  //                 "ksa.paymob.com/api/acceptance/post_pay",
  //               ) ||
  //               request.url.contains(
  //                 "washgate4carwash.com/api/payment/callback",
  //               )) {
  //             print("✅ Paymob payment redirect detected");

  //             checkPayment();

  //             return NavigationDecision.prevent;
  //           }
  //           // Detect callback URL
  //           // if (request.url.contains("payment/callback")) {
  //           //   print("Payment callback detected");

  //           //   checkPayment();

  //           //   return NavigationDecision.prevent;
  //           // }

  //           return NavigationDecision.navigate;
  //         },
  //         onPageStarted: (url) {
  //           print('WebView page started: $url');
  //         },
  //         onPageFinished: (url) {
  //           print('WebView page finished: $url');
  //         },
  //         onWebResourceError: (error) {
  //           print(
  //               'WebView error: ${error.description} (code: ${error.errorCode})');
  //           errorToast('Could not load payment page.');
  //         },
  //       ),
  //     );

  //     controller.loadRequest(uri);
  //   }

  //   bool _checkingPayment = false;

  //   Future<void> checkPayment() async {
  //     if (_checkingPayment) return;

  //     _checkingPayment = true;

  //     try {
  //       // Check payment status repeatedly for up to 60 seconds.
  //       for (int i = 0; i < 30; i++) {
  //         if (!mounted) return;

  //         final status = await service.checkPaymentStatus(bookingId);

  //         print("Payment status attempt ${i + 1}: $status");

  //         if (status == "PAID") {
  //           if (!mounted) return;

  //           successToast("payment_successful".tr);

  //           Get.offAllNamed(
  //             Routes.confirmationpageview,
  //             arguments: Get.arguments,
  //           );
  //           return;
  //         }

  //         if (status == "FAILED") {
  //           if (!mounted) return;

  //           errorToast("payment_failed".tr);
  //           Get.back();
  //           return;
  //         }

  //         // Still INITIATED or pending: try again.
  //         await Future.delayed(const Duration(seconds: 2));
  //       }

  //       if (mounted) {
  //         errorToast(
  //           "Payment is still processing. Please check your booking status.",
  //         );
  //       }
  //     } catch (e) {
  //       print("Status check error: $e");

  //       if (mounted) {
  //         errorToast(
  //           "Could not verify payment status. Please check your booking.",
  //         );
  //       }
  //     } finally {
  //       _checkingPayment = false;
  //     }
  //   }

  //   /// Check payment result
  //   // Future<void> checkPayment() async {
  //   //   try {
  //   //     await Future.delayed(const Duration(seconds: 3));

  //   //     final status = await service.checkPaymentStatus(bookingId);

  //   //     print("Payment Status: $status");

  //   //     if (status == "PAID") {
  //   //       errorToast(
  //   //         "payment_successful".tr,
  //   //       );

  //   //       Get.offAllNamed(
  //   //         Routes.confirmationpageview,
  //   //         arguments: Get.arguments,
  //   //       );
  //   //     }

  //   //     if (status == "FAILED") {
  //   //       errorToast(
  //   //         "payment_failed".tr,
  //   //       );

  //   //       Get.back();
  //   //     }
  //   //   } catch (e) {
  //   //     print("Status check error: $e");
  //   //   }
  //   // }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text(
  //           "payment".tr,
  //         ),
  //       ),
  //       body: WebViewWidget(
  //         controller: controller,
  //       ),
  //     );
  //   }
  // }
