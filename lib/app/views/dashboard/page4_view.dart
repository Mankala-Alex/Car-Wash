import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class Page4View extends GetView<DashboardController> {
  const Page4View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
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
          child: Column(
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

              const SizedBox(height: 30),

              // ---------- Avatar ----------
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/carwash/avatar.png', // <-- your profile image
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          return const Icon(Icons.person,
                              size: 80, color: Colors.grey);
                        },
                      ),
                    ),
                  ),

                  // Edit icon
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- Name ----------
              const Text(
                "John Doe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "john.doe@email.com",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // ---------- Card Container ----------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _menuTile(Icons.directions_car, "My Car",
                        () => Get.toNamed(Routes.carlist)),
                    const Divider(height: 0),
                    _menuTile(Icons.location_on_outlined, "My Locations",
                        () => Get.toNamed(Routes.locationslist)),
                    const Divider(height: 0),
                    _menuTile(Icons.language, "Language Selection",
                        () => Get.toNamed(Routes.langchange)),
                    const Divider(height: 0),
                    _menuTile(Icons.headset_mic_outlined, "Help & Support",
                        () => Get.toNamed(Routes.help)),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ---------- Logout Button ----------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Tile Widget ----------------
  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // <-- Add this
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.bgBlackLight, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
