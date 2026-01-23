import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offers_controller.dart';
import 'package:car_wash_customer_app/app/services/socket_service.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize SocketService once
    Get.put<SocketService>(SocketService());

    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<OffersController>(() => OffersController());
    Get.lazyPut<FeaturesListController>(() => FeaturesListController());
  }
}
