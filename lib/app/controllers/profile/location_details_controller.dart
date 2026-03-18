import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';

class LocationDetailsController extends GetxController {
  late BookSlotController bookSlotController;
  late TextEditingController houseNoController;
  late TextEditingController landmarkController;
  late TextEditingController phoneController;
  late String selectedSaveAs;

  final List<String> saveAsOptions = ['Home', 'Work', 'Other'];

  // Variables passed from previous screen
  late double latitude;
  late double longitude;
  late String address;
  SavedLocation? editingLocation;

  @override
  void onInit() {
    super.onInit();
    bookSlotController = Get.find<BookSlotController>();

    // Get arguments from previous screen
    if (Get.arguments != null) {
      latitude = Get.arguments['latitude'] ?? 0.0;
      longitude = Get.arguments['longitude'] ?? 0.0;
      address = Get.arguments['address'] ?? '';
      editingLocation = Get.arguments['editingLocation'];
    }

    _initializeControllers();
  }

  void _initializeControllers() {
    if (editingLocation != null) {
      selectedSaveAs = editingLocation!.label;
      houseNoController = TextEditingController(text: editingLocation!.houseNo);
      landmarkController =
          TextEditingController(text: editingLocation!.landmark ?? '');
      phoneController =
          TextEditingController(text: editingLocation!.phoneNumber);
    } else {
      selectedSaveAs = 'Home';
      houseNoController = TextEditingController();
      landmarkController = TextEditingController();
      phoneController = TextEditingController();
    }
  }

  @override
  void onClose() {
    houseNoController.dispose();
    landmarkController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void saveLocation() {
    // Validate required fields
    if (houseNoController.text.isEmpty) {
      errorToast('Please enter house number');
      return;
    }

    if (phoneController.text.isEmpty) {
      errorToast('Please enter phone number');
      return;
    }

    if (editingLocation != null) {
      // Update existing location
      final updatedLocation = SavedLocation(
        id: editingLocation!.id,
        label: selectedSaveAs,
        address: address,
        latitude: latitude,
        longitude: longitude,
        houseNo: houseNoController.text,
        landmark:
            landmarkController.text.isEmpty ? null : landmarkController.text,
        phoneNumber: phoneController.text,
      );

      bookSlotController.updateSavedLocation(
        editingLocation!,
        updatedLocation,
      );

      successToast('Location updated successfully');
    } else {
      // Create new location
      final savedLocation = SavedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: selectedSaveAs,
        address: address,
        latitude: latitude,
        longitude: longitude,
        houseNo: houseNoController.text,
        landmark:
            landmarkController.text.isEmpty ? null : landmarkController.text,
        phoneNumber: phoneController.text,
      );

      bookSlotController.addSavedLocation(savedLocation);
      successToast('Location saved successfully');
    }

    Get.back();
    Get.back();
  }

  void updateSaveAs(String? value) {
    if (value != null) {
      selectedSaveAs = value;
      update();
    }
  }
}
