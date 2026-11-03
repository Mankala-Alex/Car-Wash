import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/help_center_controller.dart';
import 'package:car_wash_customer_app/app/models/support/support_models.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

/// Help Center landing screen: FAQ categories + entry point to live chat.
class HelpCenterView extends GetView<HelpCenterController> {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "help_center_title".tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.secondaryLight,
        onRefresh: controller.loadCategories,
        child: Obx(() {
          if (controller.isLoading.value && controller.categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryLight),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              _header(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "select_category_hint".tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (controller.categories.isEmpty)
                _emptyState()
              else
                ...controller.categories.map(_categoryTile),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _chatCard(),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "how_can_we_help".tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "find_quick_answers_to_your_questions".tr,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ---------------- Category tile ----------------
  Widget _categoryTile(FaqCategory category) {
    return GestureDetector(
      onTap: () => controller.openCategory(category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLightGrayLight),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.bgLightSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(category.icon),
                size: 21,
                color: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.localizedName(controller.languageCode),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDefaultLight,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textLightGrayLight,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Chat with support ----------------
  Widget _chatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLightSecondaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLightGrayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: AppColors.secondaryLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "need_more_help".tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "support_chat_intro".tr,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLightGrayLight,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: controller.startChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "chat_with_support".tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Empty state ----------------
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        children: [
          const Icon(
            Icons.help_outline,
            size: 46,
            color: AppColors.textLightGrayLight,
          ),
          const SizedBox(height: 10),
          Text(
            "no_help_content".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLightGrayLight,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: controller.loadCategories,
            child: Text("retry".tr),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'calendar':
        return Icons.calendar_month_outlined;
      case 'card':
        return Icons.credit_card;
      case 'refund':
        return Icons.currency_exchange;
      case 'technician':
        return Icons.engineering_outlined;
      case 'star':
        return Icons.star_border;
      case 'ticket':
        return Icons.local_offer_outlined;
      case 'person':
        return Icons.person_outline;
      case 'bug':
        return Icons.bug_report_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
