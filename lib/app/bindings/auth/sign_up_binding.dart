import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/auth/sign_up_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}
