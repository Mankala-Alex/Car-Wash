import 'package:get/get.dart';

import '../../controllers/auth/lang_selection_controller.dart';

class LangSelectionBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LangSelectionController());
  }
}
