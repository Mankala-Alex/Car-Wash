import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  // ==============================
  // UI
  // ==============================

  String image = "";

  String get formattedDate {
    final dt = DateTime.tryParse(scheduledAt);

    if (dt == null) return "";

    return DateFormat(
      'EEE, dd MMM • hh:mm a',
    ).format(dt.toLocal());
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

    slotId = int.tryParse(
          args["slot_id"]?.toString() ?? "0",
        ) ??
        0;

    scheduledAt = args["scheduled_at"]?.toString() ?? "";

    amount = double.tryParse(
          args["amount"]?.toString() ?? "0",
        ) ??
        0.0;

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

  Future<void> payNow() async {
    try {
      isLoading.value = true;

      print("========================================");
      print("💳 PAY NOW");
      print("Customer: $customerId");
      print("Vehicle: $vehicle");
      print("Service: $serviceName");
      print("Slot: $slotId");
      print("Amount: $amount");
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
        formattedAddress: formattedAddress,
        address: address,
        houseNumber: houseNumber,
        landmark: landmark,
        addressLabel: addressLabel,
      );

      print("========================================");
      print("💳 CREATE PAYMENT RESPONSE");
      print("$response");
      print("========================================");

      if (response["success"] != true) {
        print("❌ Payment API returned success=false");

        errorToast("payment_failed".tr);
        return;
      }

      final paymentUrl = response["payment_url"]?.toString();

      paymentAttemptId = response["payment_attempt_id"]?.toString() ?? "";

      bookingReference = response["booking_reference"]?.toString() ?? "";

      print("💳 PAYMENT URL: $paymentUrl");
      print("💳 PAYMENT ATTEMPT ID: $paymentAttemptId");
      print("💳 BOOKING REFERENCE: $bookingReference");

      if (paymentUrl == null || paymentUrl.isEmpty) {
        errorToast("Payment URL is empty");
        return;
      }

      if (paymentAttemptId.isEmpty) {
        print("❌ Payment attempt ID missing from backend response");

        errorToast("Payment initialization failed");
        return;
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

          // UI data
          "service_name": serviceName,
          "scheduled_at": scheduledAt,
          "amount": amount,
          "image": image,
        },
      );
    } catch (e) {
      print("❌ Payment Error: $e");

      final errorText = e.toString();
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
          return;
        }
      }

      errorToast("payment_failed".tr);
    } finally {
      isLoading.value = false;
    }
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
