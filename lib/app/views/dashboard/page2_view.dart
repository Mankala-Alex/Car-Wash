import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custome_confirmation_dialog.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custom_feedback_dialog.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/helpers/amount_formatter.dart';
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
                    return Image.asset(
                      "assets/no_data/past_history.png",
                      width: 400,
                      height: 400,
                    );
                  }

                  return Column(
                    children: controller.pastBookings.asMap().entries.map((
                      entry,
                    ) {
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          _skeletonBox(width: 180, height: 32, radius: 8),

          const SizedBox(height: 25),

          // Top illustration/header placeholder
          _skeletonBox(width: double.infinity, height: 150, radius: 12),

          const SizedBox(height: 40),

          // Past bookings title
          _skeletonBox(width: 180, height: 32, radius: 8),

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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _skeletonBox(width: 150, height: 25, radius: 6),
              _skeletonBox(width: 65, height: 25, radius: 6),
            ],
          ),

          const SizedBox(height: 20),

          // Vehicle
          _skeletonBox(width: 210, height: 20, radius: 6),

          const SizedBox(height: 14),

          // Provider
          _skeletonBox(width: 230, height: 20, radius: 6),

          const SizedBox(height: 14),

          // Date
          _skeletonBox(width: 190, height: 20, radius: 6),

          const SizedBox(height: 14),

          // Time
          _skeletonBox(width: 150, height: 20, radius: 6),

          const SizedBox(height: 25),

          // Rating placeholder
          _skeletonBox(width: 170, height: 28, radius: 6),

          const SizedBox(height: 25),

          // Book Again
          _skeletonBox(width: double.infinity, height: 58, radius: 16),

          const SizedBox(height: 15),

          // View Details
          _skeletonBox(width: double.infinity, height: 58, radius: 16),
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
    String dateText = "not_available".tr;
    String timeText = "not_available".tr;

    // Prefer the slot label sent by the backend (Saudi wall-clock): the stored
    // `scheduled_at` is an absolute instant, so converting it would show a
    // different hour depending on the phone's timezone.
    dateText = b.slotDateLabel ?? dateText;
    timeText = b.slotStartLabel ?? timeText;

    // if (b.slotDateLabel == null && b.scheduledAt != null) {
    //   dateText = DateFormat('dd MMM yyyy').format(b.scheduledAt!);
    //   timeText = DateFormat('hh:mm a').format(b.scheduledAt!);
    // }

    if (b.scheduledAt != null) {
      dateText = (b.slotDateLabel == null || b.slotDateLabel!.trim().isEmpty)
          ? DateFormat('dd MMM yyyy').format(b.scheduledAt!)
          : b.slotDateLabel!;

      timeText = (b.slotStartLabel == null || b.slotStartLabel!.trim().isEmpty)
          ? DateFormat('hh:mm a').format(b.scheduledAt!)
          : b.slotStartLabel!;
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
                        "${'vehicle_colon'.tr}: ${b.vehicle}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${'provider_colon'.tr}: ${b.washerName ?? "not_assigned".tr}",
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
                    const RiyalSymbol(size: 20),
                    const SizedBox(height: 4),
                    Text(
                      formatAmount(b.amount),
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
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  timeText,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: b.hasTechnicianAssigned
                      // Same rule as cancelling: once a technician took the
                      // job the slot belongs to him, so the edit flow stays
                      // closed and the button only explains why.
                      ? GestureDetector(
                          onTap: () {
                            Get.dialog(
                              CustomConfirmationDialog(
                                header: "edit_booking".tr,
                                body: "edit_blocked_technician_assigned".tr,
                                yesText: "close".tr,
                                isCancel: false,
                                onYes: Get.back,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFFF1F5F9),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "edit_locked_technician_assigned".tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
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
                                    "price": formatAmount(b.amount),
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
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.blue),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit, color: Colors.blue),
                                  const SizedBox(width: 7),
                                  Text(
                                    "edit".tr,
                                    style: const TextStyle(
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
                  child: b.hasPendingCancellation
                      // Already asked for a cancellation: the admin has to
                      // approve it, so the button becomes a status chip.
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFFFF4E5),
                            border: Border.all(color: const Color(0xFFF0B429)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.hourglass_top,
                                  size: 18,
                                  color: Color(0xFFB7791F),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "cancellation_requested".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB7791F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            // Opens the cancellation sheet: policy + reasons + remarks.
                            // Nothing is refunded here — an admin approves the request.
                            controller.openCancellationSheet(
                              b.bookingCode.toString(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.close, color: Colors.red),
                                  const SizedBox(width: 7),
                                  Text(
                                    "cancel".tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
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

            const SizedBox(height: 10),

            // VIEW DETAILS - opens the full booking details page
            GestureDetector(
              onTap: () {
                // Get.toNamed(Routes.bookinghistorydetailsview, arguments: b);
                Get.toNamed(
                  Routes.bookinghistorydetailsview,
                  arguments: {
                    'booking': b,
                    'dateText': dateText,
                    'timeText': timeText,
                  },
                );
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    "view_details".tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // PAST BOOKING CARD (Same UI as your original, only dynamic)
  // ===================================================================
  /// Refund status line for a cancelled booking.
  ///
  /// Replaces the review widget: there is no completed service to rate, but the
  /// customer must be able to see whether the money came back.
  Widget _cancelledRefundInfo(Datum booking) {
    final status = (booking.refundStatus ?? "").toUpperCase();
    final failed = status == "FAILED";
    final noPayment = status == "NOT_REQUIRED";
    // A real refund: Paymob credits the card, so the customer can see a
    // separate refund line on his statement.
    final refunded = status == "REFUNDED";
    // A void: the payment was cancelled BEFORE it settled, so the bank simply
    // releases the hold — the charge disappears instead of a credit appearing.
    // Saying "refunded" here made customers look for money that never shows up
    // as a credit, so it gets its own wording and its own timing.
    final reversed = status == "VOIDED";
    // The admin rejected the request: the booking is cancelled but the money
    // stays with us, so never pretend a refund is on its way.
    final rejected = status == "REJECTED";

    final String amount = formatAmount(booking.refundAmount ?? booking.amount);

    final String label;
    if (failed) {
      label = "refund_failed_contact_support".tr;
    } else if (noPayment) {
      label = "no_payment_taken".tr;
    } else if (refunded) {
      label = "${"refund_issued".tr}: $amount";
    } else if (reversed) {
      // `trParams` does not always resolve placeholders with this localization
      // setup, so the amount is substituted explicitly.
      label = "payment_reversed_to_card".tr.replaceAll("{{amount}}", amount);
    } else if (rejected) {
      label = "cancellation_rejected_no_refund".tr;
    } else {
      label = "refund_pending_review".tr;
    }

    // Red = the customer must act. Amber = money is on its way but the bank has
    // not shown it yet. Green = done.
    final isProblem = failed || rejected;
    final Color foreground = isProblem
        ? const Color(0xFFC0392B)
        : (reversed ? const Color(0xFFB7791F) : const Color(0xFF1E8449));
    final Color background = isProblem
        ? const Color(0xFFFDECEC)
        : (reversed ? const Color(0xFFFFF4E5) : const Color(0xFFE8F6EC));

    final String reason =
        rejected ? (booking.cancellationRejectionReason ?? "").trim() : "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isProblem
                ? Icons.error_outline
                : (reversed ? Icons.hourglass_top : Icons.check_circle_outline),
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    "${"cancellation_rejection_reason".tr}: $reason",
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when an admin rejected the cancellation request.
  ///
  /// Rejecting never cancels the booking and never refunds it, so the message
  Widget _pastBookingCard({required int index, required Datum booking}) {
    String dateText = "not_available".tr;
    String timeText = "not_available".tr;

    // Same rule as the current-booking card: show the slot's own Saudi time.
    dateText = booking.slotDateLabel ?? dateText;
    timeText = booking.slotStartLabel ?? timeText;

    if (booking.slotDateLabel == null && booking.scheduledAt != null) {
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
                if (booking.isCancelled)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "cancelled".tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC0392B),
                      ),
                    ),
                  ),
                const RiyalSymbol(size: 18),
                const SizedBox(width: 5),
                Text(
                  formatAmount(booking.amount),
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
                "${'vehicle_colon'.tr}: ${booking.vehicle}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              "${'provider_colon'.tr}: ${booking.washerName ?? "not_assigned".tr}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              "${'date_colon'.tr}: $dateText",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              "${'time_colon'.tr}: $timeText",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            if (booking.isCancelled) ...[
              // Cancelled bookings have no service to review — show the refund
              // state instead of the star rating widget.
              _cancelledRefundInfo(booking),
            ] else if (isReviewed) ...[
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
                Get.toNamed(
                  Routes.bookslot,
                  arguments: {
                    "name": booking.serviceName,
                    // Service price (excl. VAT) when the backend sent the
                    // breakdown, otherwise the stored total is used as-is.
                    "price": booking.serviceAmount > 0
                        ? booking.serviceAmount.toString()
                        : formatAmount(booking.amount),
                    "service_id": booking.serviceId,
                    "image": "assets/carwash/toyota_camry.png",
                    "description": "Quick wash",
                    "features": ["Vacuum", "Tire Shine", "Body Wash"],
                    "vat_percentage": booking.vatPercentage,
                    "vat_amount": booking.vatAmount,
                    "total_amount": booking.totalAmount,
                  },
                );
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
                  arguments: {
                    'booking': booking,
                    'dateText': dateText,
                    'timeText': timeText,
                  },
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
