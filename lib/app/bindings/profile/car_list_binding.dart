import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/car_list_controller.dart';

class CarListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarListController>(() => CarListController());
  }
}
