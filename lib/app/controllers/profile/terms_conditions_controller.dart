import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/legal_document_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/profile_repository.dart';

class TermsConditionsController extends GetxController {
  final ProfileRepository repository = ProfileRepository();

  final termsDocument = Rxn<LegalDocumentModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    try {
      isLoading.value = true;

      final response = await repository.getTermsAndConditions();
      final data = response.data;

      if (data is Map<String, dynamic>) {
        termsDocument.value = LegalDocumentModel.fromJson(data);
      } else if (data is Map) {
        termsDocument.value =
            LegalDocumentModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print("❌ Error fetching Terms & Conditions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get pageTitle {
    return termsDocument.value?.getLocalizedTitle() ?? 'Terms & Conditions';
  }

  String get documentContent {
    return termsDocument.value?.getLocalizedContent() ?? '';
  }
}
