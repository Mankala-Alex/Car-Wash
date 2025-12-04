import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/flutter_toast.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../models/auth/login_model.dart';

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

      if (data.success == false) {
        errorToast(data.message);
        return null;
      }

      return data;
    } catch (e) {
      isLoading(false);
      errorToast("Something went wrong");
      return null;
    }
  }
}
