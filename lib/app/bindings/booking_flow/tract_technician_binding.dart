import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/tract_technician_controller.dart';

class TractTechnicianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackTechnicianController>(() => TrackTechnicianController());
  }
}
