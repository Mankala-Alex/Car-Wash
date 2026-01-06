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
  TextEditingController phoneCtrl = TextEditingController(); // ✅ NEW

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
        "email": emailCtrl.text.trim(), // OTP email
        "phone": phoneCtrl.text.trim(), // ✅ REAL PHONE
      });

      isLoading(false);

      final data = Signupmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      final customer = resp.data["customer"];
      if (customer != null) {
        await SharedPrefsHelper.setString("customerUuid", customer["id"]);
        await SharedPrefsHelper.setString(
          "customerName",
          "${customer["firstName"]} ${customer["lastName"]}",
        );
        await SharedPrefsHelper.setString(
          "customerEmail",
          customer["email"] ?? "",
        );
        await SharedPrefsHelper.setString(
          "customerPhone",
          customer["mobile"] ?? "",
        );
        await SharedPrefsHelper.setString(
          "authToken",
          resp.data["token"] ?? "",
        );
      }

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
