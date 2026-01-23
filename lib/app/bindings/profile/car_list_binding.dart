import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/car_list_controller.dart';

class CarListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarListController>(() => CarListController());
  }
}
