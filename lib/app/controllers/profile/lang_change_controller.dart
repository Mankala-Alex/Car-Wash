import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
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

  void applyLanguageChange() async {
    if (selectedValue.value.isEmpty) return;

    if (selectedValue.value == "en") {
      await SharedPrefsHelper.setString(
        SharedPrefsHelper.languageCode,
        "en",
      );

      await SharedPrefsHelper.setString(
        SharedPrefsHelper.countryCode,
        "US",
      );

      Get.updateLocale(const Locale("en", "US"));
    } else {
      await SharedPrefsHelper.setString(
        SharedPrefsHelper.languageCode,
        "ar",
      );

      await SharedPrefsHelper.setString(
        SharedPrefsHelper.countryCode,
        "SA",
      );

      Get.updateLocale(const Locale("ar", "SA"));
    }

    Get.back();
  }
}
