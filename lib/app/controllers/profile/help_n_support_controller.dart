import 'package:get/get.dart';

class HelpNSupportController extends GetxController {
  // which FAQ is expanded
  RxInt expandedFaq = (-1).obs;

  // FAQ content (localized)
  List<Map<String, dynamic>> get faqs => [
        {
          "id": 1,
          "question": "faq_q1".tr,
          "answer": "faq_a1".tr,
        },
        {
          "id": 2,
          "question": "faq_q2".tr,
          "answer": "faq_a2".tr,
        },
        {
          "id": 3,
          "question": "faq_q3".tr,
          "answer": "faq_a3".tr,
        },
        {
          "id": 4,
          "question": "faq_q4".tr,
          "answer": "faq_a4".tr,
        },
      ];

  void toggleFAQ(int id) {
    expandedFaq.value = expandedFaq.value == id ? -1 : id;
  }
}
