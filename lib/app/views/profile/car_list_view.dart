import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/car_list_controller.dart';
import 'package:my_new_app/app/custome_widgets/skeleton_box.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class CarListView extends GetView<CarListController> {
  const CarListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "My Vehicles",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ADD BUTTON → Same AddCarView
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryLight,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () async {
          final result = await Get.toNamed(Routes.addcar);

          if (result == true) {
            controller.fetchVehicles(); // refresh list
          }
        },
      ),

      body: Obx(() {
        // ===== LOADING → SKELETON CARDS =====
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (_, __) {
              return Container(
                margin: const EdgeInsets.only(bottom: 22),
                child: const SkeletonBox(
                  width: double.infinity,
                  height: 240, // image + text height
                  radius: 26,
                ),
              );
            },
          );
        }

        // ===== EMPTY =====
        if (controller.customerVehicles.isEmpty) {
          return const Center(
            child: Text(
              "No Vehicles Added",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // ===== REAL DATA =====
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.customerVehicles.length,
          itemBuilder: (_, index) {
            final v = controller.customerVehicles[index];

            return _vehicleCard(
              imagePath: "assets/carwash/splash_2.jpg", // static image
              title: "${v["make"]} ${v["model"]}",
              subtitle: v["vehicle_number"],
            );
          },
        );
      }),
    );
  }

  Widget _vehicleCard({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,

              // 🔥 IMAGE-LEVEL SKELETON
              frameBuilder: (context, child, frame, _) {
                if (frame == null) {
                  return const SkeletonBox(
                    width: double.infinity,
                    height: 160,
                    radius: 22,
                  );
                }
                return child;
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
