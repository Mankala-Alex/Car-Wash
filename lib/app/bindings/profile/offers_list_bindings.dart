import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/offers_controller.dart';

class OffersListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
