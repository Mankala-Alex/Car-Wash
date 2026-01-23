import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offers_controller.dart';

class OffersListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
