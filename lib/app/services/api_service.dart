import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import '../config/environment.dart';
import '../helpers/helper_check_internet.dart';
import '../custome_widgets/no_internet_connection.dart';
import '../helpers/secure_store.dart';
import '../helpers/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.baseUrl, // http://10.0.2.2:3000/api/
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static bool _interceptorsAdded = false;

  // --------------------------
  // ADD INTERCEPTORS
  // --------------------------
  static void _addInterceptors() {
    if (_interceptorsAdded) return;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 🔥 Add Auth Token if needed
          if (options.extra["auth"] == true) {
            final token = await FlutterSecureStore()
                .getSingleValue(SharedPrefsHelper.accessToken);

            // Debug: print token presence (do NOT log tokens in production)
            print(
                "🔐 Auth requested. token present: ${token != null && token.isNotEmpty}");

            // Only add header when token is non-null and non-empty
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            } else {
              // Helpful debug info when token missing — server will likely return 401
              print(
                  "⚠️ Authorization header not set because token is empty or null");
            }

            // Try to decode JWT payload to show claims (debugging only)
            try {
              if (token != null && token.split('.').length == 3) {
                final parts = token.split('.');
                final payload = parts[1];
                final normalized = base64Url.normalize(payload);
                final decoded = utf8.decode(base64Url.decode(normalized));
                print("🔍 Token payload claims: $decoded");
              }
            } catch (e) {
              print('Error decoding token payload: $e');
            }

            // Debug: print final headers for this request
            print(
                "➡️ Request ${options.method} ${options.path} headers: ${options.headers}");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // If no internet or request never reached server
          if (error.type == DioExceptionType.unknown ||
              error.type == DioExceptionType.connectionError) {
            print("❌ No Response From Server → ${error.message}");
            return handler.reject(error);
          }

          // Log detailed response info for debugging 4xx/5xx
          try {
            final req = error.requestOptions;
            print("❗️ DioError for ${req.method} ${req.path}");
            print("➡️ Request uri: ${req.uri}");
            print("➡️ Request headers: ${req.headers}");
            if (req.data != null) print("➡️ Request body: ${req.data}");

            if (error.response != null) {
              print("⬅️ Response status: ${error.response?.statusCode}");
              print("⬅️ Response data: ${error.response?.data}");
            } else {
              print("⬅️ No response received (response is null)");
            }
          } catch (e) {
            print("Error while logging DioException details: $e");
          }

          return handler.next(error);
        },
      ),
    );

    _interceptorsAdded = true;
  }

  // --------------------------
  // POST REQUEST
  // --------------------------
  static Future<Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuthToken = false,
  }) async {
    if (await isInternet()) {
      _addInterceptors();

      return await _dio.post(
        endpoint,
        data: data,
        // Send correct JSON
        options: Options(extra: {"auth": requireAuthToken}),
      );
    } else {
      _showNoInternetPopup();
      throw Exception("No Internet");
    }
  }

  // --------------------------
  // GET REQUEST
  // --------------------------
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? params,
    bool requireAuthToken = false,
  }) async {
    if (await isInternet()) {
      _addInterceptors();

      return await _dio.get(
        endpoint,
        queryParameters: params,
        options: Options(extra: {"auth": requireAuthToken}),
      );
    } else {
      _showNoInternetPopup();
      throw Exception("No Internet");
    }
  }

  static Future<Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuthToken = false,
  }) async {
    if (await isInternet()) {
      _addInterceptors();

      return await _dio.put(
        endpoint,
        data: data,
        options: Options(extra: {"auth": requireAuthToken}),
      );
    } else {
      _showNoInternetPopup();
      throw Exception("No Internet");
    }
  }

  static Future<Response> delete(
    String endpoint, {
    bool requireAuthToken = false,
  }) async {
    if (await isInternet()) {
      _addInterceptors();

      return await _dio.delete(
        endpoint,
        options: Options(extra: {"auth": requireAuthToken}),
      );
    } else {
      _showNoInternetPopup();
      throw Exception("No Internet");
    }
  }

  // --------------------------
  // SHARED POPUP
  // --------------------------
  static void _showNoInternetPopup() {
    Get.dialog(
      const NoInternetConnection(),
      barrierColor: const Color(0x90000000),
      barrierDismissible: false,
    );
  }
}
