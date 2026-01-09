import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking slot/booking_history_model.dart';
import 'package:my_new_app/app/repositories/auth/auth_repository.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/services/socket_service.dart';

class DashboardController extends GetxController {
  //for demo purpose only
  Timer? _refreshTimer;
  // this is just for demo purpose for auto refreshing
  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5), // 👈 demo-friendly
      (timer) {
        if (customerUuid.isNotEmpty) {
          fetchBookingHistory();
        }
      },
    );
  }
  // this is just for demo purpose for auto refreshing

  var selectedIndex = 0.obs;
  final repo = BookSlotRepository();

  final AuthRepository _authRepo = AuthRepository();

  var isLoading = false.obs;

  Rx<Datum?> trackingBooking = Rx<Datum?>(null);

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
    _initializeController();
    final arg = Get.arguments;
    if (arg != null && arg is int) {
      selectedIndex.value = arg;
      print("🔥 Setting selectedIndex from arguments → $arg");
    }
  }

  // Initialize controller with proper async handling
  Future<void> _initializeController() async {
    try {
      isLoading.value = true;

      await loadCustomerInfo();

      if (customerUuid.isNotEmpty) {
        await fetchBookingHistory();
        // Connect socket and set up listeners
        _setupSocketConnection();
        _setupSocketListeners();
        // this is just for demo purpose for auto refreshing
        _startAutoRefresh();
        // this is just for demo purpose for auto refreshing
      }
    } catch (e) {
      print("❌ Dashboard init error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ===== SOCKET.IO INTEGRATION =====

  /// Setup socket connection
  Future<void> _setupSocketConnection() async {
    try {
      final socketService = Get.find<SocketService>();
      if (!socketService.isConnected) {
        await socketService.connect();
      }
    } catch (e) {
      print("❌ Socket connection error: $e");
    }
  }

  /// Setup socket event listeners
  void _setupSocketListeners() {
    try {
      final socketService = Get.find<SocketService>();

      // Listen to booking_accepted event
      ever(socketService.bookingAcceptedEvent, (data) {
        if (data != null) {
          print("📡 Socket: booking_accepted received");
          _updateBookingFromSocket(data, "ASSIGNED");
        }
      });

      // Listen to booking_arrived event
      ever(socketService.bookingArrivedEvent, (data) {
        if (data != null) {
          print("📡 Socket: booking_arrived received");
          _updateBookingFromSocket(data, "ARRIVED");
        }
      });

      // Listen to booking_started event
      ever(socketService.bookingStartedEvent, (data) {
        if (data != null) {
          print("📡 Socket: booking_started received");
          _updateBookingFromSocket(data, "IN_PROGRESS");
        }
      });

      // Listen to booking_completed event
      ever(socketService.bookingCompletedEvent, (data) {
        if (data != null) {
          print("📡 Socket: booking_completed received");
          _updateBookingFromSocket(data, "COMPLETED");
        }
      });

      print("✅ Socket listeners set up successfully");
    } catch (e) {
      print("❌ Error setting up socket listeners: $e");
    }
  }

  /// Update booking status from socket event
  /// Safely handles both payload formats
  void _updateBookingFromSocket(
    Map<String, dynamic> socketData,
    String expectedStatus,
  ) {
    try {
      // Extract booking ID from socket data
      final bookingId = socketData['id'] ?? socketData['booking_id'];
      if (bookingId == null) {
        print("⚠️ No booking ID found in socket data");
        return;
      }

      print("🔄 Updating booking: $bookingId to status: $expectedStatus");

      // Update in currentBookings
      final currentIndex = currentBookings.indexWhere(
        (booking) => booking.id == bookingId,
      );

      if (currentIndex != -1) {
        // UPDATE existing booking
        final oldBooking = currentBookings[currentIndex];
        final updatedJson = oldBooking.toJson();
        updatedJson['status'] = expectedStatus;

        if (socketData.containsKey('washer_id')) {
          updatedJson['washer_id'] = socketData['washer_id'];
        }
        if (socketData.containsKey('washer_name')) {
          updatedJson['washer_name'] = socketData['washer_name'];
        }

        final updatedBooking = Datum.fromJson(updatedJson);
        currentBookings[currentIndex] = updatedBooking;

        trackingBooking.value = updatedBooking;
      } else if (expectedStatus != "COMPLETED") {
        // 🔥 THIS IS THE MISSING PART
        final newBooking = Datum.fromJson(socketData);

        currentBookings.insert(0, newBooking);
        trackingBooking.value = newBooking;
      }

      // Check if booking should move to past bookings (COMPLETED)
      if (expectedStatus == "COMPLETED") {
        final pastIndex = pastBookings.indexWhere(
          (booking) => booking.id == bookingId,
        );

        if (pastIndex == -1 && currentIndex != -1) {
          // Move from current to past
          final booking = currentBookings.removeAt(currentIndex);
          pastBookings.add(booking);
          trackingBooking.value = null;

          print("✅ Booking moved to past bookings: $bookingId");
        }
      }
    } catch (e) {
      print("❌ Error updating booking from socket: $e");
    }
  }

  // ===== END SOCKET.IO INTEGRATION =====

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
  }

  // -----------------------------------------------------
  // FETCH BOOKING HISTORY USING UUID ONLY
  // -----------------------------------------------------
  Future<void> fetchBookingHistory() async {
    if (customerUuid.isEmpty) return;

    try {
      isLoading.value = true;

      final body = {"customer_id": customerUuid};
      final resp = await repo.postBookingsHistory(body);

      final model = Bookinghistorymodel.fromJson(resp.data);
      splitBookings(model.data);
    } catch (e) {
      print("❌ History error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------
  // SPLIT INTO CURRENT & PAST BOOKINGS
  // -----------------------------------------------------
  void splitBookings(List<Datum> allBookings) {
    // CURRENT BOOKINGS (VISIBLE LIST)
    currentBookings.value = allBookings
        .where((b) =>
            b.status == "PENDING" ||
            b.status == "ASSIGNED" ||
            b.status == "ARRIVED" ||
            b.status == "IN_PROGRESS")
        .toList();

    // TRACKING BOOKING (PRIORITY BASED)
    final trackingList = allBookings
        .where((b) =>
            b.status == "IN_PROGRESS" ||
            b.status == "ARRIVED" ||
            b.status == "ASSIGNED")
        .toList();

    trackingBooking.value = trackingList.isNotEmpty ? trackingList.first : null;

    // PAST BOOKINGS
    pastBookings.value =
        allBookings.where((b) => b.status == "COMPLETED").toList();

    print("trackingBooking = ${trackingBooking.value?.status}");
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

  Future<void> logout() async {
    try {
      // 1️⃣ Disconnect socket
      final socketService = Get.find<SocketService>();
      await socketService.disconnect();
    } catch (e) {
      // Socket disconnect failure should NOT block logout
      print("⚠️ Socket disconnect error: $e");
    }

    try {
      // 2️⃣ Call logout API
      await _authRepo.postLogout();
    } catch (e) {
      // API failure should NOT block logout
      print("Logout API error: $e");
    } finally {
      // 3️⃣ Clear local data ALWAYS
      await SharedPrefsHelper.clearAll();

      // 4️⃣ Reset GetX state
      Get.deleteAll(force: true);

      // 5️⃣ Navigate to login
      Get.offAllNamed(Routes.login);
    }
  }
}
