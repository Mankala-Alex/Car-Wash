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
            if (token != null) {
              options.headers["Authorization"] = "Bearer $token";
            }
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
