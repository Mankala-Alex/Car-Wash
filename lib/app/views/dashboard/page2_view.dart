import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/custome_widgets/custome_confirmation_dialog.dart';
import 'package:my_new_app/app/custome_widgets/wheel_loader.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';
import 'package:my_new_app/app/models/booking slot/booking_history_model.dart';

class Page2View extends GetView<DashboardController> {
  const Page2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Bookings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),

      // -------------------------------------------------------
      // BODY
      // -------------------------------------------------------
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: wheelloader(), // your lottie loader here
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------
              // CURRENT BOOKING (DYNAMIC)
              // ---------------------------------------------------
              const Text(
                "Current Booking",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (controller.currentBookings.isEmpty) {
                  return const Text(
                    "No current bookings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  );
                }

                // Only 1 card? Show the first one.
                return Column(
                  children: controller.currentBookings.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _currentBookingCard(b),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 30),

              // ---------------------------------------------------
              // PAST BOOKINGS
              // ---------------------------------------------------
              const Text(
                "Past Bookings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (controller.pastBookings.isEmpty) {
                  return const Text(
                    "No past bookings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  );
                }

                return Column(
                  children:
                      controller.pastBookings.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _pastBookingCard(
                        index: entry.key,
                        booking: entry.value,
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ===================================================================
  // CURRENT BOOKING CARD (Your exact same UI, only dynamic data added)
  // ===================================================================
  Widget _currentBookingCard(Datum b) {
    // --- Extract DATE and TIME from scheduled_at ---
    String dateText = "N/A";
    String timeText = "N/A";

    if (b.scheduledAt != null && b.scheduledAt!.contains("T")) {
      final parts = b.scheduledAt!.split("T");
      dateText = parts[0];
      if (parts.length > 1 && parts[1].length >= 5) {
        timeText = parts[1].substring(0, 5);
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff4E9AF1).withOpacity(0.9),
            const Color(0xff1E78E6).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW WITH AVATAR + NAME
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/carwash/avatar.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // SERVICE + WASHER + VEHICLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vehicle: ${b.vehicle}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Provider: ${b.washerName.isEmpty ? "Not Assigned" : b.washerName}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // PRICE
                Column(
                  children: [
                    Image.asset("assets/carwash/SAR.png",
                        width: 20, height: 20),
                    const SizedBox(height: 4),
                    Text(
                      b.amount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(),

            const SizedBox(height: 12),

            // DATE & TIME ROW
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.dialog(
                        CustomConfirmationDialog(
                          header: "Edit Booking",
                          body: "Do you want to edit this booking?",
                          yesText: "Yes, Edit",
                          noText: "No",
                          onYes: () {
                            Get.back();

                            controller.editBooking({
                              "booking_code": b.bookingCode,
                              "vehicle": b.vehicle,
                              "service_id": b.serviceId,
                              "service_name": b.serviceName,
                              "slot_id": b.slotId,
                              "price": b.amount,
                              "image": "",
                              "description": "",
                              "features": [],
                            });
                          },
                        ),
                        barrierDismissible: false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.blue)),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 7),
                            Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.dialog(
                        CustomConfirmationDialog(
                          header: "Cancel Booking",
                          body: "Are you sure you want to cancel this booking?",
                          yesText: "Yes, Cancel",
                          noText: "No",
                          onYes: () async {
                            Get.back(); // close dialog

                            controller.isLoading.value = true;

                            await controller
                                .cancelBooking(b.bookingCode.toString());

                            controller.isLoading.value = false;
                          },
                        ),
                        barrierDismissible: false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.red.withOpacity(0.9),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, color: Colors.white),
                            SizedBox(width: 7),
                            Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // PAST BOOKING CARD (Same UI as your original, only dynamic)
  // ===================================================================
  Widget _pastBookingCard({
    required int index,
    required Datum booking,
  }) {
    // --- Extract DATE and TIME from scheduled_at ---
    String dateText = "N/A";
    String timeText = "N/A";

    if (booking.scheduledAt != null && booking.scheduledAt!.contains("T")) {
      final parts = booking.scheduledAt!.split("T");
      dateText = parts[0];
      if (parts.length > 1 && parts[1].length >= 5) {
        timeText = parts[1].substring(0, 5);
      }
    }

    return GetBuilder<DashboardController>(
      builder: (ctrl) {
        int rating = ctrl.ratingMap[index] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE + PRICE ROW
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Image.asset("assets/carwash/SAR.png", width: 18, height: 18),
                  const SizedBox(width: 5),
                  Text(
                    booking.amount,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // VEHICLE
              if (booking.vehicle.isNotEmpty) ...[
                Text(
                  "Vehicle: ${booking.vehicle}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
              ],

              // PROVIDER
              Text(
                "Provider: ${booking.washerName}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),

              // DATE
              Text(
                "Date: $dateText",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),

              // TIME
              Text(
                "Time: $timeText",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // ⭐ RATING
              Row(
                children: List.generate(5, (starIndex) {
                  bool isFilled = starIndex < rating;

                  return GestureDetector(
                    onTap: () => ctrl.setRating(index, starIndex + 1),
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      size: 26,
                      color: isFilled ? AppColors.warningLight : Colors.grey,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 14),

              // BOOK AGAIN BUTTON
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.bookslot, arguments: {
                    "name": booking.serviceName,
                    "price": booking.amount,
                    "service_id": booking.serviceId,
                    "image": "assets/carwash/toyota_camry.png",
                    "description": "Quick wash",
                    "features": ["Vacuum", "Tire Shine", "Body Wash"],
                  });
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.secondaryLight,
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Book Again",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================================================================
  // COMMON ACTION BUTTON (unchanged)
  // ===================================================================
  Widget _actionButton(
    IconData icon,
    String label,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
