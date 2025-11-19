import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

// IMPORTANT: Ensure this import path is correct for your project

// The main view widget is Stateless, extending GetView
// This automatically provides access to the BookSlotController instance via 'controller'
class BookSlotView extends GetView<BookSlotController> {
  const BookSlotView({super.key});

  // --- Helper Widget for Vehicle Cards ---
  Widget _buildVehicleCard(
    BuildContext context, {
    required String vehicleName,
    required String plateNumber,
    required String imagePath,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.updateSelectedVehicle(vehicleName),
        child: Container(
          width: Get.width * 0.55, // ← 55% of screen → shows 1 full + half next
          padding: const EdgeInsets.all(14),
          //margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: controller.selectedVehicle.value == vehicleName
                  ? const Color(0xFF0A63F6)
                  : const Color(0xFFE6E6E6),
              width: controller.selectedVehicle.value == vehicleName ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bigger Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  imagePath,
                  height: 120, // ← increased height
                  width: double.infinity,
                  fit: BoxFit.cover, // looks exactly like your screenshot
                ),
              ),

              const SizedBox(height: 12),

              Text(
                vehicleName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                plateNumber,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Add New Vehicle Card ---
  Widget _buildAddVehicleCard(BuildContext context) {
    return GestureDetector(
      // Wrap with GestureDetector
      onTap: () {
        // Handle navigation to Add Vehicle screen
        print("Add New Vehicle tapped!");
      },
      child: Container(
        width: 150, // Fixed width for add vehicle card
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline,
                size: 30, color: AppColors.primaryLight),
            const SizedBox(height: 8),
            Text(
              "Add New",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDatePicker(BuildContext context, DateTime selectedDate,
      Function(DateTime) onDateChange) {
    return SizedBox(
      height: 88,
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: selectedDate,
        daysCount: 30, // Shows 30 days starting today
        width: 50,
        height: 88,
        selectionColor: AppColors.textWhiteLight,
        selectedTextColor: AppColors.textDefaultLight,
        monthTextStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        dayTextStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        dateTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
        deactivatedColor: AppColors.textDefaultLight,
        onDateChange: onDateChange,
      ),
    );
  }

  // --- Helper Widget for Time Slots ---
  Widget _buildTimeSlots(BuildContext context) {
    // This list would typically be dynamic based on the selected date (fetched by controller)
    final List<String> availableTimes = [
      "9:00 AM", "9:30 AM", "10:00 AM", "11:30 AM",
      "1:00 PM", "2:00 PM", "3:30 PM", "4:00 PM",
      "4:30 PM" // Example more slots
    ];

    return Obx(
      () => Wrap(
        spacing: 12, // Horizontal spacing
        runSpacing: 12, // Vertical spacing
        children: availableTimes.map((time) {
          bool isDisabled = time == "3:30 PM"; // Example of a disabled slot
          return _buildTimeSlotButton(
            context,
            time,
            isSelected: controller.selectedTimeSlot.value == time,
            isDisabled: isDisabled,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlotButton(BuildContext context, String time,
      {bool isSelected = false, bool isDisabled = false}) {
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: isDisabled
          ? null
          : (selected) {
              controller.updateSelectedTimeSlot(
                  time); // Calls the method in the controller
            },
      selectedColor: const Color(0xFF2196F3),
      disabledColor: Colors.grey[300],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isDisabled
            ? Colors.grey[600]
            : (isSelected ? Colors.white : const Color(0xFF1E293B)),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDisabled
              ? Colors.transparent
              : (isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    );
  }

  // --- Helper Widget for Map Snippet ---
  Widget _buildMapSnippet(BuildContext context) {
    // This is a static image placeholder. A real map would use google_maps_flutter.
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage(
              'assets/carwash/map.png'), // Replace with your map image asset
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // --- Helper Widget for Address Cards ---
  Widget _buildAddressCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String address,
    // isSelected will now come from the controller via Obx
  }) {
    return Obx(
      // Wrap with Obx to react to selectedAddress changes
      () => GestureDetector(
        // Wrap with GestureDetector for tapping
        onTap: () =>
            controller.updateSelectedAddress(title), // Call controller method
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedAddress.value == title
                  ? AppColors.primaryLight
                  : Colors.grey[300]!,
              width: controller.selectedAddress.value == title ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF0F4F8), // Light grey background for icon
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.primaryLight),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                    ),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Radio<bool>(
                value: true,
                groupValue: controller.selectedAddress.value ==
                    title, // Use controller state
                onChanged: (bool? value) {
                  // This is redundant as the GestureDetector onTap handles it,
                  // but kept for explicit radio button behavior if desired.
                  if (value == true) controller.updateSelectedAddress(title);
                },
                activeColor: const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Bottom Confirm Booking Bar ---
  Widget _buildBottomConfirmBookingBar(
      BuildContext context, double screenWidth, String totalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        // Ensures content is not obscured by system UI (like navigation gestures)
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min, // Essential for Column in Row
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  totalAmount, // This could also come from the controller
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Call the booking submission method in your controller
                //print("Confirm Booking tapped!");
                //controller.confirmBooking();
                Get.toNamed(Routes.confirmationpageview);
                // Calling the method now defined in controller
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                "Confirm Booking",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textDefaultLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondaryLight, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF1E293B)), // Dark icon
          onPressed: () {
            Get.back(); // Use GetX for navigation back
          },
        ),
        title: const Text(
          "Confirm Your Wash",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 30, 41, 59),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildServiceSummaryCard(context),
            Text(
              "Select Your Vehicle",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDefaultLight),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 210, // Fixed height for vehicle cards
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildVehicleCard(context,
                      vehicleName: "Tesla Model",
                      plateNumber: "MAJ-923",
                      imagePath: "assets/carwash/whitecar.png"),
                  const SizedBox(width: 12),
                  _buildVehicleCard(context,
                      vehicleName: "Ford F-150",
                      plateNumber: "XYZ-789",
                      imagePath: "assets/carwash/blue.png"),
                  const SizedBox(width: 12),
                  _buildAddVehicleCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Select Date and Time",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDefaultLight),
            ),
            const SizedBox(height: 15),
            buildDatePicker(context, controller.selectedDate.value, (date) {
              controller.selectedDate.value = date;
              // Fetch available slots, etc., if needed
            }),

            const SizedBox(height: 15),
            _buildTimeSlots(context), // This uses Obx and controller

            const SizedBox(height: 30),

            // --- Location Section ---
            const SizedBox(height: 16),
            _buildMapSnippet(context),
            const SizedBox(height: 16),
            _buildAddressCard(context,
                icon: Icons.home_outlined,
                title: "Home",
                address: "123 Market St, San Francisco"),
            const SizedBox(height: 12),
            _buildAddressCard(context,
                icon: Icons.work_outline,
                title: "Work",
                address: "456 Tech Ave, Silicon Valley"),
            const SizedBox(height: 30),
            // The main widget structure for the Price Details section

            // --- Section Header: Price Details ---
            Text(
              "Price Details",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDefaultLight),
            ),
            const SizedBox(height: 10),

            // --- The Content Card ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // White background for the card
                borderRadius: BorderRadius.circular(15), // Rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  // 1. Premium Wash Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premium Wash',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '\$75.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500, // Semi-bold for price
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // 2. Taxes & Fees Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taxes & Fees',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        '\$6.56',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // 3. Total Amount Row (Bold and Blue)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .black, // Slightly darker than the above text
                        ),
                      ),
                      Text(
                        '\$81.56',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Highlight color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomConfirmBookingBar(context, screenWidth,
          "\$55.25"), // Total amount can be dynamic from controller
    );
  }

  Widget buildServiceSummaryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/carwash/yellowcar.png', // Replace with actual image
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SERVICE DETAILS',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Premium Interior & Exterior Wash',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    Text(
                      '\$75.00',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Our most popular package for a complete clean.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Est. Duration: 90 mins',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildVehicleSelector(
    BuildContext context, {
    required RxString selectedVehicle,
    required void Function(String) onSelectVehicle,
  }) {
    // Example vehicles; replace with your actual data or use from your controller
    final List<Map<String, String>> vehicles = [
      {
        'image': 'assets/tesla_model3.jpg',
        'name': 'Tesla Model 3',
        'plate': 'ABC-123'
      },
      {'image': 'assets/bmw_m2.jpg', 'name': 'BMW M2', 'plate': 'XYZ-789'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Select Your Vehicle',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 110,
          child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isSelected = selectedVehicle.value == vehicle['name'];
                  return GestureDetector(
                    onTap: () => onSelectVehicle(vehicle['name'] ?? ""),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.asset(
                              vehicle['image'] ?? "",
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(vehicle['name'] ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.blue : Colors.black)),
                          Text(vehicle['plate'] ?? "",
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }
}
