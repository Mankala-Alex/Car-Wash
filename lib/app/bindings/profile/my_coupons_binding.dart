import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/coupons_list_controller.dart';

class MyCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponsListController>(() => CouponsListController());
  }
}
