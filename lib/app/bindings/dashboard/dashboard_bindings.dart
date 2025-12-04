import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/controllers/profile/offers_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<OffersController>(() => OffersController());
    Get.lazyPut<FeaturesListController>(() => FeaturesListController());
  }
}
