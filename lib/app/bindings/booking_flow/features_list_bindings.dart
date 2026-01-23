import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';

class FeaturesListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeaturesListController>(() => FeaturesListController());
  }
}
