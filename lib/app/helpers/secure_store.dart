import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureStore {
  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  /// Set Single Value
  Future<void> storeSingleValue(String key, String? val) async {
    await secureStorage.write(key: key, value: val);
  }

  /// Read the Single
  Future<String?> getSingleValue(String key) async {
    return await secureStorage.read(key: key);
  }

  /// Delete all Data
  Future<void> deleteAllData() async {
    await secureStorage.deleteAll();
  }

  /// Set the Token
  Future<void> storeLoginDetails(Map<String, dynamic> loginDetails) async {
    await secureStorage.write(
      key: 'loginDetails',
      value: jsonEncode(loginDetails),
    );
  }
}
