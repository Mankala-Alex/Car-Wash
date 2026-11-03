import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/faq_chat_controller.dart';

class FaqChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaqChatController>(() => FaqChatController());
  }
}
