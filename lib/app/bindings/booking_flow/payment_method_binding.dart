import 'package:get/get.dart';
import '../../controllers/booking_flow/payment_method_controller.dart';

class PaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMethodController>(() => PaymentMethodController());
  }
}
