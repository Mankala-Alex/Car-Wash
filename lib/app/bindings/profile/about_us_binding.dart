import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/about_us_controller.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(() => AboutUsController());
  }
}
