import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import '../../controllers/auth/lang_selection_controller.dart';

class LangSelectionView extends GetView<LangSelectionController> {
  const LangSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LangSelectionController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Get.back(),
        // ),
        title: const Text(
          "Choose Your Language",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [SizedBox(width: 40)],
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 35),

          // ================== ENGLISH CARD ==================
          Obx(() {
            return _languageCard(
              label: "English",
              value: "en",
              isSelected: controller.selectedValue.value == "en",
              onTap: () => controller.selectedValue.value = "en",
            );
          }),

          const SizedBox(height: 18),
          // ================== ARABIC CARD ==================
          Obx(() {
            return _languageCard(
              label: "العربية",
              value: "ar",
              isSelected: controller.selectedValue.value == "ar",
              onTap: () => controller.selectedValue.value = "ar",
            );
          }),

          const Spacer(),

          // ================== CONTINUE BUTTON ==================
          Obx(() {
            bool enabled = controller.selectedValue.value.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                onTap: enabled ? controller.changeLanguage : null,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.secondaryLight
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.black45,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===================================================================
  // PROFESSIONAL VERTICAL CARD DESIGN
  // ===================================================================
  Widget _languageCard({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondaryLight : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.12 : 0.05),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // -------- Custom Radio --------
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.borderGray : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.secondaryLight : Colors.white,
              ),
            ),

            const SizedBox(width: 16),

            // -------- Label --------
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
