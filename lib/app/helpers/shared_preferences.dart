import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;

  // Keys for localization (used in main.dart)
  static const String languageCode = "language_code"; // e.g., 'en', 'ar'
  static const String countryCode = "country_code"; // e.g., 'US', 'SA'

  // API and app-specific keys (commented out until needed)
  static const String accessToken = "accessToken";
  // static const String refreshToken = "refreshToken";
  // static const String isLanguageSet = "isLanguageSet";
  // static const String accountId = "accountId";
  // static const String name = "name";
  // static const String appMUserId = "appMUserId";
  // static const String gender = "gender";
  // static const String email = "email";
  // static const String fileNo = "fileNo";
  // static const String dob = "dob";
  // static const String phoneNo = "phoneNo";
  // static const String sbuId = "sbuId";

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure _prefs is initialized
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  // Save Data
  static Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return _prefs!.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return _prefs!.setDouble(key, value);
  }

  static Future<bool> setList(String key, List<String> value) async {
    await _ensureInitialized();
    return _prefs!.setStringList(key, value);
  }

  static Future<bool> setMap(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    return _prefs!.setString(key, jsonEncode(value));
  }

  static Future<bool> setDynamic(String key, dynamic value) async {
    await _ensureInitialized();
    return _prefs!.setString(key, jsonEncode(value));
  }

  // Read Data with default values
  static Future<String> getString(
    String key, {
    String defaultValue = '',
  }) async {
    await _ensureInitialized();
    final value = _prefs!.getString(key);
    return value ?? defaultValue;
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await _ensureInitialized();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    await _ensureInitialized();
    return _prefs!.getInt(key) ?? defaultValue;
  }

  static Future<double> getDouble(
    String key, {
    double defaultValue = 0.0,
  }) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  static Future<List<String>> getList(
    String key, {
    List<String> defaultValue = const [],
  }) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key) ?? defaultValue;
  }

  static Future<Map<String, dynamic>> getMap(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) async {
    await _ensureInitialized();
    String? jsonString = _prefs!.getString(key);
    return jsonDecode(jsonString!);
  }

  static Future<dynamic> getDynamic(String key, {dynamic defaultValue}) async {
    await _ensureInitialized();
    String? jsonString = _prefs!.getString(key);
    return jsonDecode(jsonString!);
  }

  // Remove Data
  static Future<bool> remove(String key) async {
    await _ensureInitialized();
    return _prefs!.remove(key);
  }

  // Clear All Data
  static Future<bool> clearAll() async {
    await _ensureInitialized();
    return _prefs!.clear();
  }
}
