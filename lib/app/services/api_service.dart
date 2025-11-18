import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/environment.dart';
import '../custome_widgets/no_internet_connection.dart';
import '../helpers/console_print.dart';
import '../helpers/flutter_toast.dart';
import '../helpers/helper_check_internet.dart';
import '../custome_widgets/logout.dart';
import '../helpers/secure_store.dart';
import '../helpers/shared_preferences.dart';

class ApiService {
  static bool isRefreshing = false;
  static bool interceptorsAdded = false;
  // static NavigationCallback? _navigateToLogin;

  // static Logger logger = Logger();

  static bool isInternetDialouge = false;

  static const bool isProduction = Environment.isProduction;

  static final Map<String, String> commonHeaders = {
    'Content-Type': 'application/json',
  };

  // static final ApiService _singleton = ApiService._internal();
  // factory ApiService() => _singleton;
  // ApiService._internal() {
  //   _addInterceptors();
  // }

  static Dio dio = Dio(
    BaseOptions(
      baseUrl: Environment.baseUrl,
      connectTimeout: const Duration(seconds: 15000),
      receiveTimeout: const Duration(seconds: 15000),
    ),
  );

  static Future<Map<String, String>> _mergeHeaders(
    Map<String, String>? headers, {
    bool requireAuthToken = true,
  }) async {
    final Map<String, String> mergedHeaders = {...commonHeaders, ...?headers};
    if (requireAuthToken) {
      //SANDEEP CAHNGE FOR DYNAMIC
      // const accessToken =
      //     "eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiS0lSQU4sICBTQUVFRCIsIkFwcE1Vc2VySWQiOiI3IiwiRmlsZU5vIjoiMjgxNjY1IiwiTW9iaWxlIjoiMDU2ODc0NzcyMCIsIlBhdGllbnRNYXN0ZXJJZCI6IjE5NTI3MiIsIlNCVUlkIjoiMSIsIkxhbmciOiJlbiIsImV4cCI6MTc0MjkwOTU2MiwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NDQzNDMiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo0NDM0MyJ9.xXUT51cDU_PqSvMZhDchIVGVJfw9YJ5dbtLU75wVCEI";
      final accessToken = await FlutterSecureStore().getSingleValue(
        SharedPrefsHelper.accessToken,
      );
      // final refreshToken = await FlutterSecureStore().getSingleValue(Storage.refreshToken);

      String? authToken = accessToken;
      mergedHeaders['Authorization'] = 'Bearer $authToken';
    }
    return mergedHeaders;
  }

  // static void setNavigationCallback(NavigationCallback callback) {
  //   _navigateToLogin = callback;
  // }

  static void _addInterceptors() {
    if (!interceptorsAdded) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // if (!isProduction) {
            //    logger.i('-- Request -- \n URL: ${options.uri}\n Method: ${options.method} \n Headers: ${options.headers}');
            // }
            if (options.data != null) {
              var decodedData = jsonDecode(options.data);

              if (decodedData is Map) {
                decodedData = _trimMap(decodedData as Map<String, dynamic>);
              } else if (decodedData is List) {
                decodedData = _trimList(decodedData);
              }

              options.data = jsonEncode(decodedData);
            }

            if (!isProduction) {
              // if (options.data != null) {
              log(
                ''' '\x1B[38;5;230m' -- API Request -- \n URL: ${options.uri}\n Method: ${options.method} \n Headers: ${options.headers} \n ${options.data != null ? "Body: ${options.data}" : ""} ''',
              );
              // logger.i('Body: ${options.data}');
              // }
            }

            return handler.next(options);
          },
          onResponse: (response, handler) async {
            if (!isProduction) {
              log(
                " '\x1B[32m'-- API Response -- \n Status Code: ${response.statusCode} \n Data: ${jsonEncode(response.data)} ",
              );
              // logger.i('-- Response -- \n Status Code: ${response.statusCode} \n Data: ${jsonEncode(response.data)}');
            }

            if (response.statusCode == 204) {
              // refresh token
              if (!isRefreshing) {
                isRefreshing = true;
                try {
                  final newAccessToken = await getRefreshToken();
                  if (newAccessToken != null) {
                    // Retry the original request with the new token
                    final options = response.requestOptions;
                    options.headers['Authorization'] = 'Basic $newAccessToken';
                    final retryResponse = await dio.request(
                      options.path,
                      options: Options(
                        method: options.method,
                        headers: options.headers,
                      ),
                      data: options.data,
                      queryParameters: options.queryParameters,
                    );
                    return handler.resolve(retryResponse);
                  } else {
                    if (!isProduction) {
                      log(" '\x1B[31m' API ERROR ");
                      // logger.e("API ERROR ");
                    }
                    //logout();
                  }
                } catch (error) {
                  if (!isProduction) {
                    log(" '\x1B[31m' Error refreshing token: $error");
                    // logger.e("Error refreshing token: $error");
                  }
                  // await Get.dialog(
                  //   CustomConfirmationDialog(
                  //     header: "Testing purpose",
                  //     body: 'catch Exception: $error',
                  //     onNo: () {
                  //       Get.back();
                  //     },
                  //     onYes: () {
                  //       Get.offAllNamed(Routes.login);
                  //     },
                  //     noText: "Okay",
                  //     yesText: "Login here",
                  //   ),
                  //   barrierColor: Constants.bgBackDropColor,
                  //   barrierDismissible: false, // Prevents closing the dialog by tapping outside
                  // );
                  //logout();
                } finally {
                  isRefreshing = false;
                }
              } else {
                if (!isProduction) {
                  log(" '\x1B[31m' Already refreshing token");
                  // logger.i("Already refreshing token");
                }
              }
            }

            return handler.next(response);
          },
          onError: (DioException error, handler) async {
            if (error.response == null) {
              // "Response has no Location header for redirect"
              //logout();
              // await Get.dialog(
              //   CustomConfirmationDialog(
              //     header: "Testing purpose",
              //     body: 'onError: $error',
              //     onNo: () {
              //       Get.back();
              //     },
              //     onYes: () {
              //       Get.offAllNamed(Routes.login);
              //     },
              //     noText: "Okay",
              //     yesText: "Login here",
              //   ),
              //   barrierColor: Constants.bgBackDropColor,
              //   barrierDismissible: false, // Prevents closing the dialog by tapping outside
              // );

              consolePrint("Resonse NULL : ${error.message}");
              return;
            }
            if (error.response?.statusCode == 500) {
              errorToast("somthing_wrng_try_again".tr);
              return;
            }
            if (error.response?.statusCode == 401) {
              // Token Invalid - Just Logout
              // await Get.dialog(
              //   CustomConfirmationDialog(
              //     header: "Alert!",
              //     body: 'You are logged in another device',
              //     onYes: () {
              //       Get.back();
              //       logout();
              //     },
              //     yesText: "Login here",
              //   ),
              //   barrierColor: Constants.bgBackDropColor,
              //   barrierDismissible: false, // Prevents closing the dialog by tapping outside
              // );
              logout();
              return;
            }
            // if (error.response?.statusCode == 303) {
            //   // AccessToken Expired - Get new AccessToken by using Refresh Token.

            //   if (!isRefreshing) {
            //     isRefreshing = true;
            //     try {
            //       final newAccessToken = await getRefreshToken();
            //       if (newAccessToken != null) {
            //         // Retry the original request with the new token
            //         final options = error.requestOptions;
            //         options.headers['Authorization'] = 'Basic $newAccessToken';
            //         final response = await dio.request(
            //           options.path,
            //           options: Options(
            //             method: options.method,
            //             headers: options.headers,
            //           ),
            //           data: options.data,
            //           queryParameters: options.queryParameters,
            //         );
            //         return handler.resolve(response);
            //       } else {
            //         if (!isProduction) {
            //           logger.e("API ERROR ");
            //         }

            //         //logout();
            //       }
            //     } catch (error) {
            //       if (!isProduction) {
            //         logger.e("Error refreshing token: $error");
            //       }
            //       // await Get.dialog(
            //       //   CustomConfirmationDialog(
            //       //     header: "Testing purpose",
            //       //     body: 'catch Exception: $error',
            //       //     onNo: () {
            //       //       Get.back();
            //       //     },
            //       //     onYes: () {
            //       //       Get.offAllNamed(Routes.login);
            //       //     },
            //       //     noText: "Okay",
            //       //     yesText: "Login here",
            //       //   ),
            //       //   barrierColor: Constants.bgBackDropColor,
            //       //   barrierDismissible: false, // Prevents closing the dialog by tapping outside
            //       // );
            //       //logout();
            //     } finally {
            //       isRefreshing = false;
            //     }
            //   } else {
            //     if (!isProduction) {
            //       logger.i("Already refreshing token");
            //     }
            //   }
            // }
            return handler.next(error);
          },
        ),
      );
      interceptorsAdded = true;
    }
  }

  static Future<dynamic> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
    bool requireAuthToken = true,
  }) async {
    if (await isInternet()) {
      _addInterceptors();
      try {
        final response = await dio.post(
          endpoint,
          data: jsonEncode(body),
          options: Options(
            headers: await _mergeHeaders(
              headers,
              requireAuthToken: requireAuthToken,
            ),
          ),
        );
        return response;
      } catch (error) {
        // fnHandleControllerException(error, stackTrace, "ApiService", "post");
        return null; // or rethrow the error based on your need
      }
    } else {
      if (isInternetDialouge || true) {
        Get.dialog(
          const NoInternetConnection(),
          barrierColor: const Color(0xFF000000).withOpacity(0.7),
          barrierDismissible:
              false, // Prevents closing the dialog by tapping outside
        );
      }
    }
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requireAuthToken = true,
  }) async {
    if (await isInternet()) {
      _addInterceptors();
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: queryParameters,
          options: Options(
            headers: await _mergeHeaders(
              headers,
              requireAuthToken: requireAuthToken,
            ),
          ),
        );

        return response;
      } catch (error) {
        // fnHandleControllerException(error, stackTrace, "ApiService", "post");
        return null; // or rethrow the error based on your need
      }
    } else {
      consolePrint("Internet failed");

      if (isInternetDialouge || true) {
        Get.dialog(
          const NoInternetConnection(),
          barrierColor: const Color(0xFF000000).withOpacity(0.7),
          barrierDismissible:
              false, // Prevents closing the dialog by tapping outside
        );
      }
    }
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool requireAuthToken = true,
  }) async {
    _addInterceptors();
    try {
      final response = await dio.put(
        endpoint,
        data: jsonEncode(body),
        options: Options(
          headers: await _mergeHeaders(
            headers,
            requireAuthToken: requireAuthToken,
          ),
        ),
      );

      return response;
    } catch (error) {
      // fnHandleControllerException(error, stackTrace, "ApiService", "post");
      return null; // or rethrow the error based on your need
    }
  }

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requireAuthToken = true,
  }) async {
    _addInterceptors();
    try {
      final response = await dio.delete(
        endpoint,
        options: Options(
          headers: await _mergeHeaders(
            headers,
            requireAuthToken: requireAuthToken,
          ),
        ),
      );

      return response;
    } catch (error) {
      // fnHandleControllerException(error, stackTrace, "ApiService", "post");
      return null; // or rethrow the error based on your need
    }
  }

  static Future<String?> getRefreshToken() async {
    // try {
    //   final accountID = Storage.readString(Storage.accountID);
    //   final accessToken = await FlutterSecureStore().getSingleValue(
    //     Storage.accessToken,
    //   );
    //   final refreshToken = await FlutterSecureStore().getSingleValue(
    //     Storage.refreshToken,
    //   );

    //   if (refreshToken != null) {
    //     Map<String, dynamic> requestBody = {
    //       'AccountId': accountID,
    //       'RefreshToken': refreshToken,
    //       'AccessToken': accessToken,
    //     };

    //     Map<String, String> headers = {};

    //     final result = await dio.post(
    //       EndPoints.apiGetFreshToken,
    //       data: jsonEncode(requestBody),
    //       options: Options(
    //         headers: await _mergeHeaders(headers, requireAuthToken: false),
    //       ),
    //     );

    //     if (result.statusCode == 200) {
    //       RefreshTokenModel refreshTokenData = RefreshTokenModel.fromJson(
    //         result.data,
    //       );
    //       await FlutterSecureStore().storeSingleValue(
    //         Storage.accessToken,
    //         refreshTokenData.accessToken,
    //       );
    //       await FlutterSecureStore().storeSingleValue(
    //         Storage.refreshToken,
    //         refreshTokenData.refreshToken,
    //       );
    //       return refreshTokenData.accessToken;
    //     } else {
    //       if (!isProduction) {
    //         log(
    //           " '\x1B[31m' API Refresh token status code error, Please Login",
    //         );
    //         // logger.i("API Refresh token status code error, Please Login");
    //       }
    //       return null;
    //     }
    //   } else {
    //     if (!isProduction) {
    //       log(" '\x1B[31m' No Refresh Token, Please Login");
    //       // logger.i("No Refresh Token, Please Login");
    //     }
    //     return null;
    //   }
    // } catch (error) {
    //   // fnHandleControllerException(error, stackTrace, "ApiService", "getRefreshToken");

    //   //logout();
    //   // await Get.dialog(
    //   //   CustomConfirmationDialog(
    //   //     header: "Testing purpose",
    //   //     body: 'exception getRefreshToken: $error',
    //   //     onNo: () {
    //   //       Get.back();
    //   //     },
    //   //     onYes: () {
    //   //       Get.offAllNamed(Routes.login);
    //   //     },
    //   //     noText: "Okay",
    //   //     yesText: "Login here",
    //   //   ),
    //   //   barrierColor: Constants.bgBackDropColor,
    //   //   barrierDismissible: false, // Prevents closing the dialog by tapping outside
    //   // );
    //   // if (!isProduction) {
    //   //   logger.e("DioException::$error ");
    //   // }
    // }
    return "eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiS0lSQU4sICBTQUVFRCIsIkFwcE1Vc2VySWQiOiI3IiwiRmlsZU5vIjoiMjgxNjY1IiwiTW9iaWxlIjoiMDU2ODc0NzcyMCIsIlBhdGllbnRNYXN0ZXJJZCI6IjE5NTI3MiIsIlNCVUlkIjoiMSIsIkxhbmciOiJlbiIsImV4cCI6MTc0MjkwOTU2MiwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NDQzNDMiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo0NDM0MyJ9.xXUT51cDU_PqSvMZhDchIVGVJfw9YJ5dbtLU75wVCEI";
  }

  /// Triming the Empty Space for Every String in Map.
  static Map<String, dynamic> _trimMap(Map<String, dynamic> map) {
    return Map<String, dynamic>.from(
      map.map((key, value) {
        if (value is String) {
          return MapEntry(key, value.trim());
        } else if (value is Map) {
          return MapEntry(key, _trimMap(value as Map<String, dynamic>));
        } else if (value is List) {
          return MapEntry(key, _trimList(value));
        }
        return MapEntry(key, value);
      }),
    );
  }

  /// Triming the Empty Space for Every String in List.
  static List<dynamic> _trimList(List<dynamic> list) {
    return list.map((item) {
      if (item is String) {
        return item.trim();
      } else if (item is Map) {
        return _trimMap(item as Map<String, dynamic>);
      } else if (item is List) {
        return _trimList(item);
      }
      return item;
    }).toList();
  }

  // static bool logout() {
  //   FlutterSecureStore().deleteAllData();
  //   Storage.remove(Storage.loginResponse);
  //   Storage.remove(Storage.username);
  //   Storage.remove(Storage.emailId);
  //   Storage.remove(Storage.mobileNo);
  //   Storage.remove(Storage.accountID);
  //   Storage.remove(Storage.userRole);
  //   Storage.remove(Storage.roleId);
  //   Get.offAllNamed(Routes.login);
  //   return false;
  // }
}
