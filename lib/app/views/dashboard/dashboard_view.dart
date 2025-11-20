import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/views/dashboard/page1_view.dart';
import 'package:my_new_app/app/views/dashboard/page2_view.dart';
import 'package:my_new_app/app/views/dashboard/page3_view.dart';
import 'package:my_new_app/app/views/dashboard/page4_view.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

  final List<Widget> _pages = [
    const Page1View(),
    const Page2View(),
    const Page3View(),
    const Page4View()
  ];
  @override
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Container(
        decoration: BoxDecoration(color: CustomTheme.of(context).bgColor),
        child: Obx(() => _pages[controller.selectedIndex.value]),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disables ripple effect
          highlightColor: const Color.fromARGB(0, 0, 0, 0),
        ),
        child: Obx(() {
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.bgLight,
              // border: Border(
              //   top: BorderSide(
              //     width: 1,
              //     color: customTheme.borderLightGray,
              //   ),
              // ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3, // Increases the spread of the shadow
                  spreadRadius: 1, // Controls how far the shadow extends
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
              selectedItemColor: AppColors.secondaryLight,
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
              items: List.generate(4, (index) {
                List<String> labels = [
                  "Home".tr,
                  "My Bookings".tr,
                  "Wallet".tr,
                  "Profile".tr,
                ];
                List<String> icons = [
                  'assets/images/home.svg',
                  'assets/images/appoinment.svg',
                  'assets/images/records.svg',
                  'assets/images/user.svg',
                ];
                return BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // if (controller.selectedIndex.value == index)
                      //   Positioned(
                      //     top: -40.5, // Adjust position above the icon
                      //     child: Image.asset(
                      //       "assets/images/active_menu_new.png",
                      //       width: 100,
                      //     ),
                      //   ),
                      Container(
                        // margin: EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        child: SizedBox(
                          width: screenWidth * 0.06, //25
                          height: screenHeight * 0.025, //25
                          child: SvgPicture.asset(
                            icons[index],
                            colorFilter: ColorFilter.mode(
                              controller.selectedIndex.value == index
                                  ? AppColors.bgBlackLight
                                  : customTheme.textLightGray,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
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
