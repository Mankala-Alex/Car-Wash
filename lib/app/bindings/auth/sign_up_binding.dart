import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/auth/sign_up_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}
