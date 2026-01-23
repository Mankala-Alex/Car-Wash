import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
