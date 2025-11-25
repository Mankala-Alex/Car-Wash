import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/my_coupons_controller.dart';

class MyCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCouponsController>(() => MyCouponsController());
  }
}
