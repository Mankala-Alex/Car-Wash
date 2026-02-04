import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/config/constants.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/booking_history_details_controller.dart';
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

            _imageCard(
              title: "Before",
              images: b.beforeImages,
            ),

            const SizedBox(height: 16),

            _imageCard(
              title: "After",
              images: b.afterImages,
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
            b.scheduledAt,
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:car_wash_customer_app/app/config/constants.dart';
// import 'package:car_wash_customer_app/app/controllers/dashboard/booking_history_details_controller.dart';
// import 'package:car_wash_customer_app/app/theme/app_theme.dart';

// class BookingHistoryDetailsView
//     extends GetView<BookingHistoryDetailsController> {
//   const BookingHistoryDetailsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final b = controller.booking;

//     return Scaffold(
//       backgroundColor: AppColors.bgLight,
//       appBar: AppBar(
//         title: const Text("Service Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _info("Service", b.serviceName),
//             _info("Customer", b.customerName),
//             _info("Vehicle", b.vehicle),
//             _info("Amount", "₹${b.amount}"),
//             _info("Status", b.status),
//             const SizedBox(height: 24),
//             const Text("Before Wash",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             _imageRow(b.beforeImages),
//             const SizedBox(height: 24),
//             const Text("After Wash",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             _imageRow(b.afterImages),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _info(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         children: [
//           Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Widget _imageRow(List<String> images) {
//     if (images.isEmpty) {
//       return const Text("No images available");
//     }

//     return SizedBox(
//       height: 140,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: images.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final path = images[i].replaceAll("\\", "/");

//           return ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child: Image.network(
//               Constants.imageBaseUrl + path,
//               width: 180,
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
