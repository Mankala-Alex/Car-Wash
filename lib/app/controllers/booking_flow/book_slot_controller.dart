import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/booking%20slot/slot_dates_model.dart';
import 'package:my_new_app/app/models/booking%20slot/slot_times_model.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/services/api_service.dart';

class BookSlotController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final selectedTimeSlot = Rx<String?>(null);
  RxList customerVehicles = [].obs;
  final slotDates = <Datum>[].obs; // from Slotdatesmodel
  final slotTimes = <TimeslotDatum>[]
      .obs; // rename Datum from timeslots model to avoid conflict

  final isLoadingDates = false.obs;
  final isLoadingTimes = false.obs;

  int? selectedDateId = null; // backend date_id

  String customerId = "";

  // CORRECTED: Initialize with a plain String, not another RxString.
  final selectedVehicle = Rx<String?>('Tesla Model S');

  // Add more reactive variables for selected service, address, etc.
  final selectedService = Rx<String?>('Exterior Polish'); // Added for example
  final selectedAddress = Rx<String?>('Home'); // Added for example

  late String name;
  late String description;
  late String price;
  late List<String> features;
  late String image;

  @override
  void onInit() {
    super.onInit();

    var data = Get.arguments;

    name = data["name"]?.toString() ?? "";
    description = data["description"]?.toString() ?? "";
    price = data["price"]?.toString() ?? "";
    features = List<String>.from(data["features"] ?? []);
    image = data["image"] ?? "assets/carwash/yellowcar.png";

    initData();
  }

  Future<void> initData() async {
    await loadCustomerId(); // 🔥 First load customer ID
    await fetchCustomerVehicles(); // 🔥 Then fetch vehicles
    await fetchSlotDates();
  }

  // Update methods
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;

    // find date ID from slotDates list
    final match = slotDates.firstWhereOrNull((d) =>
        d.date?.toIso8601String().split("T")[0] ==
        newDate.toIso8601String().split("T")[0]);

    if (match != null) {
      selectedDateId = match.id;
      fetchTimeslots(match.id);
    } else {
      selectedDateId = null;
      slotTimes.clear();
    }

    print("Selected date ${newDate} with ID: $selectedDateId");
  }

  void updateSelectedTimeSlot(String time) {
    selectedTimeSlot.value = time;
    print("Time slot updated to: ${selectedTimeSlot.value}");
  }

  void updateSelectedVehicle(String vehicleName) {
    selectedVehicle.value = vehicleName;
    print("Vehicle updated to: ${selectedVehicle.value}");
  }

  void updateSelectedService(String serviceName) {
    selectedService.value = serviceName;
    print("Service updated to: ${selectedService.value}");
  }

  void updateSelectedAddress(String addressTitle) {
    selectedAddress.value = addressTitle;
    print("Address updated to: ${selectedAddress.value}");
  }

  // Add the missing confirmBooking method
  void confirmBooking() {
    print("Booking Confirmed!");
    print("Date: ${selectedDate.value}");
    print("Time: ${selectedTimeSlot.value}");
    print("Vehicle: ${selectedVehicle.value}");
    print("Service: ${selectedService.value}");
    print("Address: ${selectedAddress.value}");
    // Implement your actual booking submission logic here
    Get.snackbar("Booking Confirmed", "Your car wash has been scheduled!");
// Go back after booking
  }

  Future<void> fetchCustomerVehicles() async {
    if (customerId.isEmpty) {
      print("❌ Cannot fetch vehicles, customerId is empty.");
      customerVehicles.clear();
      return;
    }

    try {
      final response =
          await ApiService.get("customer-vehicles?customer_id=$customerId");

      if (response.statusCode == 200) {
        customerVehicles.value = response.data;
      }
    } catch (e) {
      print("Vehicle fetch failed: $e");
    }
  }

  Future<void> loadCustomerId() async {
    customerId = await SharedPrefsHelper.getString("customerId") ?? "";

    if (customerId.isEmpty) {
      print("❌ Customer ID missing");
    } else {
      print("✓ Loaded customerId: $customerId");
    }
  }

  Future<void> fetchSlotDates() async {
    try {
      isLoadingDates(true);

      final resp = await BookSlotRepository().apiGetslotdates();
      final data = Slotdatesmodel.fromJson(resp.data);

      slotDates.value = data.data;

      print("Loaded dates: ${slotDates.length}");
    } catch (e) {
      print("❌ Failed to load dates: $e");
    } finally {
      isLoadingDates(false);
    }
  }

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
}
