import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/add_car_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class AddCarView extends GetView<AddCarController> {
  const AddCarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Select Vehicle",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [SizedBox(width: 40)],
      ),

      // ------------------ FIXED BOTTOM BUTTON ------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: GestureDetector(
          onTap: () {
            // Your continue logic
          },
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),

      // ------------------ SCROLLABLE BODY ------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(),
              const SizedBox(height: 16),
              _filterBar(),
              const SizedBox(height: 16),

              Obx(() {
                final cars = controller.filteredCars;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .90,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Obx(
                        () => _carTile(car["img"]!, car["name"]!, index));
                  },
                );
              }),

              const SizedBox(height: 100), // space above bottom button
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Search Bar
  // ----------------------------------------------------------
  Widget _searchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: controller.updateSearch,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search for a car",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Icon(Icons.filter_list, color: Colors.grey),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // Filter Chips
  // ----------------------------------------------------------
  Widget _filterBar() {
    return Obx(() {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _chip("All", 0),
          _chip("<1500cc", 1),
          _chip("1500–2500cc", 2),
          _chip(">2500cc", 3),
        ],
      );
    });
  }

  Widget _chip(String label, int index) {
    bool isSelected = controller.selectedFilter.value == index;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => controller.selectFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.bgLightSecondaryLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textDefaultLight : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.close, size: 16, color: AppColors.errorLight),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Car Tile (Selectable)
  // ----------------------------------------------------------
  Widget _carTile(String img, String name, int index) {
    bool isSelected = controller.selectedCarIndex.value == index;

    return InkWell(
      onTap: () => controller.selectCar(index),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                img,
                height: 80,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
