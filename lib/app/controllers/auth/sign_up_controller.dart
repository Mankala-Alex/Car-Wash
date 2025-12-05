import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

      // navigate to OTP page
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
