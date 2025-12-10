import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/auth/sign_up_model.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../routes/app_routes.dart';

class SignupController extends GetxController {
  final AuthRepository repository = AuthRepository();

  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();

  late String phone; // comes from LoginView
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    phone = Get.arguments["phone"];
    super.onInit();
  }

  int _extractNumericCustomerId(String? customerCode) {
    if (customerCode == null) return 0;
    final match = RegExp(r'(\d+)$').firstMatch(customerCode);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  Future<void> submitSignup() async {
    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty) {
      errorToast("Please fill all fields");
      return;
    }

    isLoading(true);

    try {
      final resp = await repository.postSignup({
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "phone": phone,
      });

      isLoading(false);

      final data = Signupmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      // ==============================
      // ⭐ SAVE CUSTOMER DATA LOCALLY ⭐
      // ==============================
      if (resp.data["customer"] != null) {
        final customer = resp.data["customer"];

        final String uuid = customer["id"];
        final String customerCode = customer["customerId"];
        final int numericId = _extractNumericCustomerId(customerCode);

        final String first = customer["firstName"] ?? "";
        final String last = customer["lastName"] ?? "";
        final String fullName = "$first $last";

        final String email = customer["email"] ?? "";
        final String phoneNumber = customer["mobile"] ?? "";
        final String token = resp.data["token"] ?? "";

        print("📌 Saving customer data...");
        print("UUID = $uuid");
        print("Numeric ID = $numericId");
        print("Name = $fullName");

        // SAVE EVERYTHING
        await SharedPrefsHelper.setString("customerUuid", uuid);
        await SharedPrefsHelper.setInt("customerNumericId", numericId);
        await SharedPrefsHelper.setString("customerName", fullName);
        await SharedPrefsHelper.setString("customerEmail", email);
        await SharedPrefsHelper.setString("customerPhone", phoneNumber);
        await SharedPrefsHelper.setString("authToken", token);
      }

      // ==============================
      // GO TO OTP PAGE
      // ==============================
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": data.customerId,
          "phone": phone,
        },
      );
    } catch (e) {
      isLoading(false);
      errorToast("Signup failed");
    }
  }
}

//changed for the booking history//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_new_app/app/models/auth/sign_up_model.dart';
// import '../../helpers/flutter_toast.dart';
// import '../../repositories/auth/auth_repository.dart';
// import '../../routes/app_routes.dart';

// class SignupController extends GetxController {
//   final AuthRepository repository = AuthRepository();

//   TextEditingController firstNameCtrl = TextEditingController();
//   TextEditingController lastNameCtrl = TextEditingController();
//   TextEditingController emailCtrl = TextEditingController();

//   late String phone; // comes from LoginView
//   RxBool isLoading = false.obs;

//   @override
//   void onInit() {
//     phone = Get.arguments["phone"];
//     super.onInit();
//   }

//   Future<void> submitSignup() async {
//     if (firstNameCtrl.text.trim().isEmpty ||
//         lastNameCtrl.text.trim().isEmpty ||
//         emailCtrl.text.trim().isEmpty) {
//       errorToast("Please fill all fields");
//       return;
//     }

//     isLoading(true);

//     try {
//       final resp = await repository.postSignup({
//         "firstName": firstNameCtrl.text.trim(),
//         "lastName": lastNameCtrl.text.trim(),
//         "email": emailCtrl.text.trim(),
//         "phone": phone,
//       });

//       isLoading(false);

//       final data = Signupmodel.fromJson(resp.data);

//       if (!data.success) {
//         errorToast(data.message);
//         return;
//       }

//       // navigate to OTP page
//       Get.toNamed(
//         Routes.otpPage,
//         arguments: {
//           "customerId": data.customerId,
//           "phone": phone,
//         },
//       );
//     } catch (e) {
//       isLoading(false);
//       errorToast("Signup failed");
//     }
//   }
// }
