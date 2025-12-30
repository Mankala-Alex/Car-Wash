import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/custome_widgets/wheel_loader.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../../controllers/profile/coupon_details_controller.dart';

class CouponDetailsView extends GetView<CouponDetailsController> {
  const CouponDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Coupon Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return wheelloader();
        }

        final c = controller.coupon.value;
        if (c == null) {
          return const Center(child: Text("Coupon not found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= MAIN CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ICON
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: AppColors.secondaryLight,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // DISCOUNT
                    Text(
                      "${c.discountPercent}% OFF",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DASHED DIVIDER
                    Divider(color: Colors.grey.shade300),

                    const SizedBox(height: 20),

                    // QR
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: QrImageView(
                        data: c.couponCode,
                        size: 200,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // COUPON CODE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c.couponCode,
                            style: const TextStyle(
                              fontSize: 18,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.copy,
                            color: AppColors.secondaryLight,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // EXPIRY + STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Expires on\n${controller.formattedExpiry}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isActive
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: controller.isActive
                                    ? Colors.green
                                    : Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.displayStatus,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: controller.isActive
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Scan this code at the terminal or show it\nto a cashier to redeem your discount.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }),
    );
  }
}
