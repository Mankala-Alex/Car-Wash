import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking slot/booking_history_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  // BOOKINGS
  RxList<Datum> currentBookings = <Datum>[].obs;
  RxList<Datum> pastBookings = <Datum>[].obs;

  int? customerNumericId;

  @override
  void onInit() {
    super.onInit();
    loadCustomerId();
  }

  Future<void> loadCustomerId() async {
    customerNumericId = await SharedPrefsHelper.getInt("customerNumericId");

    print("✅ Dashboard loaded numericId: $customerNumericId");

    if (customerNumericId != null && customerNumericId != 0) {
      fetchBookingHistory();
    } else {
      print("❌ No numeric customer ID – cannot load history.");
    }
  }

  Future<void> fetchBookingHistory() async {
    if (customerNumericId == null || customerNumericId == 0) return;

    try {
      final body = {"customer_id": customerNumericId};

      final resp = await BookSlotRepository().postBookingsHistory(body);

      print("📥 HISTORY RESPONSE: ${resp.data}");

      final model = Bookinghistorymodel.fromJson(resp.data);
      splitBookings(model.data);

      print("✓ Loaded booking history: ${model.data.length}");
    } catch (e) {
      print("❌ Failed to load booking history: $e");
    }
  }

  void splitBookings(List<Datum> allBookings) {
    final now = DateTime.now();

    currentBookings.value = allBookings.where((b) {
      return b.scheduledAt != null &&
          b.scheduledAt!.isAfter(now) &&
          (b.status == "Pending" ||
              b.status == "Accepted" ||
              b.status == "In-progress");
    }).toList();

    pastBookings.value = allBookings.where((b) {
      return b.scheduledAt != null && b.scheduledAt!.isBefore(now);
    }).toList();

    print("✓ Current bookings: ${currentBookings.length}");
    print("✓ Past bookings: ${pastBookings.length}");
  }

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

  // Rating for bookings
  var ratingMap = <int, int>{}.obs;

  void setRating(int bookingIndex, int rating) {
    ratingMap[bookingIndex] = rating;
    update();
  }
}

//for booking history//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_new_app/app/helpers/shared_preferences.dart';
// import 'package:my_new_app/app/models/booking%20slot/booking_history_model.dart';
// import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';

// class DashboardController extends GetxController {
//   var selectedIndex = 0.obs;
//   // BOOKINGS
//   RxList currentBookings = <Datum>[].obs;
//   RxList pastBookings = <Datum>[].obs;

//   String customerId = "";

//   @override
//   void onInit() {
//     super.onInit();
//     loadCustomerId();
//   }

//   Future<void> loadCustomerId() async {
//     customerId = await SharedPrefsHelper.getString("customerId") ?? "";
//     if (customerId.isNotEmpty) fetchBookingHistory();
//   }

//   Future<void> fetchBookingHistory() async {
//     try {
//       final body = {"customer_id": customerId};
//       final resp = await BookSlotRepository().getBookingsHistory(body);

//       final model = Bookinghistorymodel.fromJson(resp.data);
//       splitBookings(model.data);

//       print("✓ Loaded booking history: ${model.data.length}");
//     } catch (e) {
//       print("❌ Failed to load booking history: $e");
//     }
//   }

//   void splitBookings(List<Datum> allBookings) {
//     final now = DateTime.now();

//     currentBookings.value = allBookings.where((b) {
//       return b.scheduledAt != null &&
//           b.scheduledAt!.isAfter(now) &&
//           (b.status == "Pending" ||
//               b.status == "Accepted" ||
//               b.status == "In-progress");
//     }).toList();

//     pastBookings.value = allBookings.where((b) {
//       return b.scheduledAt != null && b.scheduledAt!.isBefore(now);
//     }).toList();

//     print("✓ Current bookings: ${currentBookings.length}");
//     print("✓ Past bookings: ${pastBookings.length}");
//   }

//   void updateIndex(int index) {
//     selectedIndex.value = index;
//   }

//   //wallet
//   RxDouble selectedAmount = 1000.0.obs;
//   RxInt selectedChipIndex = 1.obs;

//   TextEditingController amountCtrl = TextEditingController(text: "1000");

//   // DROPDOWN
//   RxBool dropdownOpen = false.obs;
//   RxInt selectedDropdownValue = 1000.obs;

//   List<int> dropdownValues = [500, 1000, 2000, 5000, 10000];

//   void toggleDropdown() {
//     dropdownOpen.value = !dropdownOpen.value;
//   }

//   void selectDropdown(int value) {
//     selectedDropdownValue.value = value;
//     updateAmount(value.toDouble());
//     dropdownOpen.value = false;
//   }

//   void updateAmount(double value) {
//     selectedAmount.value = value;
//     amountCtrl.text = value.toInt().toString();
//     selectedChipIndex.value = -1;
//   }

//   void selectChip(int index, double value) {
//     selectedChipIndex.value = index;
//     updateAmount(value);
//   }

//   void onAmountTyped(String v) {
//     selectedChipIndex.value = -1;
//     selectedAmount.value = double.tryParse(v) ?? 0;
//   }

//   //my bookings page

//   // For star rating (index → rating)
//   var ratingMap = <int, int>{}.obs;

//   void setRating(int bookingIndex, int rating) {
//     ratingMap[bookingIndex] = rating;
//     update();
//   }
// }
