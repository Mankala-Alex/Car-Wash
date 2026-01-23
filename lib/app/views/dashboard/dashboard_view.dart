import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/views/dashboard/page1_view.dart';
import 'package:car_wash_customer_app/app/views/dashboard/page2_view.dart';
import 'package:car_wash_customer_app/app/views/dashboard/page4_view.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

  // Correct way — get the controller created by Bindings
  @override
  final DashboardController controller = Get.find<DashboardController>();

  final List<Widget> _pages = [
    Page1View(),
    const Page2View(),
    //const Page3View(),
    const Page4View(),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final customTheme = CustomTheme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgLight,

      // --------------------------- BODY ---------------------------
      body: Obx(() => _pages[controller.selectedIndex.value]),

      // --------------------- BOTTOM NAVIGATION ---------------------
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: Obx(() {
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.bgLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 20,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.bgLight,
              currentIndex: controller.selectedIndex.value,
              onTap: controller.updateIndex,
              selectedItemColor: customTheme.primaryColor,
              unselectedItemColor: customTheme.textLightGray,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(3, (index) {
                final labels = [
                  "Home".tr,
                  "My Bookings".tr,
                  //"Wallet".tr,
                  "Profile".tr,
                ];

                final icons = [
                  'assets/carwash/logo/home.png',
                  'assets/carwash/logo/history.png',
                  //'assets/carwash/logo/home.png',
                  'assets/carwash/logo/profile.png',
                ];

                return BottomNavigationBarItem(
                  icon: SizedBox(
                    width: screenWidth * 0.06,
                    height: screenHeight * 0.025,
                    child: Image.asset(
                      icons[index],
                      color: controller.selectedIndex.value == index
                          ? customTheme.primaryColor
                          : customTheme.textLightGray,
                    ),
                  ),
                  label: labels[index],
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
