import 'package:car_wash_customer_app/app/models/booking%20slot/saved_location_model.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';

class LocationListController extends GetxController {
  late BookSlotController bookSlotController;

  @override
  void onInit() {
    super.onInit();
    bookSlotController = Get.find<BookSlotController>();
  }

  RxList<SavedLocation> get locations => bookSlotController.savedLocations;

  /// Removes the address, persists the list and keeps the selection valid.
  Future<void> deleteLocation(SavedLocation location) =>
      bookSlotController.removeSavedLocation(location);
}
