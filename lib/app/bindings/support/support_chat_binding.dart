import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/support_chat_controller.dart';

class SupportChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportChatController>(() => SupportChatController());
  }
}
