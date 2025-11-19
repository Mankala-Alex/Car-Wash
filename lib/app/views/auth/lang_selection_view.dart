import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth/lang_selection_controller.dart';

class LangSelectionView extends GetView<LangSelectionController> {
  const LangSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/carwash/splash_2.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Obx(() {
            return Stack(
              children: [
                Positioned(
                  top: Get.height * 0.62,
                  left: Get.width * 0.05,
                  child: _languageTile(
                    label: "English",
                    value: "en",
                    isSelected: controller.selectedValue.value == "en",
                    onTap: () => controller.selectedValue.value = "en",
                    reverse: false, // radio then text
                  ),
                ),
                Positioned(
                  top: Get.height * 0.62,
                  right: Get.width * 0.05,
                  child: _languageTile(
                    label: "العربية",
                    value: "ar",
                    isSelected: controller.selectedValue.value == "ar",
                    onTap: () => controller.selectedValue.value = "ar",
                    reverse: true, // text then radio
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            final enabled = controller.selectedValue.value.isNotEmpty;

            return Positioned(
              bottom: 45,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: enabled ? controller.changeLanguage : null,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM LANGUAGE TILE (No Radio widget)
  // -------------------------------------------------------------
  Widget _languageTile({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required bool reverse,
  }) {
    List<Widget> row = [
      _customRadio(isSelected),
      const SizedBox(width: 12),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reverse ? row.reversed.toList() : row,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM CIRCLE RADIO (NO FLUTTER RADIO)
  // -------------------------------------------------------------
  Widget _customRadio(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: selected ? Colors.white : Colors.transparent,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 24,
                  spreadRadius: 4,
                )
              ]
            : [],
      ),
    );
  }
}

// // my_new_app/lib/app/views/lang_selection_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth/lang_selection_controller.dart';

// class LangSelectionView extends GetView<LangSelectionController> {
//   const LangSelectionView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('select_language'.tr)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 controller.selectedValue.value = 'en';
//                 controller.changeLanguage();
//               },
//               child: Text('english'.tr),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 controller.selectedValue.value = 'ar';
//                 controller.changeLanguage();
//               },
//               child: Text('arabic'.tr),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
