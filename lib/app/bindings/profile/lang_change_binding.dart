import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/lang_change_controller.dart';

class LangChangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LangChangeController>(() => LangChangeController());
  }
}
