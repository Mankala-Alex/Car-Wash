import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/models/coupons_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/profile_repository.dart';

class QrCouponController extends GetxController {
  final ProfileRepository repository = ProfileRepository();

  final isLoading = true.obs;
  final coupon = Rxn<CouponData>();

  late String bookingCode;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args == null || args["booking_code"] == null) {
      print("❌ booking_code missing");
      return;
    }

    bookingCode = args["booking_code"];
    print("🎟 bookingCode = $bookingCode");

    fetchCoupon();
  }

  Future<void> fetchCoupon() async {
    try {
      isLoading.value = true;

      final resp = await repository.getCustomerCoupon(bookingCode);
      final model = CouponModel.fromJson(resp.data);

      if (model.success && model.data != null) {
        coupon.value = model.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  String get formattedExpiry {
    if (coupon.value == null) return "";
    return DateFormat("dd MMM yyyy").format(coupon.value!.expiresAt.toLocal());
  }

  bool get isRedeemable =>
      coupon.value != null &&
      coupon.value!.status == "ACTIVE" &&
      !coupon.value!.isExpired;
}
