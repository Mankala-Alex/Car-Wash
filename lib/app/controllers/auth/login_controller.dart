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
      errorToast("enter_phone_number".tr);
      return;
    }

    isLoading(true);

    try {
      final input = emailController.text.trim();

      final resp = await repository.postRequestOtpPhone({
        "phone": input,
      });

      isLoading(false);

      final data = Loginmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      /// NEW USER → SIGNUP
      if (data.exists == false) {
        Get.toNamed(
          Routes.signUp,
          arguments: {
            "phone": input,
          },
        );
        return;
      }

      /// EXISTING USER → OTP
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": data.id,
          "phone": input,
        },
      );
    } catch (e) {
      isLoading(false);
      errorToast("something_went_wrong".tr);
    }
  }
}
