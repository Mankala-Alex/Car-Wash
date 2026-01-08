import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../routes/app_routes.dart';

class SignupController extends GetxController {
  final AuthRepository repository = AuthRepository();

  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> submitSignup() async {
    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty) {
      errorToast("Please fill all fields");
      return;
    }

    isLoading(true);

    try {
      final resp = await repository.postSignup({
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
      });

      isLoading(false);

      if (resp.data["success"] != true) {
        errorToast(resp.data["message"]);
        return;
      }

      // 👉 Signup DONE, now go to OTP
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": resp.data["id"],
          "email": emailCtrl.text.trim(),
        },
      );
    } catch (e) {
      isLoading(false);
      errorToast("Signup failed");
    }
  }
}
