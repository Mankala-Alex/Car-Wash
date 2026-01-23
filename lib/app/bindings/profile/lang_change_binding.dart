import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/lang_change_controller.dart';

class LangChangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LangChangeController>(() => LangChangeController());
  }
}
