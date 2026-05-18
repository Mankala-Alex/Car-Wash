import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart';
import '../../helpers/secure_store.dart';
import '../../models/auth/otp_model.dart';
import '../../routes/app_routes.dart';

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

      loadingPopUp(false);

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success || !data.verified) {
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

      successToast("OTP Verified");

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      print("REAL FCM TOKEN: $fcmToken");

      if (fcmToken != null) {
        await sendFcmTokenToBackend(fcmToken);

        /// SUBSCRIBE USER TO ALL USERS TOPIC
        await FirebaseMessaging.instance.subscribeToTopic("all_users");

        print("Subscribed to all_users topic");
      }
      Get.offAllNamed(
        Routes.dashboard,
      );
    } catch (e) {
      loadingPopUp(false);

      print("Verify OTP Error: $e");

      errorToast(
        "otp_verification_failed".tr,
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
