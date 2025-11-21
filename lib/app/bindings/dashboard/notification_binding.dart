import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
