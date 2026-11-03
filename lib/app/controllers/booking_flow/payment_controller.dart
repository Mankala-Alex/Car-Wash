import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// What happened after asking the backend to pay by card.
enum CardChargeOutcome {
  /// The Paymob checkout (or its 3-D Secure step) is now open in the WebView.
  redirected,

  /// A saved card was charged and the booking already exists.
  completed,

  /// A saved card charge is still being settled; the callback will finish it.
  pending,

  /// Paymob refused the saved card — nothing was charged. The customer should
  /// be offered a new card instead.
  savedCardRejected,

  /// Something else went wrong; the app already told the customer.
  failed,
}

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  RxBool isLoading = false.obs;

  // ==============================
  // PAYMENT ATTEMPT
  // ==============================

  String paymentAttemptId = "";
  String bookingReference = "";

  // ==============================
  // BOOKING DATA
  // ==============================

  String customerId = "";
  String customerName = "";
  String vehicle = "";

  String serviceId = "";
  String serviceName = "";

  int slotId = 0;
  String scheduledAt = "";

  double amount = 0.0;

  // ==============================
  // LOCATION
  // ==============================

  double? latitude;
  double? longitude;

  String? formattedAddress;
  String? address;
  String? houseNumber;
  String? landmark;
  String? addressLabel;
  String? pincode;

  /// City resolved by the availability check. Required so `payment/create`
  /// can apply the same city-level fallback (the pincode alone often isn't a
  /// configured service-area row).
  String? city;

  // ==============================
  // UI
  // ==============================

  String image = "";

  String get formattedDate {
    final dt = DateTime.tryParse(scheduledAt);

    if (dt == null) return "";

    // `scheduled_at` is already the wall-clock slot time, so don't call
    // toLocal() here (it would shift the time by the device's timezone).
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt);
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    // Booking/payment data
    customerId = args["customer_id"]?.toString() ?? "";
    customerName = args["customer_name"]?.toString() ?? "";
    vehicle = args["vehicle"]?.toString() ?? "";

    serviceId = args["service_id"]?.toString() ?? "";
    serviceName = args["service_name"]?.toString() ?? "";

    slotId = int.tryParse(args["slot_id"]?.toString() ?? "0") ?? 0;

    scheduledAt = args["scheduled_at"]?.toString() ?? "";

    amount = double.tryParse(args["amount"]?.toString() ?? "0") ?? 0.0;

    // Location
    latitude = args["latitude"] == null
        ? null
        : double.tryParse(args["latitude"].toString());

    longitude = args["longitude"] == null
        ? null
        : double.tryParse(args["longitude"].toString());

    formattedAddress = args["formatted_address"]?.toString();

    address = args["address"]?.toString();

    houseNumber = args["house_number"]?.toString();

    landmark = args["landmark"]?.toString();

    addressLabel = args["address_label"]?.toString();

    pincode = args["pincode"]?.toString();

    city = args["city"]?.toString();

    // UI
    image = args["image"]?.toString() ?? "";

    print("========================================");
    print("💳 PAYMENT SCREEN ARGUMENTS");
    print("Customer: $customerId");
    print("Customer Name: $customerName");
    print("Vehicle: $vehicle");
    print("Service ID: $serviceId");
    print("Service: $serviceName");
    print("Slot: $slotId");
    print("Scheduled: $scheduledAt");
    print("Amount: $amount");
    print("========================================");
  }

  /// Opens the payment method chooser. No payment attempt is created here —
  /// the existing card call now runs only after the customer picks Card.
  /// The booking arguments are forwarded untouched so no field is lost.
  void payNow() {
    Get.toNamed(
      Routes.paymentMethod,
      arguments: Map<String, dynamic>.from(Get.arguments ?? const {}),
    );
  }

  /// Returns to the slot picker with a fresh slot list after the chosen time
  /// turned out to be full (nothing was charged in that case).
  void _returnToSlots() {
    try {
      final bookSlot = Get.find<BookSlotController>();
      bookSlot.refreshSelectedDateSlots();
    } catch (e) {
      print("⚠️ Could not refresh slots: $e");
    }

    Get.until(
      (route) => route.settings.name == Routes.bookslot || route.isFirst,
    );
  }

  /// Existing Paymob card flow — `POST /api/payment/create`, then either the
  /// Paymob WebView or, when a saved card was charged and approved instantly,
  /// the confirmation screen.
  ///
  /// [saveCard] asks Paymob to tokenize the card the customer is about to type.
  /// [savedCardId] charges a card saved earlier; the backend looks the Paymob
  /// token up itself, so the app never handles it.
  Future<CardChargeOutcome> payWithCard({
    bool saveCard = false,
    int? savedCardId,
  }) async {
    try {
      isLoading.value = true;

      print("========================================");
      print("💳 PAY WITH CARD");
      print("Customer: $customerId");
      print("Vehicle: $vehicle");
      print("Service: $serviceName");
      print("Slot: $slotId");
      print("Amount: $amount");
      print("Save card: $saveCard");
      print("Saved card id: $savedCardId");
      print("========================================");

      final response = await _service.createPayment(
        customerId: customerId,
        customerName: customerName,
        vehicle: vehicle,
        serviceId: serviceId,
        serviceName: serviceName,
        slotId: slotId,
        scheduledAt: scheduledAt,
        amount: amount,
        latitude: latitude,
        longitude: longitude,
        pincode: pincode,
        city: city,
        formattedAddress: formattedAddress,
        address: address,
        houseNumber: houseNumber,
        landmark: landmark,
        addressLabel: addressLabel,
        saveCard: saveCard,
        savedCardId: savedCardId,
      );

      print("========================================");
      print("💳 CREATE PAYMENT RESPONSE");
      print("$response");
      print("========================================");

      paymentAttemptId = response["payment_attempt_id"]?.toString() ?? "";

      bookingReference = response["booking_reference"]?.toString() ?? "";

      if (response["success"] != true) {
        print("❌ Payment API returned success=false");

        final errorCode = response["error"]?.toString() ?? "";
        final serverMessage = response["message"]?.toString();

        // Nothing was charged and the backend already released the seat. Both
        // cases mean "pay with a new card instead".
        if (errorCode == "SAVED_CARD_REJECTED" ||
            errorCode == "THREE_DS_UNAVAILABLE") {
          errorToast(
            (serverMessage != null && serverMessage.isNotEmpty)
                ? serverMessage
                : "saved_card_not_available".tr,
          );

          return CardChargeOutcome.savedCardRejected;
        }

        errorToast(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : "payment_failed".tr,
        );

        return CardChargeOutcome.failed;
      }

      if (paymentAttemptId.isEmpty) {
        print("❌ Payment attempt ID missing from backend response");

        errorToast("payment_init_failed".tr);

        return CardChargeOutcome.failed;
      }

      // =========================================================
      // SAVED CARD CHARGED — already approved, no checkout needed
      // =========================================================
      final paymentStatus = response["payment_status"]?.toString() ?? "";

      if (paymentStatus == "PAID") {
        return _handlePaidAttempt(response);
      }

      if (paymentStatus == "PENDING") {
        print("⌛ Saved card charge is still pending");

        errorToast("payment_processing".tr);

        return CardChargeOutcome.pending;
      }

      // A settled attempt has no checkout URL to open: the card was declined,
      // or the seat was taken while paying. Never let that fall through to
      // "payment URL is empty".
      if (paymentStatus == "FAILED") {
        print("❌ Saved card charge was declined");

        errorToast(
          response["message"]?.toString() ?? "payment_failed".tr,
        );

        return CardChargeOutcome.failed;
      }

      if (paymentStatus == "SLOT_UNAVAILABLE") {
        print("🚫 Slot taken while charging the saved card");

        errorToast(
          response["message"]?.toString() ?? "slot_no_longer_available".tr,
        );

        _returnToSlots();

        return CardChargeOutcome.failed;
      }

      // =========================================================
      // PAYMOB (new card, or 3-D Secure for a saved card)
      // =========================================================
      final paymentUrl = response["payment_url"]?.toString();

      final requiresThreeDs = response["requires_three_ds"] == true;

      print("💳 PAYMENT URL: $paymentUrl");
      print("💳 THREE DS: $requiresThreeDs");
      print("💳 PAYMENT ATTEMPT ID: $paymentAttemptId");
      print("💳 BOOKING REFERENCE: $bookingReference");

      if (paymentUrl == null || paymentUrl.isEmpty) {
        errorToast("payment_url_empty".tr);

        return CardChargeOutcome.failed;
      }

      // A new card that Paymob refused to tokenize can still be paid — but the
      // customer must not be promised it will be saved.
      if (saveCard &&
          savedCardId == null &&
          response["save_card_enabled"] != true) {
        errorToast("save_card_not_supported".tr);
      }

      Get.toNamed(
        "/payment_webview",
        arguments: {
          "url": paymentUrl,

          // IMPORTANT:
          // There is NO bookingId here because
          // the real booking does not exist yet.
          "paymentAttemptId": paymentAttemptId,
          "booking_reference": bookingReference,

          // 3-D Secure for a saved card starts polling right away, because this
          // page may never show a Paymob "post pay" redirect.
          "autoCheck": requiresThreeDs,

          // UI data
          "service_name": serviceName,
          "scheduled_at": scheduledAt,
          "amount": amount,
          "image": image,
        },
      );

      return CardChargeOutcome.redirected;
    } catch (e) {
      print("❌ Payment Error: $e");

      final errorText = e.toString();

      // =====================================================
      // SLOT FULL / ALREADY TAKEN
      // =====================================================
      // The backend reserves the seat before creating the payment, so it
      // answers 409 SLOT_UNAVAILABLE instead of charging for a full slot.
      if (errorText.contains('SLOT_UNAVAILABLE')) {
        print("🚫 Slot unavailable — no payment was created");

        errorToast("slot_no_longer_available".tr);

        _returnToSlots();

        return CardChargeOutcome.failed;
      }

      final serviceAreaMessageMatch = RegExp(
        r'message\s*:\s*([^,\n}]+)',
      ).firstMatch(errorText);

      if (errorText.contains('SERVICE_AREA_NOT_AVAILABLE') &&
          serviceAreaMessageMatch != null) {
        final serviceAreaMessage = serviceAreaMessageMatch.group(1)?.trim();

        if (serviceAreaMessage != null &&
            serviceAreaMessage.isNotEmpty &&
            serviceAreaMessage != 'null') {
          errorToast(serviceAreaMessage);
          return CardChargeOutcome.failed;
        }
      }

      errorToast("payment_failed".tr);

      return CardChargeOutcome.failed;
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows the confirmation screen for a payment the backend already settled
  /// (a saved card charged without a 3-D Secure challenge).
  CardChargeOutcome _handlePaidAttempt(Map<String, dynamic> response) {
    final bookingId = response["booking_id"]?.toString() ?? "";

    print("========================================");
    print("✅ SAVED CARD PAID");
    print("Booking ID: $bookingId");
    print("Booking Reference: $bookingReference");
    print("========================================");

    successToast("payment_successful".tr);

    final args = Map<String, dynamic>.from(Get.arguments ?? const {});

    args["bookingId"] = bookingId;
    args["booking_reference"] = bookingReference;

    Get.offAllNamed(Routes.confirmationpageview, arguments: args);

    return CardChargeOutcome.completed;
  }
}

// import 'dart:async';

// import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
// import 'package:car_wash_customer_app/app/services/payment_services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class PaymentController extends GetxController {
//   final PaymentService _service = PaymentService();

//   RxBool isLoading = false.obs;

//   String bookingId = "";
//   double amount = 0.0;

//   /// NEW fields
//   String serviceName = "";
//   String scheduledAt = "";
//   String image = "";
//   String bookingCode = "";

//   String get formattedDate {
//     final dt = DateTime.tryParse(scheduledAt);
//     if (dt == null) return "";
//     return DateFormat('EEE, dd MMM • hh:mm a').format(dt.toLocal());
//   }

//   @override
//   void onInit() {
//     super.onInit();

//     final args = Get.arguments ?? {};

//     bookingId = args["bookingId"];
//     amount = args["amount"];

//     /// NEW
//     serviceName = args["service_name"] ?? "";
//     scheduledAt = args["scheduled_at"] ?? "";
//     image = args["image"] ?? "";
//     bookingCode = args["booking_code"] ?? "";
//   }

//   // Future<void> payNow() async {
//   //   Get.offAllNamed(
//   //     Routes.confirmationpageview,
//   //     arguments: {
//   //       "service_name": serviceName,
//   //       "scheduled_at": scheduledAt,
//   //       "amount": amount,
//   //       "image": image,
//   //       "booking_code": bookingCode,
//   //     },
//   //   );
//   // }

//   Future<void> payNow() async {
//     try {
//       isLoading.value = true;

//       print("========================================");
//       print("💳 PAY NOW");
//       print("Booking ID: $bookingId");
//       print("Amount: $amount");
//       print("Service: $serviceName");
//       print("========================================");

//       final response = await _service.createPayment(
//         bookingId: bookingId,
//         amount: amount,
//       );

//       print("💳 CREATE PAYMENT RESPONSE: $response");

//       if (response["success"] == true) {
//         final paymentUrl = response["payment_url"]?.toString();

//         print("💳 PAYMENT URL: $paymentUrl");

//         if (paymentUrl == null || paymentUrl.isEmpty) {
//           errorToast("Payment URL is empty");
//           return;
//         }

//         Get.toNamed(
//           "/payment_webview",
//           arguments: {
//             "url": paymentUrl,
//             "bookingId": bookingId,
//             "service_name": serviceName,
//             "scheduled_at": scheduledAt,
//             "amount": amount,
//             "image": image,
//             "booking_code": bookingCode,
//           },
//         );
//       } else {
//         print("❌ Payment API returned success=false");

//         errorToast(
//           "payment_failed".tr,
//         );
//       }
//     } catch (e) {
//       print("❌ Payment Error: $e");

//       errorToast(
//         "payment_failed".tr,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Pay Now
//   // Future<void> payNow() async {
//   //   try {
//   //     isLoading.value = true;

//   //     final response = await _service.createPayment(
//   //       bookingId: bookingId,
//   //       amount: amount,
//   //     );

//   //     if (response["success"]) {
//   //       String paymentUrl = response["payment_url"];

//   //       Get.toNamed(
//   //         "/payment_webview",
//   //         arguments: {
//   //           "url": paymentUrl,
//   //           "bookingId": bookingId,

//   //           /// Forward confirmation data
//   //           "service_name": serviceName,
//   //           "scheduled_at": scheduledAt,
//   //           "amount": amount,
//   //           "image": image,
//   //           "booking_code": bookingCode,
//   //         },
//   //       );
//   //     } else {
//   //       errorToast(
//   //         "payment_failed".tr,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     print("Payment Error: $e");

//   //     errorToast(
//   //       "payment_failed".tr,
//   //     );
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
// }
