import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:my_new_app/app/controllers/booking_flow/confirmation_page_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class ConfirmationPageView extends GetView<ConfirmationPageController> {
  const ConfirmationPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 40),

              SizedBox(
                width: 240, // control size here
                height: 240,
                child: Lottie.asset(
                  'assets/carwash/animations/success.json',
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // TITLE
              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 20),

              // 📄 BOOKING CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: controller.image.isNotEmpty &&
                              controller.image.startsWith("http")
                          ? Image.network(
                              controller.image,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                "assets/carwash/default_service.png",
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              controller.image.isNotEmpty
                                  ? controller.image
                                  : "assets/carwash/default_service.png",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),

                    const SizedBox(width: 14),

                    // DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            controller.serviceName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Total: SAR ${controller.amount}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // DONE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.bookingqrcouponview,
                      arguments: {
                        "booking_code": controller.bookingCode,
                      },
                    );
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
