import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/api_error_helper.dart';
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
      errorToast("please_fill_all_fields".tr);
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
        errorToast(
          resp.data["message"]?.toString() ?? "signup_failed".tr,
        );
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

      // Non-2xx (400/409/422...) responses are thrown by Dio, so the real
      // backend message is inside the exception, not in a Response object.
      errorToast(
        apiErrorMessage(e, "signup_failed".tr),
      );
    }
  }
}
