import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/auth/sign_up_model.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/flutter_toast.dart';

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;

  late String customerId;
  late String phone;

  @override
  void onInit() {
    customerId = Get.arguments["customerId"];
    phone = Get.arguments["phone"];
    super.onInit();
  }

  void setOtp(String value) {
    otp.value = value;
  }

  Future<Signupmodel?> verifyOtp() async {
    if (otp.value.length != 4) {
      errorToast("Enter valid OTP");
      return null;
    }

    loadingPopUp(true);

    try {
      final resp = await repository.postVerifyOtp({
        "customerId": customerId,
        "otp": otp.value,
      });

      loadingPopUp(false);

      // When backend returns error: { "error": "Invalid OTP" }
      if (resp.data["error"] != null) {
        errorToast(resp.data["error"]);
        return null;
      }

      final data = Signupmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      return data;
    } catch (e) {
      loadingPopUp(false);
      errorToast("OTP verification failed");
      return null;
    }
  }
}
