import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../models/auth/login_model.dart';
import '../../routes/app_routes.dart';
import '../../helpers/shared_preferences.dart';

class LoginController extends GetxController {
  final AuthRepository repository = AuthRepository();

  TextEditingController phoneController = TextEditingController();
  RxBool isLoading = false.obs;

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

      // -----------------------------------------
      // SAVE UUID + BASIC DETAILS FOR EXISTING USER
      // -----------------------------------------
      if (resp.data["exists"] == true && resp.data["customer"] != null) {
        final customer = resp.data["customer"];

        final String? uuid = customer["id"];
        final String fullName =
            "${customer["firstName"] ?? ""} ${customer["lastName"] ?? ""}"
                .trim();
        final String email = customer["email"] ?? "";

        print("✅ Saving UUID: $uuid");

        await SharedPrefsHelper.setString("customerUuid", uuid ?? "");
        await SharedPrefsHelper.setString("customerName", fullName);
        await SharedPrefsHelper.setString("customerEmail", email);

        // NOTE: we NO LONGER store numeric ID
      }

      // -----------------------------------------
      // NEW USER → GO TO SIGNUP
      // -----------------------------------------
      if (resp.data["exists"] == false) {
        Get.toNamed(
          Routes.signUp,
          arguments: {"phone": phoneController.text.trim()},
        );
        return null;
      }

      // -----------------------------------------
      // EXISTING USER → GO TO OTP PAGE
      // -----------------------------------------
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": resp.data["customer"]["id"],
          // this is UUID
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
