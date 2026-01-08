import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../models/auth/login_model.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository repository = AuthRepository();

  TextEditingController emailController = TextEditingController();
  RxBool isLoading = false.obs;

  Future<void> requestOtp() async {
    if (emailController.text.trim().isEmpty) {
      errorToast("Enter email");
      return;
    }

    isLoading(true);

    try {
      final resp = await repository.postRequestOtp({
        "email": emailController.text.trim(),
      });

      isLoading(false);

      final data = Loginmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      // 🔹 NEW USER → SIGNUP
      if (resp.data["exists"] == false) {
        Get.toNamed(
          Routes.signUp,
          arguments: {
            "email": emailController.text.trim(),
          },
        );
        return;
      }

      // 🔹 EXISTING USER → OTP
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": resp.data["id"], // ONLY ID
          "email": emailController.text.trim(),
        },
      );
    } catch (e) {
      isLoading(false);
      errorToast("Something went wrong");
    }
  }
}
