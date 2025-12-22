import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking slot/booking_history_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  final repo = BookSlotRepository();

  var isLoading = false.obs;

  RxString customerName = ''.obs;
  RxString customerEmail = ''.obs;

  // BOOKINGS
  RxList<Datum> currentBookings = <Datum>[].obs;
  RxList<Datum> pastBookings = <Datum>[].obs;

  /// UUID (no numeric ID anymore)
  String customerUuid = "";

  @override
  void onInit() {
    super.onInit();
    loadCustomerInfo();
    fetchBookingHistory();
    final arg = Get.arguments;
    if (arg != null && arg is int) {
      selectedIndex.value = arg;
      print("🔥 Setting selectedIndex from arguments → $arg");
    }
  }

  // -----------------------------------------------------
  // LOAD CUSTOMER DATA (UUID + NAME + EMAIL)
  // -----------------------------------------------------
  Future<void> loadCustomerInfo() async {
    customerUuid = await SharedPrefsHelper.getString("customerUuid") ?? "";
    customerName.value =
        await SharedPrefsHelper.getString("customerName") ?? "";
    customerEmail.value =
        await SharedPrefsHelper.getString("customerEmail") ?? "";

    print("UUID = $customerUuid");
    print("NAME = ${customerName.value}");
    print("EMAIL = ${customerEmail.value}");

    if (customerUuid.isNotEmpty) {
      fetchBookingHistory();
    }
  }

  // -----------------------------------------------------
  // FETCH BOOKING HISTORY USING UUID ONLY
  // -----------------------------------------------------
  Future<void> fetchBookingHistory() async {
    if (customerUuid.isEmpty) return;

    try {
      final body = {"customer_id": customerUuid};

      final resp = await BookSlotRepository().postBookingsHistory(body);

      print("📥 HISTORY RESPONSE: ${resp.data}");

      final model = Bookinghistorymodel.fromJson(resp.data);

      splitBookings(model.data);

      print("✓ Loaded booking history: ${model.data.length}");
    } catch (e) {
      print("❌ Failed to load booking history: $e");
    }
  }

  // -----------------------------------------------------
  // SPLIT INTO CURRENT & PAST BOOKINGS
  // -----------------------------------------------------
  void splitBookings(List<Datum> allBookings) {
    currentBookings.value = allBookings.where((b) {
      return b.status == "PENDING" ||
          b.status == "ASSIGNED" ||
          b.status == "ARRIVED" ||
          b.status == "IN_PROGRESS";
    }).toList();

    pastBookings.value = allBookings.where((b) {
      return b.status == "COMPLETED";
    }).toList();

    print("✓ Current bookings: ${currentBookings.length}");
    print("✓ Past bookings: ${pastBookings.length}");
  }

  // -----------------------------------------------------
  // BOTTOM NAVIGATION
  // -----------------------------------------------------
  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  // ===== WALLET (unchanged) =====
  RxDouble selectedAmount = 1000.0.obs;
  RxInt selectedChipIndex = 1.obs;

  TextEditingController amountCtrl = TextEditingController(text: "1000");

  // DROPDOWN
  RxBool dropdownOpen = false.obs;
  RxInt selectedDropdownValue = 1000.obs;

  List<int> dropdownValues = [500, 1000, 2000, 5000, 10000];

  void toggleDropdown() {
    dropdownOpen.value = !dropdownOpen.value;
  }

  void selectDropdown(int value) {
    selectedDropdownValue.value = value;
    updateAmount(value.toDouble());
    dropdownOpen.value = false;
  }

  void updateAmount(double value) {
    selectedAmount.value = value;
    amountCtrl.text = value.toInt().toString();
    selectedChipIndex.value = -1;
  }

  void selectChip(int index, double value) {
    selectedChipIndex.value = index;
    updateAmount(value);
  }

  void onAmountTyped(String v) {
    selectedChipIndex.value = -1;
    selectedAmount.value = double.tryParse(v) ?? 0;
  }

  // Ratings
  var ratingMap = <int, int>{}.obs;

  void setRating(int bookingIndex, int rating) {
    ratingMap[bookingIndex] = rating;
    update();
  }

  Future<void> cancelBooking(String bookingCode) async {
    isLoading.value = true;

    try {
      final resp = await repo.cancelBooking(bookingCode);

      if (resp.data["success"] == true) {
        successToast("Booking cancelled successfully");

        // re-fetch history
        fetchBookingHistory();
      } else {
        errorToast("Failed to cancel booking");
      }
    } catch (e) {
      errorToast("Error: $e");
    }

    isLoading.value = false;
  }

  // EDIT
  Future<void> editBooking(Map booking) async {
    /// Navigate to BookSlotView with booking details but EMPTY selections
    Get.toNamed(
      Routes.featureslist,
      arguments: {
        "is_edit": true,
        "booking_code": booking["booking_code"],
        "vehicle": booking["vehicle"],
        "service_id": booking["service_id"],
        "service_name": booking["service_name"],
        "slot_id": booking["slot_id"],
      },
    );
  }
}
