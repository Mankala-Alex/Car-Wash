import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/offers_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/profile_repository.dart';

class OffersController extends GetxController {
  final ProfileRepository repository = ProfileRepository();

  var offers = <Offersmodel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchOffers();
    super.onInit();
  }

  Future<void> fetchOffers() async {
    try {
      isLoading.value = true;

      final response = await repository.fetchoffers();
      List data = response.data;

      offers.value = data.map((e) => Offersmodel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching offers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert expiry days → actual date
  String calculateExpiryDate(int days) {
    final expiryDate = DateTime.now().add(Duration(days: days));
    return "${expiryDate.day}-${expiryDate.month}-${expiryDate.year}";
  }
}
