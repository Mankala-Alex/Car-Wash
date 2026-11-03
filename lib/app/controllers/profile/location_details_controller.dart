import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';

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
  String? pincode;
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
      pincode = Get.arguments['pincode']?.toString();
      editingLocation = Get.arguments['editingLocation'];
    }

    if (editingLocation != null && (pincode == null || pincode!.isEmpty)) {
      pincode = editingLocation!.pincode;
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
      selectedSaveAs = _firstAvailableLabel();
      houseNoController = TextEditingController();
      landmarkController = TextEditingController();
      phoneController = TextEditingController();
      _prefillCustomerPhone();
    }
  }

  /// Whether another saved location already uses [label] (case-insensitive).
  /// The location currently being edited is ignored so its own label stays
  /// selectable.
  bool _isLabelTaken(String label) {
    final normalized = label.trim().toLowerCase();

    return bookSlotController.savedLocations.any((location) {
      if (editingLocation != null && location.id == editingLocation!.id) {
        return false;
      }
      return location.label.trim().toLowerCase() == normalized;
    });
  }

  /// First label the customer hasn't used yet, so a new address doesn't start
  /// on a label that is already taken.
  String _firstAvailableLabel() {
    for (final option in saveAsOptions) {
      if (!_isLabelTaken(option)) return option;
    }
    return saveAsOptions.first;
  }

  /// Pre-fills the phone field with the logged-in customer's mobile number so
  /// the user doesn't have to type it for every new address. The value is
  /// still editable, and an existing address keeps its own stored number.
  Future<void> _prefillCustomerPhone() async {
    try {
      var phone = (await SharedPrefsHelper.getString("customerPhone")).trim();

      if (phone.isEmpty) {
        phone = bookSlotController.customerPhone.trim();
      }

      if (phone.isNotEmpty && phoneController.text.trim().isEmpty) {
        phoneController.text = phone;
      }
    } catch (e) {
      print('Could not prefill customer phone: $e');
    }
  }

  @override
  void onClose() {
    houseNoController.dispose();
    landmarkController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Localizes the stored English label (Home / Work / Other) for display.
  String _localizedLocationLabel(String label) {
    switch (label) {
      case 'Home':
        return 'home'.tr;
      case 'Work':
        return 'work'.tr;
      case 'Other':
        return 'other'.tr;
      default:
        return label;
    }
  }

  void saveLocation() {
    // Validate required fields
    if (houseNoController.text.isEmpty) {
      errorToast('please_enter_house_number'.tr);
      return;
    }

    if (phoneController.text.isEmpty) {
      errorToast('please_enter_phone_number'.tr);
      return;
    }

    // Only one address per label (Home / Work / Other).
    if (_isLabelTaken(selectedSaveAs)) {
      errorToast(
          '${_localizedLocationLabel(selectedSaveAs)} ${'already_added'.tr}');
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
        pincode: pincode ?? editingLocation!.pincode,
      );

      bookSlotController.updateSavedLocation(
        editingLocation!,
        updatedLocation,
      );

      successToast('location_updated_successfully'.tr);
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
        pincode: pincode,
      );

      bookSlotController.addSavedLocation(savedLocation);
      successToast('location_saved_successfully'.tr);
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
