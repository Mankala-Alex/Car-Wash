import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking slot/slot_dates_model.dart';
import 'package:my_new_app/app/models/booking slot/slot_times_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/services/api_service.dart';

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
      errorToast("Customer ID missing");
      return;
    }

    if ((selectedVehicle.value ?? "").isEmpty) {
      print("❌ FAILED: Vehicle not selected");
      errorToast("Please select a vehicle");
      return;
    }

    if ((selectedTimeSlot.value ?? "").isEmpty) {
      print("❌ FAILED: Time slot not selected");
      errorToast("Please select a time slot");
      return;
    }

    if (selectedSlotId.value == 0) {
      print("❌ FAILED: Slot ID = 0 (invalid)");
      errorToast("Invalid slot selected");
      return;
    }
    if (isEditMode) {
      if (selectedSlotId.value == 0) {
        errorToast("Please select a slot");
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
        successToast("Booking Updated Successfully!");

        // GO DIRECTLY TO HISTORY PAGE (Page 2)
        Get.offAllNamed(
          Routes.dashboard,
          arguments: 1, // <-- Page2 index
        );
      } else {
        errorToast("Failed to update booking");
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
        print("🎉 BOOKING SUCCESS — NAVIGATING");
        successToast("Booking Confirmed!");
        final bookingCode = resp.data["data"]["booking_code"];
        Get.offNamed(
          Routes.confirmationpageview,
          arguments: {
            "service_name": name,
            "scheduled_at": buildScheduledAt(),
            "amount": price,
            "image": image,
            "booking_code": bookingCode, // ✅ REQUIRED
          },
        );
      } else {
        print("❌ BOOKING FAILED FROM API");
        errorToast(resp.data["error"] ?? "Booking failed");
      }
    } catch (e) {
      print("🔥 EXCEPTION IN API: $e");
      errorToast("Booking failed. Try again.");
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
    return 5.0; // static VAT
  }

  double get totalAmount {
    return servicePrice + vatAmount;
  }
}
