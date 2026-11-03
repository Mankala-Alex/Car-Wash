import 'package:get/get.dart';

import '../../helpers/flutter_toast.dart';
import '../../models/support/support_models.dart';
import '../../repositories/support/support_repository.dart';
import '../../routes/app_routes.dart';

/// Landing screen of the Help Center: the list of FAQ categories.
class HelpCenterController extends GetxController {
  final SupportRepository _repository = SupportRepository();

  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  RxList<FaqCategory> categories = <FaqCategory>[].obs;

  /// True when the API failed and the built-in category list is shown instead,
  /// so the customer can still browse the help topics.
  RxBool isUsingFallback = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  String get languageCode => Get.locale?.languageCode ?? 'en';

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.fetchCategories();

      if (result.isEmpty) {
        _useFallback();
      } else {
        categories.value = result;
        isUsingFallback.value = false;
      }
    } catch (e) {
      print("❌ Help Center categories failed: $e");
      _useFallback();

      final message = SupportRepository.errorMessage(
        e,
        'unable_to_load_help_center'.tr,
      );
      errorMessage.value = message;
      errorToast(message);
    } finally {
      isLoading.value = false;
    }
  }

  void _useFallback() {
    isUsingFallback.value = true;
    categories.value = _fallbackCategories;
  }

  /// Same ids as the backend seed, so opening a category still works as soon
  /// as the connection is back.
  List<FaqCategory> get _fallbackCategories => [
        const FaqCategory(
          id: 'booking_issues',
          nameEn: 'Booking Issues',
          nameAr: 'مشاكل الحجز',
          icon: 'calendar',
        ),
        const FaqCategory(
          id: 'payment_issues',
          nameEn: 'Payment Issues',
          nameAr: 'مشاكل الدفع',
          icon: 'card',
        ),
        const FaqCategory(
          id: 'cancellation_refund',
          nameEn: 'Cancellation and Refund',
          nameAr: 'الإلغاء والاسترداد',
          icon: 'refund',
        ),
        const FaqCategory(
          id: 'technician_issues',
          nameEn: 'Technician Issues',
          nameAr: 'مشاكل الفني',
          icon: 'technician',
        ),
        const FaqCategory(
          id: 'service_quality',
          nameEn: 'Service Quality',
          nameAr: 'جودة الخدمة',
          icon: 'star',
        ),
        const FaqCategory(
          id: 'coupons_offers',
          nameEn: 'Coupons and Offers',
          nameAr: 'الكوبونات والعروض',
          icon: 'ticket',
        ),
        const FaqCategory(
          id: 'account_issues',
          nameEn: 'Account Issues',
          nameAr: 'مشاكل الحساب',
          icon: 'person',
        ),
        const FaqCategory(
          id: 'app_issues',
          nameEn: 'App Technical Issues',
          nameAr: 'مشاكل التطبيق التقنية',
          icon: 'bug',
        ),
        const FaqCategory(
          id: 'other_issues',
          nameEn: 'Other Issues',
          nameAr: 'مشاكل أخرى',
          icon: 'help',
        ),
      ];

  void openCategory(FaqCategory category) {
    Get.toNamed(Routes.faqChat, arguments: category);
  }

  /// "Chat with Support" straight from the Help Center (no FAQ context).
  void startChat() {
    Get.toNamed(Routes.supportChat);
  }
}
