import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/models/coupons_list_model.dart';
import 'package:car_wash_customer_app/app/repositories/coupon/coupon_repository.dart';

class CouponDetailsController extends GetxController {
  final CouponRepository _repository = CouponRepository();

  final isLoading = true.obs;
  final coupon = Rxn<CouponsListModel>();

  /// Localization key of the last load error (`''` when there is none).
  final errorKey = ''.obs;

  /// True for a short moment after the code is copied (drives the ✅ icon).
  final isCopied = false.obs;

  late String couponCode;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    final code = args?["coupon_code"]?.toString() ?? '';
    if (code.isEmpty) {
      isLoading.value = false;
      errorKey.value = 'coupon_not_found';
      return;
    }

    couponCode = code;
    fetchCouponDetails();
  }

  Future<void> fetchCouponDetails() async {
    try {
      isLoading.value = true;
      errorKey.value = '';

      final response = await _repository.fetchCouponDetails(couponCode);
      final body = response.data;

      if (body is! Map || body['success'] != true) {
        throw Exception('Unexpected coupon details payload: $body');
      }

      final data = body['data'];
      if (data is! Map) {
        throw Exception('Coupon details payload has no data');
      }

      coupon.value = CouponsListModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print("❌ Error fetching coupon details: $e");
      coupon.value = null;
      errorKey.value = couponErrorKey(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UI HELPERS =================

  String get formattedExpiry {
    final expiry = coupon.value?.expiresAt;
    if (expiry == null) return "";
    return DateFormat("dd MMM, yyyy").format(expiry.toLocal());
  }

  String get formattedAwardedAt {
    final awarded = coupon.value?.awardedAt;
    if (awarded == null) return "";
    return DateFormat("dd MMM, yyyy").format(awarded.toLocal());
  }

  bool get isActive => coupon.value?.isActive ?? false;

  /// UI-friendly, localized status
  String get displayStatus => coupon.value?.statusKey.tr ?? "";

  /// ================= COPY CODE =================
  Future<void> copyCouponCode() async {
    final code = coupon.value?.couponCode.trim() ?? "";
    if (code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));

    isCopied.value = true;
    successToast("code_copied".tr);

    // Revert the icon back to "copy" after a short delay.
    await Future.delayed(const Duration(seconds: 2));
    if (isClosed) return;
    isCopied.value = false;
  }
}
