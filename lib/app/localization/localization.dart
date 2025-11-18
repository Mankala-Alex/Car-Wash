import 'package:flutter/material.dart';
// import 'package:get/get_navigation/src/root/internacionalization.dart'
//     show Translations;
import 'package:get/get.dart';

import 'app_ar.dart';
import 'app_en.dart';

class Localization extends Translations {
  // // static var locale = Locale(
  // //   (!isItNull(Storage.readString(Storage.nxgnAppChangeLanguage)))
  // //       ? Storage.readString(Storage.nxgnAppChangeLanguage)
  // //       : "en",
  // //   'IN',
  // // );

  // Supported languages
  static const localeEnglishUS = Locale('en', 'US');
  static const localeArabic = Locale('ar', 'SA'); // Arabic (Saudi Arabia)

  // Default locale
  static const defaultLocale = localeEnglishUS;

  // Fallback locale
  static const fallbackLocale = Locale('en', 'US');

  // List of supported locales
  static final supportedLocales = [localeEnglishUS, localeArabic];

  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'ar_SA': arSA};

  // Function to update language
  void changeLanguage(String langCode, String countryCode) {
    final locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
  }
}
