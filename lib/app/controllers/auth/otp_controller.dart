import 'package:get/get.dart';
import 'package:my_new_app/app/models/auth/otp_model.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart';

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;

  late String customerId; // UUID from login/signup
  late String phone;

  @override
  void onInit() {
    customerId = Get.arguments["customerId"] ?? "";
// UUID
    phone = Get.arguments["phone"];
    super.onInit();
  }

  void setOtp(String value) {
    otp.value = value;
  }

  Future<Otpmodel?> verifyOtp() async {
    if (otp.value.length != 4) {
      errorToast("Enter valid OTP");
      return null;
    }

    loadingPopUp(true);

    try {
      print("📤 SENDING BODY TO BACKEND:");
      print({
        "id": customerId,
        "otp": otp.value,
      });

      final resp = await repository.postVerifyOtp({
        "id": customerId, // <-- REQUIRED BY BACKEND
        "otp": otp.value,
      });

      loadingPopUp(false);

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      // --------------------------------------------------------
      // SAVE CUSTOMER DETAILS — UUID ONLY (NO NUMERIC ID)
      // --------------------------------------------------------
      final customer = resp.data["customer"];
      if (customer != null) {
        final String uuid = customer["id"];
        final String fullName =
            "${customer["firstName"] ?? ""} ${customer["lastName"] ?? ""}"
                .trim();
        final String email = customer["email"] ?? "";

        print("🔵 OTP Verified: Saving user profile...");
        print("UUID: $uuid");
        print("Name: $fullName");

        // SAVE UUID ONLY
        await SharedPrefsHelper.setString("customerUuid", uuid);

        // SAVE NAME
        await SharedPrefsHelper.setString("customerName", fullName);

        // SAVE EMAIL
        await SharedPrefsHelper.setString("customerEmail", email);

        // SAVE PHONE
        await SharedPrefsHelper.setString("customerPhone", phone);
      }

      // --------------------------------------------------------
      // OTP SUCCESS FEEDBACK
      // --------------------------------------------------------
      successToast("OTP Verified!");
      return data;
    } catch (e) {
      loadingPopUp(false);
      errorToast("OTP verification failed");
      return null;
    }
  }
}
