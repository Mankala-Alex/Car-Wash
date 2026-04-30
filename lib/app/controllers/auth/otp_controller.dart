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
      errorToast("Invalid customer ID");
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
      errorToast("Enter valid OTP");
      return;
    }

    if (customerId.isEmpty) {
      errorToast("Invalid customer ID");
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

      Get.offAllNamed(
        Routes.dashboard,
      );
    } catch (e) {
      loadingPopUp(false);

      print("Verify OTP Error: $e");

      errorToast(
        "OTP verification failed",
      );
    }
  }
}
