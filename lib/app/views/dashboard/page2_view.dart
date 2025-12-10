import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';
import 'package:my_new_app/app/models/booking slot/booking_history_model.dart';

class Page2View extends GetView<DashboardController> {
  const Page2View({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchBookingHistory();
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
      body: SingleChildScrollView(
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
                children: controller.pastBookings.asMap().entries.map((entry) {
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
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CIRCLE AVATAR
              Container(
                height: 55,
                width: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffEAEAEA),
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/carwash/avatar.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // TITLE + PROVIDER + PRICE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SERVICE NAME
                    Text(
                      b.serviceName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // VEHICLE
                    if (b.vehicle != null && b.vehicle!.isNotEmpty) ...[
                      Text(
                        "Vehicle: ${b.vehicle}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // PROVIDER
                    Text(
                      "Provider: ${b.washerName}",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),

                    // DATE
                    Text(
                      "Date: $dateText",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),

                    // TIME
                    Text(
                      "Time: $timeText",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),

                    // PRICE
                    Row(
                      children: [
                        Image.asset("assets/carwash/SAR.png",
                            width: 18, height: 18),
                        const SizedBox(width: 5),
                        Text(
                          b.amount,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // TRACK + CANCEL BUTTONS
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  Icons.location_on,
                  "Track",
                  Colors.black,
                  AppColors.borderGray,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  Icons.close,
                  "Cancel",
                  Colors.white,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
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
              if (booking.vehicle != null && booking.vehicle!.isNotEmpty) ...[
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
