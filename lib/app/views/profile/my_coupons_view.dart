import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/my_coupons_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class MyCouponsView extends GetView<MyCouponsController> {
  const MyCouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          // 🔥 TOP HEADER WITH BACK BUTTON
          Container(
            width: double.infinity,
            height: 170,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // 👈 Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ⭐ Keep title centered even with back icon
                    const Expanded(
                      child: Text(
                        "My Coupons",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 👻 Dummy space to balance UI
                    const SizedBox(width: 32),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 GRID LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _gridCard(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(int index) {
    final List<String> titles = [
      "Scratch & Win",
      "Cashback Offer",
      "Refer Bonus",
      "Free Wash",
    ];

    final List<IconData> icons = [
      Icons.star,
      Icons.card_giftcard,
      Icons.people,
      Icons.local_car_wash,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 12),

          // Title
          Text(
            titles[index],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          // Icon
          Icon(
            icons[index],
            size: 50,
            color: Colors.black87,
          ),

          // 🔘 Button at bottom
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Get.toNamed(Routes.qrcouponview);
              },
              child: const Text(
                "View Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDefaultLight,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
