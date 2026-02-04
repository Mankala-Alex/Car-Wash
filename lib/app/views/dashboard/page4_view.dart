import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custome_confirmation_dialog.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class Page4View extends GetView<DashboardController> {
  const Page4View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: AppColors.bgLight,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ---------- AppBar ----------
                // Center(
                //   child: Row(
                //     children: [
                //       const Text(
                //         "My Profile",
                //         style: TextStyle(
                //           fontSize: 22,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       const Spacer(),
                //       const SizedBox(width: 42),
                //     ],
                //   ),
                // ),

                // ---------- Avatar ----------

                const SizedBox(height: 20),

                // ---------- Name ----------
                Obx(() => Text(
                      controller.customerName.value.isEmpty
                          ? "Guest User"
                          : controller.customerName.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.customerEmail.value.isEmpty
                          ? "No Email"
                          : controller.customerEmail.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    )),

                const SizedBox(height: 30),
// ---------- Quick Actions ----------
                Row(
                  children: [
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.assignment_outlined,
                        title: "My\nbookings",
                        onTap: () {
                          controller.selectedIndex.value = 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.car_crash_outlined,
                        title: "My\nCars",
                        onTap: () {
                          Get.toNamed(Routes.carlist);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expanded(
                    //   child: _quickActionCard(
                    //     icon: Icons.headset_mic_outlined,
                    //     title: "Help &\nsupport",
                    //     onTap: () {
                    //       // TODO: route
                    //     },
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------- Card Container ----------
                Column(
                  children: [
                    const SizedBox(height: 10),
                    _simpleMenuTile(
                      title: "My Locations",
                      onTap: () => Get.toNamed(Routes.locationslist),
                    ),
                    const SizedBox(height: 10),
                    _simpleMenuTile(
                      title: "Language Selection",
                      onTap: () => Get.toNamed(Routes.langchange),
                    ),
                    const SizedBox(height: 10),
                    _simpleMenuTile(
                      title: "My Coupons",
                      onTap: () => Get.toNamed(Routes.mycoupons),
                    ),
                    const SizedBox(height: 10),
                    _simpleMenuTile(
                      title: "Offers",
                      onTap: () => Get.toNamed(Routes.offers),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------- Logout Button ----------
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      CustomConfirmationDialog(
                        header: "Logout",
                        body: "Are you sure you want to logout?",
                        yesText: "Logout",
                        noText: "Cancel",
                        onYes: () {
                          Get.back(); // close dialog
                          controller.logout(); // actual logout
                        },
                        onNo: () {
                          Get.back(); // just close dialog
                        },
                      ),
                      barrierDismissible: false,
                    );
                  },
                  child: Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffffe8e8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.black,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleMenuTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 28,
              width: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
