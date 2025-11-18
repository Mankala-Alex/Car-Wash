import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/book_slot_controller.dart';



class BookSlotBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookSlotController>(() => BookSlotController());
  }
}
