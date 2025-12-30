import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/models/coupon_details_model.dart';
import '../../services/endpoints.dart';
import '../../services/api_service.dart';

class CouponDetailsController extends GetxController {
  final isLoading = true.obs;
  final coupon = Rxn<CouponDetailsModel>();

  late String couponCode;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args == null || args["coupon_code"] == null) {
      isLoading.value = false;
      return;
    }

    couponCode = args["coupon_code"];
    fetchCouponDetails();
  }

  Future<void> fetchCouponDetails() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        "${EndPoints.apigetcoupondetails}?coupon_code=$couponCode",
      );

      final data = response.data["data"];
      if (data != null) {
        coupon.value = CouponDetailsModel.fromJson(data);
      }
    } catch (e) {
      coupon.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UI HELPERS =================

  String get formattedExpiry {
    if (coupon.value == null) return "";
    return DateFormat("dd MMM, yyyy").format(coupon.value!.expiresAt.toLocal());
  }

  bool get isActive =>
      coupon.value != null &&
      coupon.value!.status == "ACTIVE" &&
      !coupon.value!.isExpired;

  /// UI-friendly status
  String get displayStatus {
    if (coupon.value == null) return "";
    if (coupon.value!.status == "IN_PROGRESS") return "PENDING";
    return coupon.value!.status;
  }
}
