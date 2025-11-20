import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  RxList<RxString> otp = List.generate(4, (index) => ''.obs).obs;
  RxInt currentIndex = 0.obs;

  List<TextEditingController> textControllers =
      List.generate(4, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  void onOtpChange(int index, String value) {
    otp[index].value = value;

    if (value.isNotEmpty && index < 3) {
      currentIndex.value = index + 1;
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      currentIndex.value = index - 1;
      focusNodes[index - 1].requestFocus();
    }
  }
}
