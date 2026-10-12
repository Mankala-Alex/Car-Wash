import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offers_controller.dart';
import 'package:car_wash_customer_app/app/helpers/secure_store.dart';
import 'package:car_wash_customer_app/app/models/advertisement/advertisement_model.dart';
import 'package:car_wash_customer_app/app/repositories/advertisment/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/models/booking slot/booking_history_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/auth_repository.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:car_wash_customer_app/app/repositories/customers/customer_repository.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/socket_service.dart';
import 'package:car_wash_customer_app/app/models/reviews/review_model.dart';

class DashboardController extends GetxController {
  //for demo purpose only
  //Timer? _refreshTimer;
  // this is just for demo purpose for auto refreshing
  // void _startAutoRefresh() {
  //   _refreshTimer?.cancel();

  //   _refreshTimer = Timer.periodic(
  //     const Duration(seconds: 5), // 👈 demo-friendly
  //     (timer) {
  //       if (customerUuid.isNotEmpty) {
  //         fetchBookingHistory();
  //       }
  //     },
  //   );
  // }
  // this is just for demo purpose for auto refreshing
  final OffersController offersController = Get.find<OffersController>();
  final FeaturesListController featuresController =
      Get.find<FeaturesListController>();

  final AdvertisementRepository advertisementRepository =
      AdvertisementRepository();

  RxList<AdvertisementModel> advertisements = <AdvertisementModel>[].obs;

  RxBool isAdvertisementsLoading = false.obs;

  Future<void> refreshHomeData() async {
    try {
      await Future.wait([
        featuresController.getAllServices(),
        offersController.fetchOffers(),
        fetchBookingHistory(),
        fetchAdvertisements(),
      ]);

      print("✅ Home page refreshed successfully");
    } catch (e) {
      print("❌ Error refreshing home page: $e");
    }
  }

  Future<void> fetchAdvertisements() async {
    try {
      isAdvertisementsLoading.value = true;

      final response = await advertisementRepository.getAdvertisements();

      final data = response.data;

      if (data is List) {
        final List<AdvertisementModel> loadedAdvertisements = data
            .map(
              (item) => AdvertisementModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((ad) => ad.status.toLowerCase() == 'active')
            .toList();

        loadedAdvertisements.sort(
          (a, b) => a.displayOrder.compareTo(b.displayOrder),
        );

        advertisements.assignAll(loadedAdvertisements);

        print(
          "✅ Advertisements loaded: ${advertisements.length}",
        );
      } else {
        advertisements.clear();

        print("⚠️ Advertisement API returned unexpected data");
      }
    } catch (e) {
      advertisements.clear();

      print("❌ Advertisement error: $e");
    } finally {
      isAdvertisementsLoading.value = false;
    }
  }

  var selectedIndex = 0.obs;
  final repo = BookSlotRepository();

  final AuthRepository _authRepo = AuthRepository();

  var isLoading = false.obs;

  Rx<Datum?> trackingBooking = Rx<Datum?>(null);

  RxString customerName = ''.obs;
  RxString customerEmail = ''.obs;
  RxString customerPhone = ''.obs;

  // BOOKINGS
  RxList<Datum> currentBookings = <Datum>[].obs;
  RxList<Datum> pastBookings = <Datum>[].obs;

  /// UUID (no numeric ID anymore)
  String customerUuid = "";

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      isLoading.value = true;

      await loadCustomerInfo();

      // Always try to refresh customer details from server when UUID present
      if (customerUuid.isNotEmpty) {
        await fetchCustomerDetails();
      }

      await fetchAdvertisements();

      final arg = Get.arguments;

      if (arg != null && arg is int) {
        selectedIndex.value = arg;
      }

      if (customerUuid.isNotEmpty) {
        await _setupSocketConnection();
        _setupSocketListeners();

        // If directly opened My Bookings tab
        if (selectedIndex.value == 1) {
          await fetchBookingHistory();
        }
      }
    } catch (e) {
      print("❌ Dashboard init error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   _initializeController();
  //   final arg = Get.arguments;
  //   if (arg != null && arg is int) {
  //     selectedIndex.value = arg;
  //     print("🔥 Setting selectedIndex from arguments → $arg");
  //   }
  // }

  // // Initialize controller with proper async handling
  // Future<void> _initializeController() async {
  //   try {
  //     isLoading.value = true;

  //     await loadCustomerInfo();
  //     if (customerUuid.isNotEmpty) {
  //       // Don't fetch booking history here.
  //       // It will be fetched only when user opens Page2 (My Bookings).

  //       await _setupSocketConnection();
  //       _setupSocketListeners();
  //     }
  //     // if (customerUuid.isNotEmpty) {
  //     //   await fetchBookingHistory();
  //     //   // Connect socket and set up listeners
  //     //   _setupSocketConnection();
  //     //   _setupSocketListeners();
  //     //   // this is just for demo purpose for auto refreshing
  //     //   _startAutoRefresh();
  //     //   // this is just for demo purpose for auto refreshing
  //     // }
  //   } catch (e) {
  //     print("❌ Dashboard init error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
    customerPhone.value =
        await SharedPrefsHelper.getString("customerPhone") ?? "";

    print("UUID = $customerUuid");
  }

  final CustomerRepository _customerRepo = CustomerRepository();

  Future<void> fetchCustomerDetails() async {
    if (customerUuid.isEmpty) return;

    try {
      isLoading.value = true;

      final resp = await _customerRepo.getCustomer(customerUuid);

      final data = resp.data;

      if (data != null && data is Map<String, dynamic>) {
        final first = (data['firstName'] ?? '') as String;
        final last = (data['lastName'] ?? '') as String;
        final fullName = ("${first.trim()} ${last.trim()}".trim());

        if (fullName.isNotEmpty) customerName.value = fullName;
        if ((data['email'] ?? '').toString().isNotEmpty) {
          customerEmail.value = data['email'];
        }
        if ((data['mobile'] ?? '').toString().isNotEmpty) {
          customerPhone.value = data['mobile'];
        }

        // Persist for later launches
        await SharedPrefsHelper.setString("customerName", customerName.value);
        await SharedPrefsHelper.setString("customerEmail", customerEmail.value);
        await SharedPrefsHelper.setString("customerPhone", customerPhone.value);
      }
    } catch (e) {
      print("❌ fetchCustomerDetails error: $e");
    } finally {
      isLoading.value = false;
    }
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
      splitBookings(model.bookings);
      await loadReviewsForCompletedBookings();
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

    for (final booking in pastBookings) {
      if (booking.id.isNotEmpty &&
          !reviewsByBookingId.containsKey(booking.id)) {
        reviewsByBookingId.remove(booking.id);
      }
    }

    print("trackingBooking = ${trackingBooking.value?.status}");
  }

  // -----------------------------------------------------
  // BOTTOM NAVIGATION
  // -----------------------------------------------------
  Future<void> updateIndex(int index) async {
    selectedIndex.value = index;

    // Page2 = My Bookings tab
    if (index == 1) {
      await fetchBookingHistory();
    }
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

  // Reviews keyed by booking ID; this is the source of truth after the API has been checked.
  final RxMap<String, ReviewModel?> reviewsByBookingId =
      <String, ReviewModel?>{}.obs;

  bool isBookingReviewed(String bookingId) {
    final review = reviewsByBookingId[bookingId];
    return review != null && review.id.isNotEmpty;
  }

  double getBookingReviewRating(String bookingId) {
    final review = reviewsByBookingId[bookingId];
    return review?.rating.toDouble() ?? 0.0;
  }

  Future<void> loadReviewForBooking(String bookingId) async {
    if (bookingId.trim().isEmpty) return;

    try {
      final response = await repo.getReviewByBooking(bookingId);
      final data = response.data;
      final review = ReviewModel.fromResponse(data);

      if (review != null && review.id.isNotEmpty) {
        reviewsByBookingId[bookingId] = review;
      } else {
        reviewsByBookingId.remove(bookingId);
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 400) {
        reviewsByBookingId.remove(bookingId);
        return;
      }

      if (code == 401 || code == 403) {
        reviewsByBookingId.remove(bookingId);
        errorToast('Please login again to continue');
        return;
      }

      reviewsByBookingId.remove(bookingId);
    } catch (e) {
      reviewsByBookingId.remove(bookingId);
    }
  }

  Future<void> loadReviewsForCompletedBookings() async {
    if (pastBookings.isEmpty) return;

    for (final booking in pastBookings) {
      if (booking.id.trim().isNotEmpty) {
        await loadReviewForBooking(booking.id);
      }
    }
  }

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    if (bookingId.trim().isEmpty) {
      errorToast('Invalid booking');
      return;
    }

    if (rating < 1 || rating > 5) {
      errorToast('Please select a rating between 1 and 5 stars');
      return;
    }

    try {
      final response = await repo.createReview({
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      });

      final review = ReviewModel.fromResponse(response.data);
      if (review != null) {
        reviewsByBookingId[bookingId] = review;
        successToast('Review submitted successfully');
        await fetchBookingHistory();
        await loadReviewForBooking(bookingId);
        update();
        return;
      }

      errorToast('Review could not be submitted');
    } on DioException catch (e) {
      final errorMessage = _extractReviewErrorMessage(e);
      if (errorMessage.isNotEmpty) {
        errorToast(errorMessage);
      } else {
        errorToast('Unable to submit review right now');
      }
    } catch (e) {
      errorToast('Unable to submit review right now');
    }
  }

  String _extractReviewErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final message = responseData['message'] ?? responseData['error'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    if (error.response?.statusCode == 401 ||
        error.response?.statusCode == 403) {
      return 'Please login again to continue';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return 'Network error. Please try again';
    }

    return '';
  }

  Future<void> cancelBooking(String bookingCode) async {
    isLoading.value = true;

    try {
      final resp = await repo.cancelBooking(bookingCode);

      if (resp.data["success"] == true) {
        successToast("booking_cancelled_successfully".tr);

        // re-fetch history
        fetchBookingHistory();
      } else {
        errorToast("failed_to_cancel_booking".tr);
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
      print("⚠️ Socket disconnect error: $e");
    }

    try {
      // 2️⃣ Call logout API
      await _authRepo.postLogout();
    } catch (e) {
      print("Logout API error: $e");
    } finally {
      // 3️⃣ Clear SharedPreferences
      await SharedPrefsHelper.clearAll();

      // 4️⃣ Clear Secure Storage  🔥 IMPORTANT
      await FlutterSecureStore().deleteAllData();

      // 5️⃣ Reset GetX
      Get.deleteAll(force: true);

      // 6️⃣ Navigate
      Get.offAllNamed(Routes.login);
    }
  }
  // Future<void> logout() async {
  //   try {
  //     // 1️⃣ Disconnect socket
  //     final socketService = Get.find<SocketService>();
  //     await socketService.disconnect();
  //   } catch (e) {
  //     // Socket disconnect failure should NOT block logout
  //     print("⚠️ Socket disconnect error: $e");
  //   }

  //   try {
  //     // 2️⃣ Call logout API
  //     await _authRepo.postLogout();
  //   } catch (e) {
  //     // API failure should NOT block logout
  //     print("Logout API error: $e");
  //   } finally {
  //     // 3️⃣ Clear local data ALWAYS
  //     await SharedPrefsHelper.clearAll();

  //     // 4️⃣ Reset GetX state
  //     Get.deleteAll(force: true);

  //     // 5️⃣ Navigate to login
  //     Get.offAllNamed(Routes.login);
  //   }
  // }
}
