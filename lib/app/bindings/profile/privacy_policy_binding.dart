import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/privacy_policy_controller.dart';

class PrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacyPolicyController>(() => PrivacyPolicyController());
  }
}
