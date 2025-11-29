import 'package:get/get.dart';

class BookSlotController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final selectedTimeSlot = Rx<String?>(null);

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
    var data = Get.arguments;

    name = data["name"]?.toString() ?? "";
    description = data["description"]?.toString() ?? "";
    price = data["price"]?.toString() ?? ""; // ALWAYS STRING
    features = List<String>.from(data["features"] ?? []);
    image = data["image"] ?? "assets/carwash/yellowcar.png";

    super.onInit();
  }

  // Update methods
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
    print("Date updated to: ${selectedDate.value}");
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
}
