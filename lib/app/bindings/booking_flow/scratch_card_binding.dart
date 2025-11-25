import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/scratch_card_controller.dart';

class ScratchCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScratchCardController>(() => ScratchCardController());
  }
}
