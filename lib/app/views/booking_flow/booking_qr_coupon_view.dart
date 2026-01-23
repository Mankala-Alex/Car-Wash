import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/booking_qr_coupon_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/loader.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';

class BookingQrCouponView extends GetView<BookingQrCouponController> {
  const BookingQrCouponView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Your Coupon"),
        centerTitle: true,
        backgroundColor: AppColors.bgLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          // 🔄 Loading state
          if (controller.isLoading.value) {
            return loader();
          }

          // ❌ No coupon
          if (controller.coupon.value == null) {
            return const Center(
              child: Text(
                "Coupon not available",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final coupon = controller.coupon.value!;

          return Column(
            children: [
              // 🎟 DISCOUNT
              Text(
                "${coupon.discountPercent}% OFF",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 🟢 STATUS
              Text(
                coupon.status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      coupon.status == "ACTIVE" ? Colors.green : Colors.orange,
                ),
              ),

              const SizedBox(height: 20),

              // 🔳 QR CODE with fade-in animation
              AnimatedOpacity(
                opacity: controller.showQrFade.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 3500),
                curve: Curves.easeInOut,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: coupon.couponCode,
                    size: 240,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔑 COUPON CODE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  coupon.couponCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📅 EXPIRY
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Valid till ${controller.formattedExpiry}",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 10),

              const SizedBox(height: 24),

              // ✅ DONE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(Routes.dashboard);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:car_wash_customer_app/app/controllers/profile/qr_coupon_controller.dart';
// import 'package:car_wash_customer_app/app/theme/app_theme.dart';

// class BookingQrCouponView extends GetView<QrCouponController> {
//   const BookingQrCouponView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Coupon"),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final c = controller.coupon.value;
//         if (c == null) {
//           return const Center(child: Text("No coupon found"));
//         }

//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: const [
//                     BoxShadow(
//                       blurRadius: 12,
//                       color: Colors.black12,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "${c.discountPercent}% OFF",
//                       style: const TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.secondaryLight,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       c.couponCode,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         letterSpacing: 1.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text("Expires on ${controller.formattedExpiry}"),
//                     const SizedBox(height: 20),
//                     _statusChip(c.status),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               if (!controller.isRedeemable)
//                 const Text(
//                   "Coupon will activate after service completion",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _statusChip(String status) {
//     Color color;
//     switch (status) {
//       case "ACTIVE":
//         color = Colors.green;
//         break;
//       case "USED":
//         color = Colors.grey;
//         break;
//       default:
//         color = Colors.orange;
//     }

//     return Chip(
//       label: Text(status),
//       backgroundColor: color.withOpacity(0.15),
//       labelStyle: TextStyle(color: color),
//     );
//   }
// }
