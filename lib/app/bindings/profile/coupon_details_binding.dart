import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/coupon_details_controller.dart';

class CouponDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponDetailsController>(() => CouponDetailsController());
  }
}
