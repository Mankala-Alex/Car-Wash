import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/terms_conditions_controller.dart';

class TermsConditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionsController>(() => TermsConditionsController());
  }
}
