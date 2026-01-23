import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/coupons_list_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class CouponsListView extends GetView<CouponsListController> {
  const CouponsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("My Coupons"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Column(
            children: [
              // ===== TOP BANNER SKELETON =====
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: SkeletonBox(
                  width: double.infinity,
                  height: 135,
                  radius: 26,
                ),
              ),

              // ===== COUPON GRID SKELETON =====
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4, // fake count while loading
                  itemBuilder: (_, __) {
                    return const SkeletonBox(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 18,
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.coupons.isEmpty) {
          return const Center(child: Text("No coupons available"));
        }

        return Column(
          children: [
            // ================= TOP REWARD BANNER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                height: 135, // ⬅️ increased height
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(26), // ⬅️ smoother corners
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFB347),
                      Color(0xFFFFCC33),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "You've got new\nrewards!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),

            // ================= COUPONS GRID =================
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.coupons.length,
                itemBuilder: (_, index) {
                  final coupon = controller.coupons[index];
                  final isActive = controller.canUse(coupon);

                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.borderGray,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= DISCOUNT ICON =================
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3E0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.percent,
                                color: AppColors.secondaryLight,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 5),

                            // ================= DISCOUNT TEXT =================
                            Text(
                              "${coupon.discountPercent}% OFF",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "Expires: ${controller.formatDate(coupon.expiresAt)}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),

                        const Spacer(),

                        // ================= BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(
                                Routes.coupondetailsview,
                                arguments: {
                                  "coupon_code": coupon.couponCode,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? AppColors.secondaryLight
                                  : Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isActive ? "Use Now" : "Not Active",
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.black45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
