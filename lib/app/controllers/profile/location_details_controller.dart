import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:car_wash_customer_app/app/helpers/api_error_helper.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/custome_widgets/wheel_loader.dart';
import 'package:car_wash_customer_app/app/repositories/customers/customer_repository.dart';

class LocationDetailsController extends GetxController {
  final CustomerRepository _customerRepository = CustomerRepository();

  late BookSlotController bookSlotController;
  late TextEditingController houseNoController;
  late TextEditingController landmarkController;
  late TextEditingController phoneController;

  /// The customer's own name. It is NOT part of the address: it is captured here
  /// because the app no longer has a signup form (phone number only), and it is
  /// stored once on the customer record so the profile tab and the technician
  /// app can show it.
  late TextEditingController nameController;

  // Variables passed from previous screen
  late double latitude;
  late double longitude;
  late String address;
  String? pincode;
  SavedLocation? editingLocation;

  /// True while the address is being saved. The Save button is disabled and
  /// the wheel loader stays on screen until the write is done (minimum 1s).
  final RxBool isSaving = false.obs;

  /// How long the loader is kept visible at least, so a very fast save does
  /// not make the screen flash and leaves the customer unsure it worked.
  static const Duration _minimumLoaderTime = Duration(seconds: 1);

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
      houseNoController = TextEditingController(text: editingLocation!.houseNo);
      landmarkController = TextEditingController(
        text: editingLocation!.landmark ?? '',
      );
      phoneController = TextEditingController(
        text: editingLocation!.phoneNumber,
      );
    } else {
      houseNoController = TextEditingController();
      landmarkController = TextEditingController();
      phoneController = TextEditingController();
      _prefillCustomerPhone();
    }

    nameController = TextEditingController();
    _prefillCustomerName();
  }

  /// Shows the name we already know (saved profile / previous address).
  Future<void> _prefillCustomerName() async {
    try {
      final stored = (await SharedPrefsHelper.getString("customerName")).trim();

      if (stored.isNotEmpty && nameController.text.trim().isEmpty) {
        nameController.text = stored;
      }
    } catch (e) {
      print('Could not prefill customer name: $e');
    }
  }

  /// Persists the name on the customer record (once, only when it changed).
  ///
  /// The address itself is already saved locally at this point, so a failure
  /// here never loses the address - it only means the name will be asked again
  /// next time.
  Future<void> _saveCustomerName(String name) async {
    if (name.isEmpty) return;

    final stored = (await SharedPrefsHelper.getString("customerName")).trim();

    if (stored.toLowerCase() == name.toLowerCase()) return;

    try {
      await _customerRepository.updateMyName(name);

      await SharedPrefsHelper.setString("customerName", name);

      // Keep the profile tab in sync without a restart.
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().customerName.value = name;
      }
    } catch (e) {
      print('Could not save customer name: $e');
      errorToast(apiErrorMessage(e, 'something_went_wrong'.tr));
    }
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
    nameController.dispose();
    super.onClose();
  }

  /// The label stored on the address.
  ///
  /// The app no longer asks the customer to pick Home / Work / Other: any number
  /// of addresses can be saved, so the label is just the house number (used as
  /// the title of the saved address card). The booking record keeps it as
  /// `address_label` for the technician.
  String get _addressLabel {
    final houseNo = houseNoController.text.trim();
    final label = houseNo.isNotEmpty ? houseNo : 'address'.tr;

    // bookings.address_label is VARCHAR(30) - never send more than that.
    return label.length > 30 ? label.substring(0, 30) : label;
  }

  Future<void> saveLocation() async {
    // Guards against a double tap while the loader is showing.
    if (isSaving.value) return;

    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      errorToast('enter_your_name'.tr);
      return;
    }

    if (houseNoController.text.isEmpty) {
      errorToast('please_enter_house_number'.tr);
      return;
    }

    if (phoneController.text.isEmpty) {
      errorToast('please_enter_phone_number'.tr);
      return;
    }

    isSaving.value = true;
    showWheelLoaderDialog(size: 120);

    // Started now and awaited at the end: guarantees the wheel loader is shown
    // for at least one second even when the save finishes instantly.
    final minimumLoaderTime = Future<void>.delayed(_minimumLoaderTime);

    String? successMessage;

    try {
      if (editingLocation != null) {
        // Update existing location
        final updatedLocation = SavedLocation(
          id: editingLocation!.id,
          label: _addressLabel,
          address: address,
          latitude: latitude,
          longitude: longitude,
          houseNo: houseNoController.text,
          landmark:
              landmarkController.text.isEmpty ? null : landmarkController.text,
          phoneNumber: phoneController.text,
          pincode: pincode ?? editingLocation!.pincode,
        );

        await bookSlotController.updateSavedLocation(
          editingLocation!,
          updatedLocation,
        );

        successMessage = 'location_updated_successfully'.tr;
      } else {
        // Create new location
        final savedLocation = SavedLocation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: _addressLabel,
          address: address,
          latitude: latitude,
          longitude: longitude,
          houseNo: houseNoController.text,
          landmark:
              landmarkController.text.isEmpty ? null : landmarkController.text,
          phoneNumber: phoneController.text,
          pincode: pincode,
        );

        await bookSlotController.addSavedLocation(savedLocation);

        successMessage = 'location_saved_successfully'.tr;
      }

      // No signup form any more: this is where we finally learn the customer's
      // name, so save it on the customer record too.
      await _saveCustomerName(nameController.text.trim());

      // Never dismiss the loader before the minimum time has elapsed.
      await minimumLoaderTime;
    } catch (e) {
      print('Could not save location: $e');
      successMessage = null;
      errorToast(apiErrorMessage(e, 'something_went_wrong'.tr));
    } finally {
      hideWheelLoaderDialog();
      isSaving.value = false;
    }

    // Something failed - keep the customer on this screen so they can retry.
    if (successMessage == null) return;

    successToast(successMessage);

    Get.back();
    Get.back();
  }
}
