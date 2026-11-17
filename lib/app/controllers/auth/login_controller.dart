import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/api_error_helper.dart';
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

      final resp = await repository.postRequestOtpPhone({"phone": input});

      isLoading(false);

      final data = Loginmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      /// EVERY number goes to the OTP screen.
      ///
      /// There is no signup screen any more: the backend creates the customer
      /// record from the mobile number on the fly, so a brand new number and an
      /// existing one follow exactly the same path.
      Get.toNamed(
        Routes.otpPage,
        arguments: {
          "customerId": data.id,
          "phone": data.phone.isNotEmpty ? data.phone : input,
          "expiresInSeconds": data.expiresInSeconds,
          "resendAfterSeconds": data.resendAfterSeconds,
          "otpLength": data.otpLength,
          "isNewCustomer": data.isNewCustomer,
        },
      );
    } catch (e) {
      isLoading(false);
      print("Request OTP Error: $e");

      errorToast(apiErrorMessage(e, "something_went_wrong".tr));
    }
  }
}
