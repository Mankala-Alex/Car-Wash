import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/privacy_policy_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.pageTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final htmlContent = controller.documentContent;
        if (htmlContent.isEmpty) {
          return const Center(
            child: Text('No privacy policy available.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: htmlContent,
            style: {
              'body': Style(
                margin: Margins.zero,
                fontSize: FontSize(15),
                lineHeight: const LineHeight(1.6),
                color: const Color(0xFF333333),
              ),
              'p': Style(margin: Margins.only(bottom: 12)),
              'ul': Style(margin: Margins.only(bottom: 12, left: 18)),
              'li': Style(margin: Margins.only(bottom: 6)),
              'strong': Style(fontWeight: FontWeight.w700),
            },
          ),
        );
      }),
    );
  }
}
