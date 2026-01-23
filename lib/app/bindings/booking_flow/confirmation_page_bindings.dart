import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/confirmation_page_controller.dart';

class ConfirmationPageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmationPageController>(() => ConfirmationPageController());
  }
}
