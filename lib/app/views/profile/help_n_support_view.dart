import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/help_n_support_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class HelpNSupportView extends GetView<HelpNSupportController> {
  const HelpNSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "help_support".tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- FAQ Header Section ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Text(
                "find_quick_answers_to_your_questions".tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- FAQ TITLE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "frequently_asked_questions".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- FAQ LIST ----------------
            Obx(
              () => Column(
                children: controller.faqs.map((faq) {
                  bool expanded = controller.expandedFaq.value == faq["id"];

                  return GestureDetector(
                    onTap: () {
                      controller.toggleFAQ(faq["id"] as int);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq["question"] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              )
                            ],
                          ),

                          // --------- SMOOTH EXPAND / COLLAPSE ------------
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: expanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      faq["answer".tr] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- CONTACT SUPPORT FORM ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "contact_support".tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "contact_support_message".tr,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    _inputField("full_name".tr),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                            child: _inputField("email".tr + " (optional)")),
                        const SizedBox(width: 12),
                        Expanded(child: _inputField("mobile_number".tr)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _dropdownField("general_inquiry".tr),
                    const SizedBox(height: 12),

                    _inputField("booking_id_if_relevant".tr),
                    const SizedBox(height: 12),

                    _textArea("describe_your_issue_or_question".tr),
                    const SizedBox(height: 12),

                    // Send button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "send_message".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------------- Input Field ----------------
  Widget _inputField(String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // ---------------- Dropdown Field ----------------
  Widget _dropdownField(String label) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }

  // ---------------- Text Area ----------------
  Widget _textArea(String hint) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: TextField(
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
