import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/shared_preferences.dart';

class LangSelectionController extends GetxController {
  var selectedValue = 'en'.obs;
  @override
  void onInit() async {
    String? languageCode = await SharedPrefsHelper.getString(
      SharedPrefsHelper.languageCode,
    );

    //selectedValue.value = languageCode;

    super.onInit();
  }

  void changeLanguage() {
    // SharedPrefsHelper.setString(SharedPrefsHelper.lang, selectedValue.value);
    //

    if (selectedValue.value == 'en') {
      SharedPrefsHelper.setString(SharedPrefsHelper.languageCode, 'en');
      SharedPrefsHelper.setString(SharedPrefsHelper.countryCode, 'US');
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      SharedPrefsHelper.setString(SharedPrefsHelper.languageCode, 'ar');
      SharedPrefsHelper.setString(SharedPrefsHelper.countryCode, 'SA');
      Get.updateLocale(const Locale('ar', 'SA'));
    }
    Get.offNamed('/login');
  }
}
