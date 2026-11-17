import 'package:get/get.dart';
import 'dart:convert';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/models/booking slot/services_model.dart';
import 'package:car_wash_customer_app/app/models/booking slot/slot_dates_model.dart';
import 'package:car_wash_customer_app/app/models/booking slot/slot_times_model.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/models/offers/offer_coupon_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:car_wash_customer_app/app/repositories/offers/offer_coupon_repository.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';

class BookSlotController extends GetxController {
  final BookSlotRepository repository = BookSlotRepository();

  bool isEditMode = false;
  String editBookingCode = "";

  final RxString couponCodeInput = ''.obs;
  //-----------------------
  // REACTIVE VARIABLES
  //-----------------------
  final customerVehicles = <dynamic>[].obs;

  final selectedDate = Rx<DateTime?>(null);
  final selectedTimeSlot = Rx<String?>(null);

  /// 24-hour start time (e.g. "09:00") used to build `scheduled_at`.
  /// The 12-hour label stored in [selectedTimeSlot] is display-only.
  String selectedSlotTime24h = "";

  final selectedVehicle = Rx<String?>(null);
  final selectedAddress = Rx<String?>("Home");

  // Location variables
  final savedLocations = <SavedLocation>[].obs;
  final Rx<SavedLocation?> selectedSavedLocation = Rx<SavedLocation?>(null);

  int? selectedDateId;
  final selectedSlotId = 0.obs;

  final slotDates = <SlotDate>[].obs;
  final slotTimes = <TimeslotDatum>[].obs;

  final isLoadingDates = false.obs;
  final isLoadingTimes = false.obs;
  final isCheckingServiceability = false.obs;
  final isServiceable = false.obs;
  final serviceabilityMessage = ''.obs;
  final selectedPincode = ''.obs;

  /// City resolved by the availability check (`Jeddah`, `Riyadh`, …).
  /// Sent to `payment/create`, otherwise the backend re-checks with the
  /// pincode only and loses the city-level fallback that matched here.
  final serviceAreaCity = ''.obs;
  final serviceAreaMatch = ''.obs;

  /// Service ZONE (map area) of the selected address.
  ///
  /// Slots are per area: `09:00-10:00` in "al rimal" and in "ol alaya" are two
  /// different rows with their own capacity, so the date and time pickers may
  /// only be filled AFTER the address is known and its area resolved.
  final serviceAreaId = ''.obs;
  final serviceAreaName = ''.obs;

  /// True once the address resolved to an area -> the pickers may be shown.
  bool get hasServiceArea => serviceAreaId.value.isNotEmpty;

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
  late String serviceId;
  late List<String> features;
  late String image;

  /// Price breakdown, produced by the backend (services payload). The app never
  /// computes VAT itself, so these stay reactive: they are refreshed from the
  /// API every time the screen opens (see [refreshPricing]).
  final price = ''.obs;
  final vatPercentage = 0.0.obs;
  final vatAmount = 0.0.obs;
  final totalAmountValue = 0.0.obs;

  //-----------------------
  // COUPONS (offers)
  //-----------------------
  final OfferCouponRepository couponRepository = OfferCouponRepository();

  /// Coupons the backend says are usable for the selected service + slot.
  final availableCoupons = <OfferCouponModel>[].obs;
  final isLoadingCoupons = false.obs;

  /// The coupon the customer applied (null = none).
  final appliedCoupon = Rx<OfferCouponModel?>(null);

  /// Price split returned by `offers/coupons/validate` once a coupon is applied.
  final couponBreakdown = Rx<CouponPriceBreakdown?>(null);

  bool get hasCouponApplied =>
      appliedCoupon.value != null && couponBreakdown.value != null;

  String get appliedCouponCode => appliedCoupon.value?.code ?? '';

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get canConfirmBooking {
    return (selectedVehicle.value ?? '').isNotEmpty &&
        (selectedTimeSlot.value ?? '').isNotEmpty &&
        selectedSlotId.value != 0 &&
        selectedSavedLocation.value != null &&
        isServiceable.value &&
        !isCheckingServiceability.value;
  }

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
      selectedSlotTime24h = "";

      print("🟦 EDIT MODE ENABLED for $editBookingCode");
    }

    image = data["image"] ?? "";
    name = data["name"] ?? "";
    description = data["description"] ?? "";
    price.value = data["price"].toString();
    serviceId = (data["service_id"] ?? data["id"] ?? "").toString();
    features = List<String>.from(data["features"] ?? []);

    // VAT breakdown comes from the backend; missing values mean "no extra tax".
    final double parsedPrice = double.tryParse(price.value) ?? 0.0;
    vatPercentage.value = _toDouble(data["vat_percentage"]);
    vatAmount.value = _toDouble(data["vat_amount"]);
    totalAmountValue.value = _toDouble(
      data["total_amount"],
      fallback: parsedPrice + vatAmount.value,
    );

    initData();
    refreshPricing();
    loadSavedLocations(); // Load locations from storage
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  /// Re-reads the price breakdown (price, VAT rate/amount and total) from the
  /// backend whenever this screen opens.
  ///
  /// The breakdown reaches this screen through the route arguments, which are a
  /// snapshot of the service list the home screen loaded. That list is only
  /// reloaded on pull-to-refresh, so a VAT change made on the backend kept
  /// showing the previous rate on every later visit. Fetching the service again
  /// here keeps both this screen and the home screen cache truthful.
  Future<void> refreshPricing() async {
    if (serviceId.isEmpty) return;

    try {
      final response = await repository.fetchAllServices();
      final data = response.data;
      if (data is! List) return;

      final services = data
          .map(
            (e) => Servicesmodel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      // Hand the fresh list back to the home screen so it stops showing the
      // stale prices/VAT as well (no manual pull-to-refresh needed).
      if (Get.isRegistered<FeaturesListController>()) {
        Get.find<FeaturesListController>().applyServices(services);
      }

      final match = services.firstWhereOrNull((s) => s.id == serviceId);
      if (match == null) return;

      price.value = match.price.toString();
      vatPercentage.value = match.vatPercentage;
      vatAmount.value = match.vatAmount;
      totalAmountValue.value = match.totalAmount;

      print("💰 Pricing refreshed → VAT ${match.vatPercentage}%");
    } catch (e) {
      print("❌ Failed to refresh pricing: $e");
    }
  }

  Future<void> initData() async {
    await loadCustomerInfo();
    await fetchCustomerVehicles();
    // Dates are per area: nothing to load until an address is selected.
    // (The address section appears first on the screen and calls
    // `refreshServiceabilityForSelectedLocation` -> `fetchSlotDates`.)
    if (hasServiceArea) {
      await fetchSlotDates();
    }
  }

  //-----------------------
  // LOAD SAVED USER DATA
  //-----------------------
  Future<void> loadCustomerInfo() async {
    customerUuid = await SharedPrefsHelper.getString("customerUuid");
    customerName = await SharedPrefsHelper.getString("customerName");
    customerPhone = await SharedPrefsHelper.getString("customerPhone");

    print("UUID Loaded: $customerUuid");
  }

  //-----------------------
  // DATE SELECTION
  //-----------------------
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
    selectedTimeSlot.value = null;
    selectedSlotId.value = 0;
    selectedSlotTime24h = "";

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
  void updateSelectedTimeSlot(TimeslotDatum slot) {
    selectedTimeSlot.value = slot.displayStartLabel;
    selectedSlotTime24h =
        slot.startTime.isNotEmpty ? slot.startTime : slot.time;
    selectedSlotId.value = slot.id;

    // Coupon rules can depend on the slot (day + start time), so a different
    // slot means a different set of usable coupons.
    if (hasCouponApplied) removeCoupon();
    loadAvailableCoupons();
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
  List<dynamic> _normalizeVehicleList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final list = data['data'];
      if (list is List) return list;
      if (data['vehicles'] is List) return data['vehicles'];
      if (data['customerVehicles'] is List) return data['customerVehicles'];
    }
    return [];
  }

  Future<void> fetchCustomerVehicles() async {
    try {
      if (customerUuid.isEmpty) {
        print("❌ No customer UUID found");
        return;
      }

      print("📌 Fetching vehicles for: $customerUuid");

      final resp = await ApiService.get(
        "customer-vehicles/me",
        requireAuthToken: true,
      );

      if (resp.statusCode == 200) {
        print("📥 VEHICLES RESPONSE: ${resp.data}");

        customerVehicles.value = _normalizeVehicleList(resp.data);

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
  /// Loads the dates that are open for the customer's AREA.
  ///
  /// Does nothing (and clears the picker) while the address is unknown, because
  /// a date/time slot only exists inside a service zone.
  Future<void> fetchSlotDates() async {
    final areaId = serviceAreaId.value;

    if (areaId.isEmpty) {
      slotDates.clear();
      slotTimes.clear();
      selectedDate.value = null;
      selectedDateId = null;
      isLoadingDates(false);
      return;
    }

    try {
      isLoadingDates(true);

      // The backend already drops dates with no bookable slot left (full,
      // started, or inside the 60 min lead time) *for that area*.
      final resp = await repository.apiGetslotdates(
        availableOnly: true,
        serviceAreaId: areaId,
      );
      final data = Slotsdatemodel.fromJson(resp.data);

      slotDates.value = data.data;

      // Auto-select the first day that still has slots.
      if (slotDates.isNotEmpty && selectedDateId == null) {
        updateSelectedDate(slotDates.first.date);
      }
    } catch (e) {
      print("❌ Failed to load dates: $e");
      slotDates.clear();
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

      final resp = await repository.apiGettimeslots(
        dateId,
        availableOnly: true,
        serviceAreaId: serviceAreaId.value,
      );
      final data = Slottimesmodel.fromJson(resp.data);

      // Defensive: never show a slot that has no seat left, even if an older
      // backend version ignores `availableOnly`.
      slotTimes.value = data.data
          .where(
            (slot) =>
                slot.maxBookings <= 0 ||
                slot.currentBookings < slot.maxBookings,
          )
          .toList();
    } catch (e) {
      print("❌ Failed to load time slots: $e");
    } finally {
      isLoadingTimes(false);
    }
  }

  /// Re-loads the slots of the selected date after coming back from the payment
  /// flow, and clears the selection when the chosen time was taken meanwhile.
  Future<void> refreshSelectedDateSlots() async {
    final dateId = selectedDateId;

    if (dateId == null) return;

    final previousSlotId = selectedSlotId.value;

    await fetchTimeslots(dateId);

    final stillAvailable = slotTimes.any((slot) => slot.id == previousSlotId);

    if (!stillAvailable) {
      selectedSlotId.value = 0;
      selectedTimeSlot.value = "";
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
    if (selectedSavedLocation.value == null) {
      errorToast("please_select_a_location_msg".tr);
      return;
    }
    if (isCheckingServiceability.value) {
      errorToast("checking_service_availability".tr);
      return;
    }
    if (!isServiceable.value) {
      errorToast("service_not_available_in_area".tr);
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

      // The stored booking amount must equal what the customer was actually
      // charged (service price + VAT). The cancellation refund reverses
      // `booking.amount * 100` cents, so sending the bare service price here
      // overwrote 70.80 with 60.00 and the refund no longer matched the
      // Paymob payment.
      final updateBody = {
        "vehicle": selectedVehicle.value,
        "service_id": serviceId,
        "service_name": name,
        "amount": totalAmount,
        "slot_id": selectedSlotId.value,
        "scheduled_at": buildScheduledAt(),
      };

      print("📤 UPDATE BOOKING BODY → $updateBody");

      try {
        final resp = await repository.updateBooking(
          editBookingCode,
          updateBody,
        );

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
      } on DioException catch (e) {
        // 409 = the backend locked this booking (a technician is already
        // assigned, or it is completed/cancelled). Show its reason instead of
        // a generic failure.
        final data = e.response?.data;
        final message = data is Map ? data["message"]?.toString() : null;
        errorToast(message ?? "failed_to_update_booking".tr);
        Get.back();
      } catch (e) {
        print("❌ Update booking error: $e");
        errorToast("failed_to_update_booking".tr);
      }

      return; // IMPORTANT
    }

    print("✅ VALIDATION PASSED — Building body…");

    final double priceNumber = double.tryParse(price.value) ?? 0.0;

    final location = selectedSavedLocation.value;

    // The name is captured on the address screen (there is no signup form), which
    // runs AFTER this controller loaded its copy. Re-read it so the booking and
    // the technician app get the real name instead of an empty string.
    final latestName = (await SharedPrefsHelper.getString(
      "customerName",
    ))
        .trim();
    if (latestName.isNotEmpty) {
      customerName = latestName;
    }

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
      "latitude": location?.latitude,
      "longitude": location?.longitude,
      "formatted_address": location?.address,
      "address": location?.address,
      "house_number": location?.houseNo,
      "landmark": location?.landmark,
      "address_label": location?.label,
    };

    print("📤 FINAL BOOKING BODY → $body");
    print("📤 PAYMENT DATA → $body");

    Get.toNamed(
      Routes.payment,
      arguments: {
        "customer_id": customerUuid,
        "customer_name": customerName,
        "vehicle": selectedVehicle.value,
        "service_id": serviceId,
        "service_name": name,
        "slot_id": selectedSlotId.value,
        "scheduled_at": buildScheduledAt(),
        "amount": totalAmount,
        // Offer coupon (empty when none was applied). The backend re-validates
        // it and recomputes the amount, so this is only a hint for the pay
        // screen — never the source of truth.
        "coupon_code": appliedCouponCode,
        "discount_amount": couponDiscountAmount,
        // Price breakdown so the payment screen shows the same VAT the
        // backend charged (instead of a hardcoded 0%).
        "price": servicePrice,
        "vat_percentage": vatPercentage.value,
        "vat_amount": displayVatAmount,
        "latitude": location?.latitude,
        "longitude": location?.longitude,
        "formatted_address": location?.address,
        "address": location?.address,
        "house_number": location?.houseNo,
        "landmark": location?.landmark,
        "address_label": location?.label,
        "pincode": selectedPincode.value,
        "city": serviceAreaCity.value,
        "image": image,
      },
    );
    // try {
    //   final resp = await repository.postBookSlot(body);

    //   print("📥 BOOKING RESPONSE: ${resp.data}");

    //   if (resp.data["success"] == true) {
    //     //successToast("Booking Created!");

    //     final bookingId = resp.data["data"]["id"];

    //     final bookingCode = resp.data["data"]["booking_code"];
    //     print("📤 PAYMENT DATA → $body");

    //     Get.toNamed(
    //       Routes.payment,
    //       arguments: {
    //         // Backend/payment data
    //         "customer_id": customerUuid,
    //         "customer_name": customerName,
    //         "vehicle": selectedVehicle.value,
    //         "service_id": serviceId,
    //         "service_name": name,
    //         "slot_id": selectedSlotId.value,
    //         "scheduled_at": buildScheduledAt(),
    //         "amount": totalAmount,

    //         // Location
    //         "latitude": location?.latitude,
    //         "longitude": location?.longitude,
    //         "formatted_address": location?.address,
    //         "address": location?.address,
    //         "house_number": location?.houseNo,
    //         "landmark": location?.landmark,
    //         "address_label": location?.label,

    //         // UI
    //         "image": image,
    //       },
    //     );

    //     /// Navigate to payment
    //     ///
    //     // Get.toNamed(
    //     //   Routes.payment,
    //     //   arguments: {
    //     //     "bookingId": bookingId,
    //     //     "amount": totalAmount,

    //     //     /// Needed for confirmation page
    //     //     "service_name": name,
    //     //     "scheduled_at": buildScheduledAt(),
    //     //     "image": image,
    //     //     "booking_code": bookingCode,
    //     //   },
    //     // );
    //   } else {
    //     print("❌ BOOKING FAILED FROM API");
    //     errorToast(resp.data["error"] ?? "booking_failed".tr);
    //   }
    // } catch (e) {
    //   print("🔥 EXCEPTION IN API: $e");
    //   errorToast("booking_failed_try_again".tr);
    // }
  }

  //-----------------------
  // ADDRESS
  //-----------------------
  void updateSelectedAddress(SavedLocation location) {
    selectedSavedLocation.value = location;
    selectedAddress.value = location.label;
    refreshServiceabilityForSelectedLocation();
  }

  Future<String?> _resolvePincodeForLocation(SavedLocation location) async {
    final existingPincode = (location.pincode ?? '').trim();
    if (existingPincode.isNotEmpty) {
      return existingPincode;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final resolvedPincode = placemarks.first.postalCode?.trim();
      if (resolvedPincode == null || resolvedPincode.isEmpty) {
        return null;
      }

      final updatedLocation = location.copyWith(pincode: resolvedPincode);
      final index = savedLocations.indexWhere((item) => item.id == location.id);
      if (index != -1) {
        savedLocations[index] = updatedLocation;
        _saveSavedLocations();
      }
      selectedSavedLocation.value = updatedLocation;
      return resolvedPincode;
    } catch (e) {
      print('Error resolving pincode for selected location: $e');
      return null;
    }
  }

  /// Verifies serviceability using the saved location's map pin.
  ///
  /// Saudi postal codes are exactly 5 digits. When the geocoder cannot resolve
  /// one, the coordinates are still sent so the backend can reverse-geocode.
  Future<void> checkServiceability(
    String pincode, {
    double? latitude,
    double? longitude,
  }) async {
    final normalized = pincode.replaceAll(RegExp(r'[^0-9]'), '');
    final hasValidPincode = RegExp(r'^\d{5}$').hasMatch(normalized);
    final hasCoordinates = latitude != null && longitude != null;

    if (!hasValidPincode && !hasCoordinates) {
      selectedPincode.value = '';
      serviceAreaCity.value = '';
      serviceAreaMatch.value = '';
      isServiceable.value = false;
      isCheckingServiceability.value = false;
      serviceabilityMessage.value = 'unable_to_determine_postal'.tr;
      await _applyServiceArea('', '');
      return;
    }

    selectedPincode.value = hasValidPincode ? normalized : '';
    isCheckingServiceability.value = true;
    isServiceable.value = false;
    serviceabilityMessage.value = 'checking_service_availability_short'.tr;

    try {
      final response = await repository.checkCustomerServiceability(
        hasValidPincode ? normalized : null,
        latitude: latitude,
        longitude: longitude,
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};

      if (data['success'] == true && data['serviceable'] == true) {
        isServiceable.value = true;
        final responsePincode = (data['pincode'] ?? '').toString().trim();
        if (responsePincode.isNotEmpty) {
          selectedPincode.value = responsePincode;
        }
        serviceAreaCity.value = (data['city'] ?? '').toString().trim();
        serviceAreaMatch.value = (data['match'] ?? '').toString().trim();
        print(
          '✅ Serviceable → match: ${data['match']}, source: ${data['pincode_source']}, pincode: ${data['pincode']}, city: ${data['city']}, zone: ${data['zone_id']}',
        );
        serviceabilityMessage.value = 'service_available_in_area'.tr;

        // Per-area slots: switch the pickers to this area's dates/slots.
        await _applyServiceArea(
          (data['zone_id'] ?? '').toString(),
          (data['zone_name'] ?? '').toString(),
        );
        return;
      }

      isServiceable.value = false;
      serviceAreaCity.value = '';
      serviceAreaMatch.value = '';
      serviceabilityMessage.value =
          data['message']?.toString() ?? 'service_not_available_in_area'.tr;
      await _applyServiceArea('', '');
    } catch (e) {
      isServiceable.value = false;
      serviceAreaCity.value = '';
      serviceAreaMatch.value = '';
      serviceabilityMessage.value = 'unable_to_verify_service'.tr;
      await _applyServiceArea('', '');
      print('Serviceability check failed: $e');
    } finally {
      isCheckingServiceability.value = false;
    }
  }

  /// Stores the area of the selected address and reloads the pickers when it
  /// changed (a slot from another area can never be booked).
  Future<void> _applyServiceArea(String id, String name) async {
    final previous = serviceAreaId.value;
    final next = id.trim();

    serviceAreaId.value = next;
    serviceAreaName.value = name.trim();

    if (previous == next) return;

    // Different area -> the chosen date/time belongs to another pool.
    selectedDate.value = null;
    selectedTimeSlot.value = null;
    selectedSlotId.value = 0;
    selectedSlotTime24h = '';
    selectedDateId = null;
    slotTimes.clear();

    await fetchSlotDates();
  }

  Future<void> refreshServiceabilityForSelectedLocation() async {
    final location = selectedSavedLocation.value;
    if (location == null) {
      selectedPincode.value = '';
      isServiceable.value = false;
      isCheckingServiceability.value = false;
      serviceabilityMessage.value = 'please_select_a_location_msg'.tr;
      await _applyServiceArea('', '');
      return;
    }

    // The saved pincode is only a hint — the map pin is always forwarded so
    // the backend can resolve the real code (geocoder results are unreliable).
    final resolved = await _resolvePincodeForLocation(location);

    await checkServiceability(
      resolved ?? '',
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  String buildScheduledAt() {
    final date = selectedDate.value;
    final time = selectedSlotTime24h;

    if (date == null || time.isEmpty) return "";

    final parts = time.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    // Create LOCAL datetime
    final local = DateTime(date.year, date.month, date.day, hour, minute);

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

  // Price breakdown: every value comes from the backend.
  double get servicePrice {
    return double.tryParse(price.value) ?? 0.0;
  }

  /// Money taken off by the applied coupon (0 when none).
  double get couponDiscountAmount {
    return couponBreakdown.value?.discountAmount ?? 0.0;
  }

  /// VAT to display: recomputed by the backend when a coupon is applied.
  double get displayVatAmount {
    return couponBreakdown.value?.vatAmount ?? vatAmount.value;
  }

  /// Price VAT is computed on (service price - coupon discount).
  double get taxableAmount {
    return couponBreakdown.value?.taxableAmount ?? servicePrice;
  }

  /// VAT rate in percent (e.g. 15), as configured on the backend.
  String get vatPercentLabel {
    return vatPercentage.value % 1 == 0
        ? vatPercentage.value.toStringAsFixed(0)
        : vatPercentage.value.toStringAsFixed(2);
  }

  /// Total as sent to `payment/create`: the discounted total when a coupon is
  /// applied, otherwise service price + VAT from the backend.
  double get totalAmount {
    final discounted = couponBreakdown.value?.totalAmount;
    if (discounted != null) return discounted;

    return totalAmountValue.value > 0 ? totalAmountValue.value : servicePrice;
  }

  // ===== COUPONS (offers) =====

  /// Asks the backend which coupons can be used for the selected service+slot.
  Future<void> loadAvailableCoupons() async {
    if (serviceId.isEmpty || selectedSlotId.value == 0) {
      availableCoupons.clear();
      return;
    }

    try {
      isLoadingCoupons.value = true;

      final response = await couponRepository.getAvailableCoupons(
        serviceId: serviceId,
        slotId: selectedSlotId.value,
      );

      final data = response.data;
      final list = data is Map ? data['coupons'] : data;

      if (list is List) {
        availableCoupons.assignAll(
          list
              .whereType<Map>()
              .map(
                (item) =>
                    OfferCouponModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((coupon) => coupon.code.isNotEmpty)
              .toList(),
        );
      } else {
        availableCoupons.clear();
      }

      print("🎟️ Available coupons: ${availableCoupons.length}");
    } catch (e) {
      availableCoupons.clear();
      print("❌ Failed to load coupons: $e");
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  /// Validates the coupon on the backend and stores the resulting breakdown.
  /// Returns the error message to show, or null on success.
  Future<String?> applyCoupon(OfferCouponModel coupon) async {
    try {
      final response = await couponRepository.validateCoupon(
        code: coupon.code,
        serviceId: serviceId,
        slotId: selectedSlotId.value,
      );

      final data = response.data;
      final breakdown = data is Map ? data['breakdown'] : null;

      if (breakdown is! Map) {
        return "coupon_not_valid".tr;
      }

      appliedCoupon.value = coupon;
      couponBreakdown.value = CouponPriceBreakdown.fromJson(
        Map<String, dynamic>.from(breakdown),
      );

      print(
        "🎟️ Coupon ${coupon.code} applied: -$couponDiscountAmount → $totalAmount",
      );

      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message']?.toString() : null;
      return (message != null && message.isNotEmpty)
          ? message
          : "coupon_not_valid".tr;
    } catch (e) {
      print("❌ Apply coupon error: $e");
      return "coupon_not_valid".tr;
    }
  }

  /// Removes the applied coupon and goes back to the normal price.
  void removeCoupon() {
    appliedCoupon.value = null;
    couponBreakdown.value = null;
  }

  // ===== LOCATION MANAGEMENT =====

  /// Add a saved location
  Future<void> addSavedLocation(SavedLocation location) async {
    savedLocations.add(location);

    // Select the newly added location
    selectedAddress.value = location.label;
    selectedSavedLocation.value = location;
    refreshServiceabilityForSelectedLocation();

    // Persist to storage (awaited so the caller can show a loader until the
    // address is really written).
    await _saveSavedLocations();

    print('✅ Location saved: ${location.label} - ${location.address}');
  }

  /// Update an existing saved location
  Future<void> updateSavedLocation(
    SavedLocation oldLocation,
    SavedLocation newLocation,
  ) async {
    int index = savedLocations.indexWhere((loc) => loc.id == oldLocation.id);

    if (index != -1) {
      savedLocations[index] = newLocation;

      // Select the updated location
      selectedAddress.value = newLocation.label;
      selectedSavedLocation.value = newLocation;
      refreshServiceabilityForSelectedLocation();

      // Persist to storage (awaited so the caller can show a loader until the
      // address is really written).
      await _saveSavedLocations();

      print(
        '✏️ Location updated: ${newLocation.label} - ${newLocation.address}',
      );
    }
  }

  /// Deletes a saved address and keeps the current selection valid.
  ///
  /// Used by the 3-dot menu on both the Addresses screen and the
  /// "Confirm Car Wash" screen.
  Future<void> removeSavedLocation(SavedLocation location) async {
    final wasSelected = selectedSavedLocation.value?.id == location.id ||
        selectedAddress.value == location.label;

    savedLocations.removeWhere((item) => item.id == location.id);

    if (wasSelected) {
      final next = savedLocations.isNotEmpty ? savedLocations.first : null;
      selectedSavedLocation.value = next;
      selectedAddress.value = next?.label;

      // Clears the area/slot pickers, or asks the customer to pick an address
      // when nothing is saved anymore.
      await refreshServiceabilityForSelectedLocation();
    }

    await saveSavedLocations();
  }

  /// Load saved locations from SharedPreferences
  Future<void> loadSavedLocations() async {
    try {
      String? locationsJson = await SharedPrefsHelper.getString(
        "savedLocations",
      );
      if (locationsJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(locationsJson);
        savedLocations.value = jsonList
            .map((json) => SavedLocation.fromJson(json as Map<String, dynamic>))
            .toList();
        if (savedLocations.isNotEmpty) {
          selectedSavedLocation.value = savedLocations.first;
          selectedAddress.value = savedLocations.first.label;
          refreshServiceabilityForSelectedLocation();
        }
        print(
          '📍 Loaded ${savedLocations.length} saved locations from storage',
        );
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
      print("Location picker error: $e");
      errorToast('error_selecting_location'.tr);
    }
  }

  /// Add a new location to saved locations
  void addLocation(
    String address,
    double latitude,
    double longitude, {
    String? pincode,
  }) {
    final location = SavedLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'other'.tr,
      address: address,
      latitude: latitude,
      longitude: longitude,
      houseNo: '',
      phoneNumber: '',
      pincode: pincode,
    );

    addSavedLocation(location);
  }

  /// Update selected location
  void updateSelectedLocation(
    String address,
    double latitude,
    double longitude,
  ) {
    final location = SavedLocation(
      id: "",
      label: "",
      address: address,
      latitude: latitude,
      longitude: longitude,
      houseNo: "",
      phoneNumber: "",
    );

    selectedSavedLocation.value = location;
    selectedAddress.value = address;
    refreshServiceabilityForSelectedLocation();
    print('📍 Selected location: $address ($latitude, $longitude)');
  }

  /// Get saved locations for display
  List<Map<String, dynamic>> getDisplayLocations() {
    // Default locations
    List<Map<String, dynamic>> locations = [];

    // Add saved locations
    locations.addAll(
      savedLocations
          .map(
            (loc) => {
              'title': loc.label,
              'address': loc.address,
              'icon': 'location',
              'latitude': loc.latitude,
              'longitude': loc.longitude,
              'houseNo': loc.houseNo,
              'landmark': loc.landmark,
              'phoneNumber': loc.phoneNumber,
            },
          )
          .toList(),
    );

    return locations;
  }
}
