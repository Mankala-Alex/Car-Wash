import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/legal_document_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/profile_repository.dart';

class PrivacyPolicyController extends GetxController {
  final ProfileRepository repository = ProfileRepository();

  final policyDocument = Rxn<LegalDocumentModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;

      final response = await repository.getPrivacyPolicy();
      final data = response.data;

      if (data is Map<String, dynamic>) {
        policyDocument.value = LegalDocumentModel.fromJson(data);
      } else if (data is Map) {
        policyDocument.value =
            LegalDocumentModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print("❌ Error fetching Privacy Policy: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get pageTitle {
    return policyDocument.value?.getLocalizedTitle() ?? 'Privacy Policy';
  }

  String get documentContent {
    return policyDocument.value?.getLocalizedContent() ?? '';
  }
}
