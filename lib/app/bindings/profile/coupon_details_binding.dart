import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/coupon_details_controller.dart';

class CouponDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponDetailsController>(() => CouponDetailsController());
  }
}
