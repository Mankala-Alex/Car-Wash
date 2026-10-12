import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custome_confirmation_dialog.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custom_feedback_dialog.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:car_wash_customer_app/app/models/booking slot/booking_history_model.dart';
import 'package:intl/intl.dart';

class Page2View extends GetView<DashboardController> {
  const Page2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "my_bookings".tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // BODY
      // -------------------------------------------------------
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildBookingsSkeleton();
        }
        return RefreshIndicator(
          onRefresh: controller.fetchBookingHistory,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------
                // CURRENT BOOKING (DYNAMIC)
                // ---------------------------------------------------
                Text(
                  "current_booking".tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Obx(() {
                  if (controller.currentBookings.isEmpty) {
                    return Image.asset(
                      "assets/no_data/current_booking.png",
                      height: 400,
                      width: 400,
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
                Text(
                  "past_bookings".tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Obx(() {
                  if (controller.pastBookings.isEmpty) {
                    return Image.asset("assets/no_data/past_history.png",
                        width: 400, height: 400);
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
          ),
        );
      }),
    );
  }

  Widget _buildBookingsSkeleton() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          _skeletonBox(
            width: 180,
            height: 32,
            radius: 8,
          ),

          const SizedBox(height: 25),

          // Top illustration/header placeholder
          _skeletonBox(
            width: double.infinity,
            height: 150,
            radius: 12,
          ),

          const SizedBox(height: 40),

          // Past bookings title
          _skeletonBox(
            width: 180,
            height: 32,
            radius: 8,
          ),

          const SizedBox(height: 20),

          // Booking skeleton 1
          _buildBookingCardSkeleton(),

          const SizedBox(height: 20),

          // Booking skeleton 2
          _buildBookingCardSkeleton(),

          const SizedBox(height: 20),

          // Booking skeleton 3
          _buildBookingCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildBookingCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _skeletonBox(
                width: 150,
                height: 25,
                radius: 6,
              ),
              _skeletonBox(
                width: 65,
                height: 25,
                radius: 6,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Vehicle
          _skeletonBox(
            width: 210,
            height: 20,
            radius: 6,
          ),

          const SizedBox(height: 14),

          // Provider
          _skeletonBox(
            width: 230,
            height: 20,
            radius: 6,
          ),

          const SizedBox(height: 14),

          // Date
          _skeletonBox(
            width: 190,
            height: 20,
            radius: 6,
          ),

          const SizedBox(height: 14),

          // Time
          _skeletonBox(
            width: 150,
            height: 20,
            radius: 6,
          ),

          const SizedBox(height: 25),

          // Rating placeholder
          _skeletonBox(
            width: 170,
            height: 28,
            radius: 6,
          ),

          const SizedBox(height: 25),

          // Book Again
          _skeletonBox(
            width: double.infinity,
            height: 58,
            radius: 16,
          ),

          const SizedBox(height: 15),

          // View Details
          _skeletonBox(
            width: double.infinity,
            height: 58,
            radius: 16,
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
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

    if (b.scheduledAt != null) {
      dateText = DateFormat('dd MMM yyyy').format(b.scheduledAt!);
      timeText = DateFormat('hh:mm a').format(b.scheduledAt!);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff4E9AF1).withValues(alpha: 0.9),
            const Color(0xff1E78E6).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
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
                        "Provider: ${b.washerName ?? "not_assigned".tr}",
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
                          header: "edit_booking".tr,
                          body: "do_you_want_to_edit_this_booking".tr,
                          yesText: "yes_edit".tr,
                          noText: "no".tr,
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
                          header: "cancel_booking".tr,
                          body:
                              "are_you_sure_you_want_to_cancel_this_booking".tr,
                          yesText: "yes_cancel".tr,
                          noText: "no".tr,
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
                        color: Colors.red.withValues(alpha: 0.9),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close, color: Colors.white),
                            const SizedBox(width: 7),
                            Text(
                              "cancel".tr,
                              style: const TextStyle(
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
    String dateText = "N/A";
    String timeText = "N/A";

    if (booking.scheduledAt != null) {
      final localTime = booking.scheduledAt!.toLocal();
      dateText = DateFormat('dd MMM yyyy').format(localTime);
      timeText = DateFormat('hh:mm a').format(localTime);
    }

    return Obx(() {
      final isReviewed = controller.isBookingReviewed(booking.id);
      final rating = controller.getBookingReviewRating(booking.id).round();

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
            if (booking.vehicle.isNotEmpty) ...[
              Text(
                "Vehicle: ${booking.vehicle}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              "Provider: ${booking.washerName}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Date: $dateText",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Time: $timeText",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            if (isReviewed) ...[
              Row(
                children: [
                  ...List.generate(5, (starIndex) {
                    final filled = starIndex < rating;
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 22,
                      color: filled ? AppColors.warningLight : Colors.grey,
                    );
                  }),
                  const SizedBox(width: 10),
                  Text(
                    rating > 0 ? rating.toStringAsFixed(1) : '0.0',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Text(
              //   "Reviewed",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.secondaryLight,
              //   ),
              // ),
            ] else ...[
              Obx(() {
                final isReviewed = controller.isBookingReviewed(booking.id);

                if (isReviewed) {
                  final rating =
                      controller.getBookingReviewRating(booking.id) ?? 0;

                  return Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 30,
                          color: AppColors.warningLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$rating.0",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Get.dialog(
                      CustomFeedbackDialog(
                        initialRating: 0,
                        onSubmit: (rating, comments) async {
                          await controller.submitReview(
                            bookingId: booking.id,
                            rating: rating,
                            comment: comments,
                          );
                        },
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_border_rounded,
                        size: 30,
                        color: AppColors.warningLight,
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 14),
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
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "book_again".tr,
                        style: const TextStyle(
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Get.toNamed(
                  Routes.bookinghistorydetailsview,
                  arguments: booking,
                );
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondaryLight),
                ),
                child: Center(
                  child: Text(
                    "view_details".tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
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
