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
  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments["phone"] != null) {
      phoneCtrl.text = Get.arguments["phone"];
    }
  }

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
      final resp = await repository.postSignupPhone({
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

      /// MOVE TO OTP PAGE

      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": resp.data["id"],
          "phone": resp.data["phone"],
        },
      );
    } catch (e) {
      isLoading(false);

      print("Signup Error: $e");

      errorToast("Signup failed");
    }
  }
}
