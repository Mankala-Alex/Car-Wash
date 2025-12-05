import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../models/auth/login_model.dart';
import '../../routes/app_routes.dart';

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

      final data = Loginmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      // 👇 NEW USER -> Go to Signup Screen
      if (resp.data["exists"] == false) {
        Get.toNamed(
          Routes.signUp,
          arguments: {
            "phone": phoneController.text.trim(),
          },
        );
        return null; // stop here
      }

      // 👇 EXISTING USER -> Go to OTP screen
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": data.customerId,
          "phone": phoneController.text.trim(),
        },
      );

      return data;
    } catch (e) {
      isLoading(false);
      errorToast("Something went wrong");
      return null;
    }
  }
}
