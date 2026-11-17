import 'dart:async';
import 'dart:io';

import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/api_error_helper.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart';
import '../../helpers/secure_store.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/otp_model.dart';
import '../../routes/app_routes.dart';

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;
  final RxBool isLoading = false.obs;

  /// Mirrors the 6 boxes so a resend can clear them.
  final TextEditingController otpCtrl = TextEditingController();

  late String customerId;
  String? phone; // ✅ phone instead of email
  int otpLength = 6;

  /// true while the verify request is running
  final isVerifying = false.obs;

  /// true while a new code is being requested
  final isResending = false.obs;

  /// "Resend OTP" unlocks when this reaches 0 (server cooldown, 60 s default).
  final resendSeconds = 0.obs;

  /// OTP validity countdown (5 min default). At 0 the code is dead.
  final expirySeconds = 0.obs;

  Timer? _resendTimer;
  Timer? _expiryTimer;

  bool get canResend => resendSeconds.value == 0 && !isResending.value;

  bool get isExpired => expirySeconds.value == 0;

  String get resendCountdown => _formatSeconds(resendSeconds.value);

  String get expiryCountdown => _formatSeconds(expirySeconds.value);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments is Map ? Get.arguments as Map : const {};

    customerId = (args["customerId"] ?? "").toString();
    phone = args["phone"]?.toString();
    otpLength = _asInt(args["otpLength"], 6);

    if (customerId.isEmpty) {
      errorToast("invalid_customer_id".tr);
      Get.back();
      return;
    }

    // The countdowns come from the server response, so the SMS validity and the
    // resend cooldown can be changed in .env without touching the app.
    _startTimers(
      resendAfter: _asInt(args["resendAfterSeconds"], 60),
      expiresIn: _asInt(args["expiresInSeconds"], 300),
    );

    print("CustomerId: $customerId");
    print("Phone: $phone");
  }

  void setOtp(String value) {
    otp.value = value;
  }

  // ================= TIMERS =================

  void _startTimers({required int resendAfter, required int expiresIn}) {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();

    resendSeconds.value = resendAfter < 0 ? 0 : resendAfter;
    expirySeconds.value = expiresIn < 0 ? 0 : expiresIn;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (expirySeconds.value <= 1) {
        expirySeconds.value = 0;
        timer.cancel();
      } else {
        expirySeconds.value--;
      }
    });
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<void> verifyOtp() async {
    if (isVerifying.value) return;

    if (isExpired) {
      errorToast("otp_expired_request_new".tr);
      return;
    }

    if (otp.value.length != otpLength) {
      errorToast("enter_valid_otp".tr);
      return;
    }

    if (customerId.isEmpty) {
      errorToast("invalid_customer_id".tr);
      return;
    }

    // isVerifying.value = true;
    // loadingPopUp(true);
    isVerifying.value = true;
    isLoading.value = true;
    try {
      final resp = await repository.postVerifyOtpPhone({
        "id": customerId,
        "otp": otp.value,
      });

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success || !data.verified) {
        loadingPopUp(false);
        errorToast(data.message);
        return;
      }

      final customer = data.customer;
      final token = data.token;

      /// SAVE TOKEN
      await FlutterSecureStore().storeSingleValue(
        SharedPrefsHelper.accessToken,
        token ?? "",
      );

      /// SAVE CUSTOMER DATA

      await SharedPrefsHelper.setString("customerUuid", customer?.id ?? "");

      await SharedPrefsHelper.setString(
        "customerName",
        "${customer?.firstName ?? ""} "
                "${customer?.lastName ?? ""}"
            .trim(),
      );

      await SharedPrefsHelper.setString("customerEmail", customer?.email ?? "");

      await SharedPrefsHelper.setString(
        "customerPhone",
        customer?.mobile ?? "",
      );

      /// commented for ios run
      // String? fcmToken = await FirebaseMessaging.instance.getToken();

      // print("REAL FCM TOKEN: $fcmToken");

      // if (fcmToken != null) {
      //   await sendFcmTokenToBackend(fcmToken);

      //   /// SUBSCRIBE USER TO ALL USERS TOPIC
      //   await FirebaseMessaging.instance.subscribeToTopic("all_users");

      //   print("Subscribed to all_users topic");
      // }

      ///added for ios run
      /// Register FCM token without blocking OTP verification
      try {
        final messaging = FirebaseMessaging.instance;
        String? fcmToken;

        if (Platform.isIOS) {
          // APNs must be available before requesting the FCM token on iOS.
          String? apnsToken;

          for (int i = 0; i < 10; i++) {
            apnsToken = await messaging.getAPNSToken();

            if (apnsToken != null && apnsToken.isNotEmpty) {
              break;
            }

            await Future.delayed(const Duration(seconds: 1));
          }

          if (apnsToken == null || apnsToken.isEmpty) {
            print(
              'APNs token unavailable. '
              'Skipping FCM registration for now.',
            );
          } else {
            fcmToken = await messaging.getToken();
          }
        } else {
          fcmToken = await messaging.getToken();
        }

        if (fcmToken != null && fcmToken.isNotEmpty) {
          print('REAL FCM TOKEN: $fcmToken');

          await sendFcmTokenToBackend(fcmToken);

          try {
            await messaging.subscribeToTopic('all_users');
            print('Subscribed to all_users topic');
          } catch (e) {
            print('Topic subscription failed: $e');
          }
        }
      } catch (e, stackTrace) {
        // Push notification registration must not prevent successful login.
        print('FCM registration failed: $e');
        print(stackTrace);
      }
      successToast("otp_verified".tr);

      loadingPopUp(false);

      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      loadingPopUp(false);

      print("Verify OTP Error: $e");

      // A dead code must not keep the customer typing: turn the countdown off so
      // the screen switches to "expired, please resend".
      final code = apiErrorCode(e);
      if (code == 'OTP_EXPIRED' ||
          code == 'OTP_ATTEMPTS_EXCEEDED' ||
          code == 'OTP_NOT_FOUND') {
        _expiryTimer?.cancel();
        expirySeconds.value = 0;
      }

      errorToast(apiErrorMessage(e, "otp_verification_failed".tr));
    } finally {
      // isVerifying.value = false;
      isVerifying.value = false;
      isLoading.value = false;
    }
  }

  // ================= RESEND OTP =================

  /// Asks the backend for a fresh code.
  ///
  /// Uses the same `authentical/send-otp` endpoint: the server keeps the same
  /// customer row (it only creates one when the number is new) and answers 429
  /// with `retry_after_seconds` when the 60 s cooldown has not passed yet.
  Future<void> resend() async {
    if (!canResend) return;

    final number = (phone ?? '').trim();

    if (number.isEmpty) {
      errorToast("enter_phone_number".tr);
      return;
    }

    isResending.value = true;

    try {
      final resp = await repository.postRequestOtpPhone({"phone": number});
      final data = Loginmodel.fromJson(Map<String, dynamic>.from(resp.data));

      if (!data.success) {
        errorToast(
          data.message.isNotEmpty ? data.message : "something_went_wrong".tr,
        );
        return;
      }

      if ((data.id ?? '').isNotEmpty) customerId = data.id!;
      if (data.phone.isNotEmpty) phone = data.phone;

      // Clear the old digits so the customer types the new code.
      otpCtrl.clear();
      otp.value = "";

      successToast("otp_resent_successfully".tr);

      _startTimers(
        resendAfter: data.resendAfterSeconds,
        expiresIn: data.expiresInSeconds,
      );
    } on DioException catch (e) {
      // Respect the server cooldown when it answers 429.
      final retryAfter = apiRetryAfterSeconds(e);
      if (retryAfter != null && retryAfter > 0) {
        resendSeconds.value = retryAfter;
      }

      errorToast(apiErrorMessage(e, "something_went_wrong".tr));
    } catch (e) {
      print("Resend OTP Error: $e");
      errorToast(apiErrorMessage(e, "something_went_wrong".tr));
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    otpCtrl.dispose();
    super.onClose();
  }

  Future<void> sendFcmTokenToBackend(String token) async {
    try {
      await ApiService.put(
          "customers/fcm-token",
          {
            "fcmToken": token,
            "platform": Platform.operatingSystem,
          },
          requireAuthToken: true);

      print("FCM token sent to backend");
    } catch (e) {
      print("Error sending FCM token: $e");
    }
  }
}
