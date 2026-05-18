import 'package:get/get.dart';
import 'dart:convert';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/models/booking slot/slot_dates_model.dart';
import 'package:car_wash_customer_app/app/models/booking slot/slot_times_model.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';

class BookSlotController extends GetxController {
  final BookSlotRepository repository = BookSlotRepository();

  bool isEditMode = false;
  String editBookingCode = "";

  //-----------------------
  // REACTIVE VARIABLES
  //-----------------------
  final customerVehicles = <dynamic>[].obs;

  final selectedDate = Rx<DateTime?>(null);
  final selectedTimeSlot = Rx<String?>(null);
  final selectedVehicle = Rx<String?>(null);
  final selectedAddress = Rx<String?>("Home");

  // Location variables
  final savedLocations = <SavedLocation>[].obs;
  RxString selectedLocationAddress = "Home".obs;
  RxDouble selectedLocationLatitude = 0.0.obs;
  RxDouble selectedLocationLongitude = 0.0.obs;

  int? selectedDateId;
  final selectedSlotId = 0.obs;

  final slotDates = <SlotDate>[].obs;
  final slotTimes = <TimeslotDatum>[].obs;

  final isLoadingDates = false.obs;
  final isLoadingTimes = false.obs;

  //-----------------------
  // CUSTOMER INFO
  //-----------------------
  String customerUuid = "";
  String customerName = "";
  String customerPhone = "";

  //-----------------------
  // SERVICE DETAILS
  //-----------------------
  late String name;
  late String description;
  late String price;
  late String serviceId;
  late List<String> features;
  late String image;

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments ?? {};
    if (data["is_edit"] == true) {
      isEditMode = true;
      editBookingCode = data["booking_code"] ?? "";

      // Force user to pick again
      selectedVehicle.value = "";
      selectedDate.value = null;
      selectedTimeSlot.value = null;
      selectedSlotId.value = 0;

      print("🟦 EDIT MODE ENABLED for $editBookingCode");
    }

    image = data["image"] ?? "";
    name = data["name"] ?? "";
    description = data["description"] ?? "";
    price = data["price"].toString();
    serviceId = data["service_id"]?.toString() ?? "";
    // ✔️ Correct field
    features = List<String>.from(data["features"] ?? []);

    initData();
    loadSavedLocations(); // Load locations from storage
  }

  Future<void> initData() async {
    await loadCustomerInfo();
    await fetchCustomerVehicles();
    await fetchSlotDates();
  }

  //-----------------------
  // LOAD SAVED USER DATA
  //-----------------------
  Future<void> loadCustomerInfo() async {
    customerUuid = await SharedPrefsHelper.getString("customerUuid") ?? "";
    customerName = await SharedPrefsHelper.getString("customerName") ?? "";
    customerPhone = await SharedPrefsHelper.getString("customerPhone") ?? "";

    print("UUID Loaded: $customerUuid");
  }

  //-----------------------
  // DATE SELECTION
  //-----------------------
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
    selectedTimeSlot.value = null;
    selectedSlotId.value = 0;

    final match = slotDates.firstWhereOrNull(
      (d) => isSameDate(d.date, newDate),
    );

    if (match != null) {
      selectedDateId = match.id;
      fetchTimeslots(match.id);
    }
  }

  //-----------------------
  // TIME SLOT SELECTION
  //-----------------------
  void updateSelectedTimeSlot(String timeLabel, int slotId) {
    selectedTimeSlot.value = timeLabel;
    selectedSlotId.value = slotId;
  }

  //-----------------------
  // VEHICLE
  //-----------------------
  void updateSelectedVehicle(String vehicleName) {
    selectedVehicle.value = vehicleName;
  }

  //-----------------------
  // FETCH VEHICLES
  //-----------------------
  Future<void> fetchCustomerVehicles() async {
    try {
      if (customerUuid.isEmpty) {
        print("❌ No customer UUID found");
        return;
      }

      print("📌 Fetching vehicles for: $customerUuid");

      final resp = await ApiService.get(
        "customer-vehicles?customer_id=$customerUuid",
        requireAuthToken: true, // ✅ REQUIRED
      );

      if (resp.statusCode == 200) {
        print("📥 VEHICLES RESPONSE: ${resp.data}");

        customerVehicles.value = List.from(resp.data);

        if (customerVehicles.isEmpty) {
          print("🚫 No vehicles found for this customer.");
        }
      }
    } catch (e) {
      print("❌ Vehicle fetch failed: $e");
    }
  }

  //-----------------------
  // FETCH DATES
  //-----------------------
  Future<void> fetchSlotDates() async {
    try {
      isLoadingDates(true);

      final resp = await repository.apiGetslotdates();
      final data = Slotsdatemodel.fromJson(resp.data);

      final today = DateTime.now();

      slotDates.value = data.data.where((d) {
        final dDate = DateTime(d.date.year, d.date.month, d.date.day);
        final tOnly = DateTime(today.year, today.month, today.day);
        return dDate.isAtSameMomentAs(tOnly) || dDate.isAfter(tOnly);
      }).toList();
    } catch (e) {
      print("❌ Failed to load dates: $e");
    } finally {
      isLoadingDates(false);
    }
  }

  //-----------------------
  // FETCH TIME SLOTS
  //-----------------------
  Future<void> fetchTimeslots(int dateId) async {
    try {
      isLoadingTimes(true);

      final resp = await repository.apiGettimeslots(dateId);
      final data = Slottimesmodel.fromJson(resp.data);

      slotTimes.value = data.data;
    } catch (e) {
      print("❌ Failed to load time slots: $e");
    } finally {
      isLoadingTimes(false);
    }
  }

  //-----------------------
  // BOOK SLOT
  //-----------------------
  Future<void> bookSlot() async {
    print("🚀 ENTERED BOOKSLOT");

    print("customerUuid = '$customerUuid'");
    print("selectedVehicle = '${selectedVehicle.value}'");
    print("selectedTimeSlot = '${selectedTimeSlot.value}'");
    print("selectedSlotId = ${selectedSlotId.value}");

    if (customerUuid.isEmpty) {
      print("❌ FAILED: Customer ID missing");
      errorToast("customer_id_missing".tr);
      return;
    }

    if ((selectedVehicle.value ?? "").isEmpty) {
      print("❌ FAILED: Vehicle not selected");
      errorToast("please_select_a_vehicle".tr);
      return;
    }

    if ((selectedTimeSlot.value ?? "").isEmpty) {
      print("❌ FAILED: Time slot not selected");
      errorToast("please_select_a_time_slot".tr);
      return;
    }

    if (selectedSlotId.value == 0) {
      print("❌ FAILED: Slot ID = 0 (invalid)");
      errorToast("invalid_slot_selected".tr);
      return;
    }
    if (isEditMode) {
      if (selectedSlotId.value == 0) {
        errorToast("please_select_a_slot".tr);
        return;
      }

      final updateBody = {
        "vehicle": selectedVehicle.value,
        "service_id": serviceId,
        "service_name": name,
        "amount": double.tryParse(price) ?? 0.0,
        "slot_id": selectedSlotId.value,
        "scheduled_at": buildScheduledAt(),
      };

      print("📤 UPDATE BOOKING BODY → $updateBody");

      final resp = await repository.updateBooking(editBookingCode, updateBody);

      if (resp.data["success"] == true) {
        successToast("booking_updated_successfully".tr);

        // GO DIRECTLY TO HISTORY PAGE (Page 2)
        Get.offAllNamed(
          Routes.dashboard,
          arguments: 1, // <-- Page2 index
        );
      } else {
        errorToast("failed_to_update_booking".tr);
      }

      return; // IMPORTANT
    }

    print("✅ VALIDATION PASSED — Building body…");

    final double priceNumber = double.tryParse(price) ?? 0.0;

    final body = {
      "customer_id": customerUuid,
      "customer_name": customerName,
      "vehicle": selectedVehicle.value,
      "service_id": serviceId,
      "service_name": name,
      "slot_id": selectedSlotId.value,
      "scheduled_at": buildScheduledAt(),
      "amount": priceNumber,
      "status": "PENDING",
    };

    print("📤 FINAL BOOKING BODY → $body");

    try {
      final resp = await repository.postBookSlot(body);

      print("📥 BOOKING RESPONSE: ${resp.data}");

      if (resp.data["success"] == true) {
        successToast("Booking Created!");

        final bookingId = resp.data["data"]["id"];

        final bookingCode = resp.data["data"]["booking_code"];

        /// Navigate to payment
        Get.toNamed(
          Routes.payment,
          arguments: {
            "bookingId": bookingId,
            "amount": totalAmount,

            /// Needed for confirmation page
            "service_name": name,
            "scheduled_at": buildScheduledAt(),
            "image": image,
            "booking_code": bookingCode,
          },
        );
      } else {
        print("❌ BOOKING FAILED FROM API");
        errorToast(resp.data["error"] ?? "booking_failed".tr);
      }
    } catch (e) {
      print("🔥 EXCEPTION IN API: $e");
      errorToast("booking_failed_try_again".tr);
    }
  }

  //-----------------------
  // ADDRESS
  //-----------------------
  void updateSelectedAddress(String title) {
    selectedAddress.value = title;
  }

  String buildScheduledAt() {
    final date = selectedDate.value;
    final time = selectedTimeSlot.value;

    if (date == null || time == null || time.isEmpty) return "";

    final parts = time.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    // Create LOCAL datetime
    final local = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Convert to UTC but KEEP same time values
    final utcFixed = DateTime.utc(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );

    // Send with Z
    return utcFixed.toIso8601String();
  }

  //staically adding the $5 forprice as VAT
  double get servicePrice {
    return double.tryParse(price) ?? 0.0;
  }

  double get vatAmount {
    return servicePrice * 0.18;
  }

  double get totalAmount {
    return servicePrice + vatAmount;
  }

  // ===== LOCATION MANAGEMENT =====

  /// Add a saved location
  void addSavedLocation(SavedLocation location) {
    savedLocations.add(location);

    // Select the newly added location
    selectedAddress.value = location.label;
    selectedLocationAddress.value = location.address;
    selectedLocationLatitude.value = location.latitude;
    selectedLocationLongitude.value = location.longitude;

    // Persist to storage
    _saveSavedLocations();

    print('✅ Location saved: ${location.label} - ${location.address}');
  }

  /// Update an existing saved location
  void updateSavedLocation(
      SavedLocation oldLocation, SavedLocation newLocation) {
    int index = savedLocations.indexWhere(
      (loc) => loc.id == oldLocation.id,
    );

    if (index != -1) {
      savedLocations[index] = newLocation;

      // Select the updated location
      selectedAddress.value = newLocation.label;
      selectedLocationAddress.value = newLocation.address;
      selectedLocationLatitude.value = newLocation.latitude;
      selectedLocationLongitude.value = newLocation.longitude;

      // Persist to storage
      _saveSavedLocations();

      print(
          '✏️ Location updated: ${newLocation.label} - ${newLocation.address}');
    }
  }

  /// Load saved locations from SharedPreferences
  Future<void> loadSavedLocations() async {
    try {
      String? locationsJson =
          await SharedPrefsHelper.getString("savedLocations");
      if (locationsJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(locationsJson);
        savedLocations.value = jsonList
            .map((json) => SavedLocation.fromJson(json as Map<String, dynamic>))
            .toList();
        print(
            '📍 Loaded ${savedLocations.length} saved locations from storage');
      }
    } catch (e) {
      print('Error loading saved locations: $e');
    }
  }

  /// Save locations to SharedPreferences
  Future<void> saveSavedLocations() async {
    try {
      final locationsJson = jsonEncode(
        savedLocations.map((loc) => loc.toJson()).toList(),
      );
      await SharedPrefsHelper.setString("savedLocations", locationsJson);
      print('💾 Saved locations to storage');
    } catch (e) {
      print('Error saving locations: $e');
    }
  }

  Future<void> _saveSavedLocations() async => saveSavedLocations();

  /// Navigate to location picker and save selected location
  Future<void> openLocationPicker() async {
    try {
      final result = await Get.toNamed(Routes.locationPicker);

      if (result != null && result is Map<String, dynamic>) {
        final latitude = result['latitude'] as double;
        final longitude = result['longitude'] as double;
        final address = result['address'] as String;

        // Save the selected location
        addLocation(address, latitude, longitude);

        successToast('location_saved'.tr);
      }
    } catch (e) {
      errorToast('error_selecting_location'.tr + ' $e');
    }
  }

  /// Add a new location to saved locations
  void addLocation(String address, double latitude, double longitude) {
    final location = SavedLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'other'.tr,
      address: address,
      latitude: latitude,
      longitude: longitude,
      houseNo: '',
      phoneNumber: '',
    );

    addSavedLocation(location);
  }

  /// Update selected location
  void updateSelectedLocation(
      String address, double latitude, double longitude) {
    selectedLocationAddress.value = address;
    selectedLocationLatitude.value = latitude;
    selectedLocationLongitude.value = longitude;
    selectedAddress.value = address;

    print('📍 Selected location: $address ($latitude, $longitude)');
  }

  /// Get saved locations for display
  List<Map<String, dynamic>> getDisplayLocations() {
    // Default locations
    List<Map<String, dynamic>> locations = [
      {
        'title': 'home'.tr,
        'address': '123 Market St, San Francisco',
        'icon': 'home',
      },
      {
        'title': 'work'.tr,
        'address': '456 Tech Ave, Silicon Valley',
        'icon': 'work',
      },
    ];

    // Add saved locations
    locations.addAll(savedLocations
        .map((loc) => {
              'title': loc.label,
              'address': loc.address,
              'icon': 'location',
              'latitude': loc.latitude,
              'longitude': loc.longitude,
              'houseNo': loc.houseNo,
              'landmark': loc.landmark,
              'phoneNumber': loc.phoneNumber,
            })
        .toList());

    return locations;
  }
}
