import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/help_center_controller.dart';

class HelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterController>(() => HelpCenterController());
  }
}
