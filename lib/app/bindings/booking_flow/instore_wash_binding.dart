import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/instore_wash_controller.dart';

class InstoreWashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstoreWashController>(() => InstoreWashController());
  }
}
