import 'package:get/get.dart';

class HelpNSupportController extends GetxController {
  // which FAQ is expanded
  RxInt expandedFaq = (-1).obs;

  // FAQ content
  final faqs = [
    {
      "id": 1,
      "question": "How do I cancel or reschedule a booking?",
      "answer":
          "You can cancel or reschedule your booking from the 'My Bookings' section. Charges may apply based on policy."
    },
    {
      "id": 2,
      "question": "What payment methods are accepted?",
      "answer":
          "We accept UPI, debit/credit cards, net banking, and wallet payments."
    },
    {
      "id": 3,
      "question": "How do I apply promo codes or coupons?",
      "answer":
          "Promo codes can be applied during the checkout process on the payment page."
    },
    {
      "id": 4,
      "question": "I forgot my password. What should I do?",
      "answer":
          "You can reset your password using the 'Forgot Password' option on the login page."
    },
  ];

  void toggleFAQ(int id) {
    expandedFaq.value = expandedFaq.value == id ? -1 : id;
  }
}
