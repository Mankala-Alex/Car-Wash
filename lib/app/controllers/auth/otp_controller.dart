import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/api_error_helper.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart';
import '../../helpers/secure_store.dart';
import '../../models/auth/otp_model.dart';
import '../../routes/app_routes.dart';
import 'dart:io';

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;

  late String customerId;
  String? phone; // ✅ phone instead of email

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    customerId = args["customerId"] ?? "";
    phone = args["phone"];

    if (customerId.isEmpty) {
      errorToast("invalid_customer_id".tr);
      Get.back();
      return;
    }

    print("CustomerId: $customerId");
    print("Phone: $phone");
  }

  void setOtp(String value) {
    otp.value = value;
  }

  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      errorToast("enter_valid_otp".tr);
      return;
    }

    if (customerId.isEmpty) {
      errorToast("invalid_customer_id".tr);
      return;
    }

    loadingPopUp(true);

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

      await SharedPrefsHelper.setString(
        "customerUuid",
        customer?.id ?? "",
      );

      await SharedPrefsHelper.setString(
        "customerName",
        "${customer?.firstName ?? ""} "
                "${customer?.lastName ?? ""}"
            .trim(),
      );

      await SharedPrefsHelper.setString(
        "customerEmail",
        customer?.email ?? "",
      );

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

      Get.offAllNamed(
        Routes.dashboard,
      );
    } catch (e) {
      loadingPopUp(false);

      print("Verify OTP Error: $e");

      errorToast(
        apiErrorMessage(e, "otp_verification_failed".tr),
      );
    }
  }

  Future<void> sendFcmTokenToBackend(String token) async {
    try {
      await ApiService.put(
        "customers/fcm-token",
        {
          "fcmToken": token,
        },
        requireAuthToken: true,
      );

      print("FCM token sent to backend");
    } catch (e) {
      print("Error sending FCM token: $e");
    }
  }
}
