import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking slot/slot_dates_model.dart';
import 'package:my_new_app/app/models/booking slot/slot_times_model.dart';
import 'package:my_new_app/app/models/booking slot/book_slot_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/services/api_service.dart';

class BookSlotController extends GetxController {
  /// null at start → user must tap a date first
  final selectedDate = Rx<DateTime?>(null);

  /// label of selected time slot ("09:00")
  final selectedTimeSlot = Rx<String?>(null);

  /// vehicles of this customer
  RxList customerVehicles = [].obs;

  /// all available dates from backend
  final slotDates = <SlotDate>[].obs;

  /// time-slots for currently selected date
  final slotTimes = <TimeslotDatum>[].obs;

  final isLoadingDates = false.obs;
  final isLoadingTimes = false.obs;

  int? selectedDateId; // backend date_id

  String customerUuid = "";
  int? customerNumericId;

  // Other selections
  final selectedVehicle = Rx<String?>('Tesla Model S');
  final selectedService = Rx<String?>('Exterior Polish');
  final selectedAddress = Rx<String?>('Home');

  late String name;
  late String description;
  late String price; // keep as String for UI
  late List<String> features;
  late String image;

  String? customerName; // from SharedPrefs
  String? customerPhone; // optional

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments ?? {};
    name = data["name"]?.toString() ?? "";
    description = data["description"]?.toString() ?? "";
    price = data["price"]?.toString() ?? "";
    features = List<String>.from(data["features"] ?? []);
    image = data["image"] ?? "assets/carwash/yellowcar.png";

    initData();
  }

  Future<void> initData() async {
    await loadCustomerIds();
    await fetchCustomerVehicles();
    await fetchSlotDates();
  }

  Future<void> loadCustomerIds() async {
    customerUuid = await SharedPrefsHelper.getString("customerUuid") ?? "";
    customerNumericId = await SharedPrefsHelper.getInt("customerNumericId");
    customerName =
        await SharedPrefsHelper.getString("customerName") ?? "No Name";

    customerPhone = await SharedPrefsHelper.getString("customerPhone") ?? "";

    print("✅ Loaded Customer:");
    print("UUID: $customerUuid");
    print("Numeric ID: $customerNumericId");
    print("Name: $customerName");
  }

  // ---------------- DATE & TIME ----------------

  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );

    selectedDate.refresh();
    selectedTimeSlot.value = null;

    final match = slotDates.firstWhereOrNull(
      (d) => isSameDate(d.date, newDate),
    );

    if (match != null) {
      selectedDateId = match.id;
      fetchTimeslots(match.id);
    } else {
      selectedDateId = null;
      slotTimes.clear();
    }

    print("User selected: $newDate → ID = $selectedDateId");
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void updateSelectedTimeSlot(String timeLabel) {
    selectedTimeSlot.value = timeLabel;
    print("Time slot updated to: $timeLabel");
  }

  // ---------------- OTHER SELECTIONS ----------------

  void updateSelectedVehicle(String vehicleName) {
    selectedVehicle.value = vehicleName;
    print("Vehicle updated to: $vehicleName");
  }

  void updateSelectedService(String serviceName) {
    selectedService.value = serviceName;
    print("Service updated to: $serviceName");
  }

  void updateSelectedAddress(String addressTitle) {
    selectedAddress.value = addressTitle;
    print("Address updated to: $addressTitle");
  }

  // ---------------- VEHICLES ----------------

  Future<void> fetchCustomerVehicles() async {
    // NOTE: your vehicles API still uses uuid, so keep that as is:
    if (customerUuid.isEmpty) {
      print("❌ Cannot fetch vehicles, customerUuid is empty.");
      customerVehicles.clear();
      return;
    }

    try {
      final response =
          await ApiService.get("customer-vehicles?customer_id=$customerUuid");

      if (response.statusCode == 200) {
        customerVehicles.value = response.data;
      }
    } catch (e) {
      print("Vehicle fetch failed: $e");
    }
  }

  // ---------------- SLOTS: DATES & TIMES ----------------

  Future<void> fetchSlotDates() async {
    try {
      isLoadingDates(true);

      final resp = await BookSlotRepository().apiGetslotdates();
      final data = Slotsdatemodel.fromJson(resp.data);

      final today = DateTime.now();

      // Keep only today & future dates
      slotDates.value = data.data.where((d) {
        final slotDate = DateTime(d.date.year, d.date.month, d.date.day);
        final todayOnly = DateTime(today.year, today.month, today.day);
        return slotDate.isAtSameMomentAs(todayOnly) ||
            slotDate.isAfter(todayOnly);
      }).toList();

      print("Filtered dates: ${slotDates.length}");
    } catch (e) {
      print("❌ Failed to load dates: $e");
    } finally {
      isLoadingDates(false);
    }
  }

  // Future<void> fetchSlotDates() async {
  //   try {
  //     isLoadingDates(true);

  //     final resp = await BookSlotRepository().apiGetslotdates();
  //     final data = Slotsdatemodel.fromJson(resp.data);

  //     slotDates.value = data.data;
  //     print("Loaded dates: ${slotDates.length}");
  //   } catch (e) {
  //     print("❌ Failed to load dates: $e");
  //   } finally {
  //     isLoadingDates(false);
  //   }
  //   print("BACKEND DATES (after model parse):");
  //   for (var d in slotDates) {
  //     print("ID: ${d.id} → DATE: ${d.date}");
  //   }
  // }

  Future<void> fetchTimeslots(int dateId) async {
    try {
      isLoadingTimes(true);

      final resp = await BookSlotRepository().apiGettimeslots(dateId);
      final data = Slottimesmodel.fromJson(resp.data);

      slotTimes.value = data.data;
      print("Loaded ${slotTimes.length} slots for dateId $dateId");
    } catch (e) {
      print("❌ Failed to load time slots: $e");
      slotTimes.clear();
    } finally {
      isLoadingTimes(false);
    }
  }

  // ---------------- BOOK SLOT ----------------

  Future<void> bookSlot() async {
    if (selectedDate.value == null || selectedTimeSlot.value == null) {
      Get.snackbar("Error", "Please select a date and time");
      return;
    }

    if (customerNumericId == null || customerNumericId == 0) {
      Get.snackbar("Error", "Customer ID not found, please re-login");
      return;
    }

    try {
      final selected = slotTimes.firstWhere(
        (s) => s.time == selectedTimeSlot.value,
      );

      // ⬅️ Extract correct hour & minute based on selected time
      final hour = int.parse(selected.time.split(":")[0]);
      final minute = int.parse(selected.time.split(":")[1]);

      final scheduledDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        hour,
        minute,
      );

      final requestBody = {
        "customer_id": customerNumericId,
        "customer_name": customerName ?? "Unknown",
        "vehicle": selectedVehicle.value ?? "",
        "service_id": Get.arguments["service_id"],
        "service_name": name,
        "slot_id": selected.id,
        "scheduled_at": scheduledDateTime.toUtc().toIso8601String(),
        "washer_id": "sarim", // if required
        "washer_name": "sarim", // if required
        "amount": double.tryParse(price) ?? 0,
        "status": "Pending",
      };

      print("📤 BOOKING REQUEST BODY:");
      print(requestBody);

      final resp = await BookSlotRepository().postBookSlot(requestBody);

      print("📥 BOOKING RESPONSE:");
      print(resp.data);

      Get.snackbar("Success", "Booking created!");

      Get.toNamed(Routes.confirmationpageview, arguments: resp.data);
    } catch (e) {
      print("❌ Booking error: $e");
      Get.snackbar("Booking Failed", "Please try again.");
    }
  }
}

//for booking history//
// import 'package:get/get.dart';
// import 'package:my_new_app/app/helpers/shared_preferences.dart';
// import 'package:my_new_app/app/models/booking slot/slot_dates_model.dart';
// import 'package:my_new_app/app/models/booking slot/slot_times_model.dart';
// import 'package:my_new_app/app/models/booking%20slot/book_slot_model.dart';
// import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
// import 'package:my_new_app/app/routes/app_routes.dart';
// import 'package:my_new_app/app/services/api_service.dart';

// class BookSlotController extends GetxController {
//   /// null at start → user must tap a date first
//   final selectedDate = Rx<DateTime?>(null);

//   /// label of selected time slot ("09:00 - 10:00")
//   final selectedTimeSlot = Rx<String?>(null);

//   /// vehicles of this customer
//   RxList customerVehicles = [].obs;

//   /// all available dates from backend
//   final slotDates = <SlotDate>[].obs;

//   /// time-slots for currently selected date
//   final slotTimes = <TimeslotDatum>[].obs;

//   final isLoadingDates = false.obs;
//   final isLoadingTimes = false.obs;

//   int? selectedDateId; // backend date_id

//   String customerId = "";

//   // Other selections
//   final selectedVehicle = Rx<String?>('Tesla Model S');
//   final selectedService = Rx<String?>('Exterior Polish');
//   final selectedAddress = Rx<String?>('Home');

//   late String name;
//   late String description;
//   late String price; // keep as String for UI
//   late List<String> features;
//   late String image;

//   @override
//   void onInit() {
//     super.onInit();

//     final data = Get.arguments ?? {};
//     name = data["name"]?.toString() ?? "";
//     description = data["description"]?.toString() ?? "";
//     price = data["price"]?.toString() ?? ""; // 👈 avoid double/String error
//     features = List<String>.from(data["features"] ?? []);
//     image = data["image"] ?? "assets/carwash/yellowcar.png";

//     initData();
//   }

//   Future<void> initData() async {
//     await loadCustomerId();
//     await fetchCustomerVehicles();
//     await fetchSlotDates();
//     // ❌ do NOT set selectedDate or fetch slots here
//     // user must first select a date
//   }

//   // ---------------- DATE & TIME ----------------

//   /// Called from UI when user taps a date in the timeline
//   void updateSelectedDate(DateTime newDate) {
//     selectedDate.value = DateTime(
//       newDate.year,
//       newDate.month,
//       newDate.day,
//     );

//     selectedDate.refresh(); // <-- THIS FIXES UI NOT UPDATING

//     selectedTimeSlot.value = null;

//     final match = slotDates.firstWhereOrNull(
//       (d) => d.date != null && isSameDate(d.date!, newDate),
//     );

//     if (match != null) {
//       selectedDateId = match.id;
//       fetchTimeslots(match.id);
//     } else {
//       selectedDateId = null;
//       slotTimes.clear();
//     }

//     print("User selected: $newDate → ID = $selectedDateId");
//   }

//   bool isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   void updateSelectedTimeSlot(String timeLabel) {
//     selectedTimeSlot.value = timeLabel;
//     print("Time slot updated to: $timeLabel");
//   }

//   // ---------------- OTHER SELECTIONS ----------------

//   void updateSelectedVehicle(String vehicleName) {
//     selectedVehicle.value = vehicleName;
//     print("Vehicle updated to: $vehicleName");
//   }

//   void updateSelectedService(String serviceName) {
//     selectedService.value = serviceName;
//     print("Service updated to: $serviceName");
//   }

//   void updateSelectedAddress(String addressTitle) {
//     selectedAddress.value = addressTitle;
//     print("Address updated to: $addressTitle");
//   }

//   // ---------------- BOOKING CONFIRM ----------------

//   void confirmBooking() {
//     print("Booking Confirmed!");
//     print("Date: ${selectedDate.value}");
//     print("Time: ${selectedTimeSlot.value}");
//     print("Vehicle: ${selectedVehicle.value}");
//     print("Service: ${selectedService.value}");
//     print("Address: ${selectedAddress.value}");

//     Get.snackbar("Booking Confirmed", "Your car wash has been scheduled!");
//   }

//   // ---------------- VEHICLES ----------------

//   Future<void> fetchCustomerVehicles() async {
//     if (customerId.isEmpty) {
//       print("❌ Cannot fetch vehicles, customerId is empty.");
//       customerVehicles.clear();
//       return;
//     }

//     try {
//       final response =
//           await ApiService.get("customer-vehicles?customer_id=$customerId");

//       if (response.statusCode == 200) {
//         customerVehicles.value = response.data;
//       }
//     } catch (e) {
//       print("Vehicle fetch failed: $e");
//     }
//   }

//   Future<void> loadCustomerId() async {
//     customerId = await SharedPrefsHelper.getString("customerId") ?? "";

//     if (customerId.isEmpty) {
//       print("❌ Customer ID missing");
//     } else {
//       print("✓ Loaded customerId: $customerId");
//     }
//   }

//   // ---------------- SLOTS: DATES & TIMES ----------------

//   Future<void> fetchSlotDates() async {
//     try {
//       isLoadingDates(true);

//       final resp = await BookSlotRepository().apiGetslotdates();
//       final data = Slotsdatemodel.fromJson(resp.data);

//       slotDates.value = data.data;
//       print("Loaded dates: ${slotDates.length}");
//     } catch (e) {
//       print("❌ Failed to load dates: $e");
//     } finally {
//       isLoadingDates(false);
//     }
//     print("BACKEND DATES (after model parse):");
//     for (var d in slotDates) {
//       print("ID: ${d.id} → DATE: ${d.date}");
//     }
//   }

//   Future<void> fetchTimeslots(int dateId) async {
//     try {
//       isLoadingTimes(true);

//       final resp = await BookSlotRepository().apiGettimeslots(dateId);
//       final data = Slottimesmodel.fromJson(resp.data);

//       slotTimes.value = data.data;
//       print("Loaded ${slotTimes.length} slots for dateId $dateId");
//     } catch (e) {
//       print("❌ Failed to load time slots: $e");
//       slotTimes.clear();
//     } finally {
//       isLoadingTimes(false);
//     }
//   }

//   Future<void> bookSlot() async {
//     if (selectedDate.value == null || selectedTimeSlot.value == null) {
//       Get.snackbar("Error", "Please select a date and time");
//       return;
//     }

//     try {
//       final selected = slotTimes.firstWhere(
//         (s) => s.time == selectedTimeSlot.value,
//       );

//       final DateTime scheduledDateTime = DateTime(
//         selectedDate.value!.year,
//         selectedDate.value!.month,
//         selectedDate.value!.day,
//         selected.hour,
//         selected.minute,
//       );

//       final requestBody = {
//         "customer_id": customerId,
//         "customer_name": "khaleel ulla", // TODO: get from local
//         "vehicle": selectedVehicle.value ?? "",
//         "service_id": Get.arguments["service_id"], // <-- from previous page
//         "service_name": name,
//         "slot_id": selected.id,
//         "scheduled_at": scheduledDateTime.toUtc().toIso8601String(),
//         "washer_id": "sarim", // backend demands
//         "washer_name": "sarim", // backend demands
//         "amount": double.tryParse(price) ?? 0,
//         "status": "Pending",
//       };

//       print("📤 BOOKING REQUEST BODY:");
//       print(requestBody);

//       final resp = await BookSlotRepository().postBookSlot(requestBody);

//       print("📥 BOOKING RESPONSE:");
//       print(resp.data);

//       Get.snackbar("Success", "Booking created!");

//       Get.toNamed(Routes.confirmationpageview, arguments: resp.data);
//     } catch (e) {
//       print("❌ Booking error: $e");
//       Get.snackbar("Booking Failed", "Please try again.");
//     }
//   }
// }
