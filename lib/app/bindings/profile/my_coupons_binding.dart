import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/coupons_list_controller.dart';

class MyCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponsListController>(() => CouponsListController());
  }
}
