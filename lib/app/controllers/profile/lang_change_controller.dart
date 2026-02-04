import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LangChangeController extends GetxController {
  RxString selectedValue = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Get the current locale and set it as selected
    String currentLocale = Get.locale?.languageCode ?? "en";
    selectedValue.value = currentLocale;
    print("📍 Current language: $currentLocale");
  }

  void applyLanguageChange() {
    if (selectedValue.value.isEmpty) return;

    Get.updateLocale(Locale(selectedValue.value));

    Get.back(); // Go back to previous page after saving
  }
}
