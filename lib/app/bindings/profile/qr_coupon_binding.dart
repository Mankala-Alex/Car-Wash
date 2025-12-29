import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/qr_coupon_controller.dart';

class QrCouponBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrCouponController>(() => QrCouponController());
  }
}
