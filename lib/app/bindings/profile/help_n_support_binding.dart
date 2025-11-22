import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/help_n_support_controller.dart';

class HelpNSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpNSupportController>(() => HelpNSupportController());
  }
}
