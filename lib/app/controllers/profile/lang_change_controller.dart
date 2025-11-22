import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LangChangeController extends GetxController {
  RxString selectedValue = "".obs;

  void applyLanguageChange() {
    if (selectedValue.value.isEmpty) return;

    Get.updateLocale(Locale(selectedValue.value));

    Get.back(); // Go back to previous page after saving
  }
}
