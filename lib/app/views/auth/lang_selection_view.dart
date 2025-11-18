// my_new_app/lib/app/views/lang_selection_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth/lang_selection_controller.dart';

class LangSelectionView extends GetView<LangSelectionController> {
  const LangSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('select_language'.tr)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                controller.selectedValue.value = 'en';
                controller.changeLanguage();
              },
              child: Text('english'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                controller.selectedValue.value = 'ar';
                controller.changeLanguage();
              },
              child: Text('arabic'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
