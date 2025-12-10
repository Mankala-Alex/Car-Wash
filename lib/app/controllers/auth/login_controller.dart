import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../models/auth/login_model.dart';
import '../../routes/app_routes.dart';
import '../../helpers/shared_preferences.dart'; // ⬅️ add this

class LoginController extends GetxController {
  final AuthRepository repository = AuthRepository();

  TextEditingController phoneController = TextEditingController();
  RxBool isLoading = false.obs;

  /// Helper: extract last digits from "CUST-933904" → 933904
  int _extractNumericCustomerId(String? customerCode) {
    if (customerCode == null) return 0;
    final match = RegExp(r'(\d+)$').firstMatch(customerCode);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  Future<Loginmodel?> requestOtp() async {
    if (phoneController.text.trim().isEmpty) {
      errorToast("Enter mobile number");
      return null;
    }

    isLoading(true);

    try {
      final resp = await repository.postRequestOtp({
        "phone": phoneController.text.trim(),
      });

      isLoading(false);

      print("🔵 API RESPONSE = ${resp.data}");

      final data = Loginmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      // ⬇️ If user exists, save IDs to SharedPrefs
      if (resp.data["exists"] == true && resp.data["customer"] != null) {
        final customerMap = resp.data["customer"];

        final String? customerUuid = customerMap["id"]; // e.g. "70b6..."
        final String? customerCode = customerMap["customerId"]; // "CUST-933904"
        final int numericId = _extractNumericCustomerId(customerCode);

        print("✅ Storing IDs: uuid=$customerUuid numeric=$numericId");

        await SharedPrefsHelper.setString("customerUuid", customerUuid ?? "");
        await SharedPrefsHelper.setInt("customerNumericId", numericId);
      }

      // If user doesn't exist → go to signup
      if (resp.data["exists"] == false) {
        Get.toNamed(
          Routes.signUp,
          arguments: {"phone": phoneController.text.trim()},
        );
        return null;
      }

      // Existing user → go to OTP
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": data.customerId,
          "phone": phoneController.text.trim(),
        },
      );

      return data;
    } catch (e, st) {
      print("🔥 requestOtp ERROR: $e\n$st");
      isLoading(false);
      errorToast("Something went wrong");
      return null;
    }
  }
}

// cvhanged fro the booking hostory//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../helpers/flutter_toast.dart';
// import '../../repositories/auth/auth_repository.dart';
// import '../../models/auth/login_model.dart';
// import '../../routes/app_routes.dart';

// class LoginController extends GetxController {
//   final AuthRepository repository = AuthRepository();

//   TextEditingController phoneController = TextEditingController();
//   RxBool isLoading = false.obs;

//   Future<Loginmodel?> requestOtp() async {
//     if (phoneController.text.trim().isEmpty) {
//       errorToast("Enter mobile number");
//       return null;
//     }

//     isLoading(true);

//     try {
//       final resp = await repository.postRequestOtp({
//         "phone": phoneController.text.trim(),
//       });

//       isLoading(false);

//       print("🔵 API RESPONSE = ${resp.data}");

//       final data = Loginmodel.fromJson(resp.data);

//       if (!data.success) {
//         errorToast(data.message);
//         return null;
//       }

//       if (resp.data["exists"] == false) {
//         Get.toNamed(
//           Routes.signUp,
//           arguments: {"phone": phoneController.text.trim()},
//         );
//         return null;
//       }

//       Get.toNamed(
//         Routes.otpPage,
//         arguments: {
//           "customerId": data.customerId,
//           "phone": phoneController.text.trim(),
//         },
//       );

//       return data;
//     } catch (e, st) {
//       print("🔥 requestOtp ERROR: $e\n$st");
//       isLoading(false);
//       errorToast("Something went wrong");
//       return null;
//     }
//   }
// }
