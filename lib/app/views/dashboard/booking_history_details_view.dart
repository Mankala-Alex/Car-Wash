import 'package:car_wash_customer_app/app/helpers/ful_screen_image.dart';
import 'package:car_wash_customer_app/app/helpers/video_player.dart';
import 'package:car_wash_customer_app/app/helpers/video_thumbnail.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/booking_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/config/constants.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/booking_history_details_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
        title: Text("Booking #${b.bookingCode}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PACKAGE CARD =================
            _packageCard(b),

            const SizedBox(height: 20),

            // ================= BOOKING DETAILS =================
            _detailsCard(b),

            const SizedBox(height: 24),

            // ================= VISUAL PROOF =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "VISUAL PROOF",
                  style: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Completed", style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _mediaSection(
              title: "Before",
              images: b.images.where((e) => e.type == "BEFORE").toList(),
              videos: b.videos.where((e) => e.type == "BEFORE").toList(),
            ),
            const SizedBox(height: 16),
            _mediaSection(
              title: "After",
              images: b.images.where((e) => e.type == "AFTER").toList(),
              videos: b.videos.where((e) => e.type == "AFTER").toList(),
            ),

            const SizedBox(height: 24),

            // ================= REVIEW =================
            //_reviewCard(),

            const SizedBox(height: 90),
          ],
        ),
      ),

      // ================= BOOK AGAIN =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Book Again",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12),
        ],
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
              Text(
                "₹${b.amount}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            b.vehicle,
            style: const TextStyle(color: Colors.black54),
          ),
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DETAILS =================
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
            "Date & Time",
            b.scheduledAt == null
                ? "N/A"
                : DateFormat('dd MMM yyyy • hh:mm a')
                    .format(b.scheduledAt!.toLocal()),
          ),
          const Divider(),
          _detailRow(
            Icons.location_on,
            "Service",
            b.serviceName, // ✅ FIXED
          ),
          const Divider(),
          _detailRow(
            Icons.credit_card,
            "Payment",
            b.status,
          ),
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
Widget _imageCard({
  required String title,
  required List<String> images,
}) {
  if (images.isEmpty) {
    return const Text("No images available");
  }

  final imageUrl = Constants.imageBaseUrl + images.first.replaceAll("\\", "/");

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
    return const Text("No media available");
  }

  final List<Widget> mediaWidgets = [];

  // 🔹 Images
  for (var img in images) {
    final imageUrl = Constants.imageBaseUrl + img.url.replaceAll("\\", "/");

    mediaWidgets.add(
      GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(imageUrl: imageUrl),
          );
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

    final videoUrl =
        "${Constants.imageBaseUrl}/api/employee/bookings/stream/$fileName";

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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
