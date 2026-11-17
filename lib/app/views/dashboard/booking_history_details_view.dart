import 'package:car_wash_customer_app/app/helpers/amount_formatter.dart';
import 'package:car_wash_customer_app/app/helpers/ful_screen_image.dart';
import 'package:car_wash_customer_app/app/helpers/media_url.dart';
import 'package:car_wash_customer_app/app/helpers/video_player.dart';
import 'package:car_wash_customer_app/app/helpers/video_thumbnail.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/booking_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/booking_history_details_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class BookingHistoryDetailsView
    extends GetView<BookingHistoryDetailsController> {
  const BookingHistoryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final b = controller.booking;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "booking_details".tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => controller.openBookingHelp(),
            icon: const Icon(
              Icons.help_outline,
              size: 18,
              color: AppColors.secondaryLight,
            ),
            label: Text(
              "help".tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= BOOKING IDENTITY =================
            _bookingHeader(b),

            const SizedBox(height: 18),

            // ================= PACKAGE CARD =================
            _packageCard(b),

            const SizedBox(height: 20),

            // ================= BOOKING DETAILS =================
            _detailsCard(b),

            const SizedBox(height: 24),

            // ================= PRICE BREAKDOWN =================
            _priceBreakdownCard(b),

            const SizedBox(height: 24),

            // ================= LOCATION =================
            _locationCard(b),

            const SizedBox(height: 24),

            // ================= VISUAL PROOF =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "visual_proof".tr,
                  style: const TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "status_completed".tr,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _mediaSection(
              title: "before".tr,
              images: b.images.where((e) => e.type == "BEFORE").toList(),
              videos: b.videos.where((e) => e.type == "BEFORE").toList(),
            ),
            const SizedBox(height: 16),
            _mediaSection(
              title: "after".tr,
              images: b.images.where((e) => e.type == "AFTER").toList(),
              videos: b.videos.where((e) => e.type == "AFTER").toList(),
            ),

            const SizedBox(height: 24),

            // ================= REVIEW =================
            _buildReviewSection(),

            const SizedBox(height: 90),
          ],
        ),
      ),

      // ================= BOTTOM ACTIONS =================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A rejected cancellation leaves the customer charged with no
              // service, so give him a way to reach support from the booking
              // he is looking at.
              if (b.isCancellationRejected) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _openSupport(b),
                    icon: const Icon(Icons.support_agent),
                    label: Text(
                      "contact_support".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC0392B),
                      side: const BorderSide(color: Color(0xFFC0392B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // SizedBox(
              //   width: double.infinity,
              //   height: 56,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.secondaryLight,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //     ),
              //     child: Text(
              //       "book_again".tr,
              //       style: const TextStyle(
              //         fontSize: 17,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// Entry point for the Contact Support flow.
  ///
  /// The real support channel is not defined yet, so this only proves the
  /// button is reachable from the booking details page.
  void _openSupport(Datum booking) {
    Get.snackbar(
      "contact_support".tr,
      "contact_support_coming_soon".tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildReviewSection() {
    return Obx(() {
      // ============================
      // REVIEW LOADING
      // ============================
      if (controller.isReviewLoading.value) {
        return _reviewSkeleton();
      }

      // ============================
      // NO REVIEW
      // ============================
      final review = controller.review.value;

      if (review == null) {
        return const SizedBox.shrink();
      }

      // ============================
      // REVIEW AVAILABLE
      // ============================
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // TITLE
            // ============================
            Text(
              "your_review".tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 14),

            // ============================
            // STARS
            // ============================
            Row(
              children: [
                ...List.generate(5, (index) {
                  final isFilled = index < review.rating;

                  return Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 28,
                    color: isFilled ? Colors.orange : Colors.grey.shade400,
                  );
                }),
                const SizedBox(width: 10),
                Text(
                  "${review.rating}/5",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // ============================
            // COMMENT
            // ============================
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _reviewSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 130, height: 22, radius: 6),
          SizedBox(height: 16),
          SkeletonBox(width: 190, height: 30, radius: 6),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 65, radius: 12),
        ],
      ),
    );
  }

  // ================= PACKAGE =================
  Widget _packageCard(b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  b.serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              RiyalAmount(
                formatAmount(b.amount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(b.vehicle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage("assets/carwash/avatar.png"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  b.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.chat_bubble_outline),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DETAILS =================
  // ================= BOOKING IDENTITY (code + status) =================
  /// The booking code lives here (not in the app bar) so long ids wrap
  /// gracefully in both English and Arabic layouts.
  Widget _bookingHeader(Datum b) {
    final statusText = _statusLabel(b.status);
    final statusColor = _statusColor(b.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLightSecondaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLightGrayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "booking_details".tr.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: AppColors.textLightGrayLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  "${'booking_id_label'.tr}: ${b.bookingCode.isEmpty ? b.id : b.bookingCode}",
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return "status_pending".tr;
      case 'ASSIGNED':
        return "status_assigned".tr;
      case 'ARRIVED':
        return "status_arrived".tr;
      case 'IN_PROGRESS':
        return "status_in_progress".tr;
      case 'COMPLETED':
        return "status_completed".tr;
      case 'CANCELLED':
      case 'CANCELED':
        return "status_cancelled".tr;
      case 'REJECTED':
        return "status_rejected".tr;
      default:
        return status.isEmpty ? "not_available".tr : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warningLight;
      case 'ASSIGNED':
      case 'ARRIVED':
        return AppColors.blue;
      case 'IN_PROGRESS':
        return AppColors.secondaryLight;
      case 'COMPLETED':
        return AppColors.successLight;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return AppColors.errorLight;
      default:
        return AppColors.textLightGrayLight;
    }
  }

  // ================= BOOKING DETAILS =================
  // Widget _detailsCard(b) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(22),
  //     ),
  //     child: Column(
  //       children: [
  //         _detailRow(
  //           Icons.calendar_today,
  //           "date_time".tr,
  //           b.scheduledAt == null
  //               ? "not_available".tr
  //               : DateFormat('dd MMM yyyy • hh:mm a').format(b.scheduledAt!),
  //         ),
  //         const Divider(),
  //         _detailRow(
  //           Icons.location_on,
  //           "service".tr,
  //           b.serviceName, // ✅ FIXED
  //         ),
  //         const Divider(),
  //         _detailRow(Icons.credit_card, "payment".tr, b.status),
  //       ],
  //     ),
  //   );
  // }
  Widget _detailsCard(b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.calendar_today,
            "date_time".tr,
            "${controller.dateText} • ${controller.timeText}",
          ),
          const Divider(),
          _detailRow(
            Icons.location_on,
            "service".tr,
            b.serviceName,
          ),
          const Divider(),
          _detailRow(
            Icons.credit_card,
            "payment".tr,
            b.status,
          ),
        ],
      ),
    );
  }

  // ================= PRICE BREAKDOWN =================
  /// Service price, VAT (rate that was paid) and the total.
  /// All three values come from the backend — the app never computes VAT.
  Widget _priceBreakdownCard(Datum b) {
    final bool hasBreakdown = b.totalAmount > 0;
    final double total =
        hasBreakdown ? b.totalAmount : (double.tryParse(b.amount) ?? 0);
    final double vatAmount = hasBreakdown ? b.vatAmount : 0;
    final double serviceAmount =
        hasBreakdown ? b.serviceAmount : (total - vatAmount);

    final String vatLabel = "vat".tr;
    final String rate = b.vatPercentage % 1 == 0
        ? b.vatPercentage.toStringAsFixed(0)
        : b.vatPercentage.toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "price_details".tr,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _amountRow("service_price".tr, serviceAmount),
          const SizedBox(height: 10),
          // Offer coupon used on this booking.
          if (b.discountAmount > 0) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${"discount".tr}${b.couponCode != null ? " (${b.couponCode})" : ""}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGreenLight,
                    ),
                  ),
                ),
                RiyalAmount(
                  "- ${formatAmount(b.discountAmount)}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGreenLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          _amountRow("$vatLabel ($rate%)", vatAmount),
          const Divider(height: 26),
          _amountRow("total_amount".tr, total, bold: true),
          if (b.paymentStatus != null && b.paymentStatus!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "${"payment".tr}: ${b.paymentStatus}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      color: bold ? Colors.black : Colors.black87,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        RiyalAmount(formatAmount(value), style: style),
      ],
    );
  }

  // ================= LOCATION =================
  Widget _locationCard(Datum b) {
    final String address = (b.formattedAddress ?? "").trim().isNotEmpty
        ? b.formattedAddress!.trim()
        : (b.address ?? "").trim();

    final List<String> extra = [
      if ((b.houseNumber ?? "").trim().isNotEmpty)
        "${'house_no'.tr}: ${b.houseNumber!.trim()}",
      if ((b.landmark ?? "").trim().isNotEmpty)
        "${'landmark'.tr}: ${b.landmark!.trim()}",
      if ((b.pincode ?? "").trim().isNotEmpty)
        "${'pincode'.tr}: ${b.pincode!.trim()}",
    ];

    if (address.isEmpty && extra.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.secondaryLight),
              const SizedBox(width: 8),
              Text(
                "location".tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (address.isNotEmpty)
            Text(address, style: const TextStyle(fontSize: 15, height: 1.4)),
          if (extra.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...extra.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _detailRow(IconData icon, String title, String value) {
  return Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.orange),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
  );
}

// ================= IMAGES =================
Widget _imageCard({required String title, required List<String> images}) {
  if (images.isEmpty) {
    return Text("no_images_available".tr);
  }

  final imageUrl = resolveMediaUrl(images.first);

  return ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Stack(
      children: [
        Image.network(
          imageUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,

          // 🔥 SKELETON LOADING
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return const SkeletonBox(
              width: double.infinity,
              height: 220,
              radius: 22,
            );
          },

          // ❌ ERROR STATE
          errorBuilder: (_, __, ___) {
            return Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
            );
          },
        ),

        // ===== TITLE CHIP =====
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: title == "Before" ? Colors.black54 : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _mediaSection({
  required String title,
  required List<BookingImage> images,
  required List<BookingVideo> videos,
}) {
  if (images.isEmpty && videos.isEmpty) {
    return Text("no_media_available".tr);
  }

  final List<Widget> mediaWidgets = [];

  // 🔹 Images
  for (var img in images) {
    final imageUrl = resolveMediaUrl(img.url);

    mediaWidgets.add(
      GestureDetector(
        onTap: () {
          Get.to(() => FullscreenImageView(imageUrl: imageUrl));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // 🔹 Videos
  for (var vid in videos) {
    String cleanPath = vid.url.replaceAll("\\", "/");

    if (!cleanPath.startsWith("/")) {
      cleanPath = "/$cleanPath";
    }

    final fileName = cleanPath.split('/').last;

    final videoUrl = "${mediaOrigin()}/api/employee/bookings/stream/$fileName";

    print("VIDEO URL: $videoUrl");

    mediaWidgets.add(
      VideoThumbnail(
        videoUrl: videoUrl,
        width: 150,
        height: 150,
        onTap: () {
          Get.to(() => VideoPlayerScreen(videoUrl: videoUrl));
        },
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: mediaWidgets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) => mediaWidgets[index],
        ),
      ),
    ],
  );
}
