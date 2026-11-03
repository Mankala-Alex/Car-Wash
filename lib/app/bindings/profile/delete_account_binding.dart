import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/delete_account_controller.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountController>(() => DeleteAccountController());
  }
}
