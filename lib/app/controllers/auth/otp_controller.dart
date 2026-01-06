import 'package:get/get.dart';
import 'package:my_new_app/app/models/auth/otp_model.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart';

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;

  late String customerId;
  late String email; // ✅ EMAIL, not phone

  @override
  void onInit() {
    customerId = Get.arguments["customerId"] ?? "";
    email = Get.arguments["email"]; // ✅ FIX
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
      final resp = await repository.postVerifyOtp({
        "id": customerId,
        "otp": otp.value,
      });

      loadingPopUp(false);

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      final customer = resp.data["customer"];
      if (customer != null) {
        await SharedPrefsHelper.setString("customerUuid", customer["id"]);
        await SharedPrefsHelper.setString(
          "customerName",
          "${customer["firstName"]} ${customer["lastName"]}".trim(),
        );
        await SharedPrefsHelper.setString("customerEmail", customer["email"]);
      }

      successToast("OTP Verified!");
      return data;
    } catch (e) {
      loadingPopUp(false);
      errorToast("OTP verification failed");
      return null;
    }
  }
}
