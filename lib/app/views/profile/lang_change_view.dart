import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/lang_change_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class LangChangeView extends GetView<LangChangeController> {
  const LangChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Change Language",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.s,
        children: [
          const SizedBox(height: 35),

          // ---------------- ENGLISH CARD ----------------
          Obx(() {
            return _languageCard(
              label: "English",
              value: "en",
              isSelected: controller.selectedValue.value == "en",
              onTap: () => controller.selectedValue.value = "en",
            );
          }),

          const SizedBox(height: 18),

          // ---------------- ARABIC CARD ----------------
          Obx(() {
            return _languageCard(
              label: "العربية",
              value: "ar",
              isSelected: controller.selectedValue.value == "ar",
              onTap: () => controller.selectedValue.value = "ar",
            );
          }),

          const SizedBox(height: 40),

          // ---------------- CONTINUE BUTTON ----------------
          Obx(() {
            bool enabled = controller.selectedValue.value.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: enabled ? controller.applyLanguageChange : null,
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
                    "Save",
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

  // ======================================================
  // SAME CARD UI AS YOUR SELECT LANGUAGE SCREEN
  // ======================================================
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
            // CUSTOM RADIO
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

            // LABEL
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
