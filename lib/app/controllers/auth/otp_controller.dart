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
  late String email;

  @override
  void onInit() {
    customerId = Get.arguments["customerId"];
    email = Get.arguments["email"];
    super.onInit();
  }

  void setOtp(String value) {
    otp.value = value;
  }

  Future<void> verifyOtp() async {
    if (otp.value.length != 4) {
      errorToast("Enter valid OTP");
      return;
    }

    loadingPopUp(true);

    try {
      final resp = await repository.postVerifyOtp({
        "id": customerId,
        "otp": otp.value,
      });

      loadingPopUp(false);

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return;
      }

      final customer = resp.data["customer"];
      final token = resp.data["token"];

      // ✅ SAVE JWT TOKEN TO SECURE STORAGE (ApiService expects it here)
      await FlutterSecureStore().storeSingleValue(
        SharedPrefsHelper.accessToken,
        token,
      );

      // ✅ SAVE CUSTOMER DETAILS TO SHARED PREFS
      await SharedPrefsHelper.setString("customerUuid", customer["id"]);
      await SharedPrefsHelper.setString(
        "customerName",
        "${customer["firstName"]} ${customer["lastName"]}".trim(),
      );
      await SharedPrefsHelper.setString("customerEmail", customer["email"]);
      await SharedPrefsHelper.setString("customerPhone", customer["mobile"]);

      successToast("OTP Verified");
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      loadingPopUp(false);
      errorToast("OTP verification failed");
    }
  }
}
