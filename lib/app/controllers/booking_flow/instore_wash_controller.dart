import 'package:get/get.dart';
import 'package:my_new_app/app/models/instores_model.dart';
import 'package:my_new_app/app/repositories/instore_repository.dart';

class InstoreWashController extends GetxController {
  final InstoreRepository repository = InstoreRepository();

  RxBool isLoading = false.obs;
  RxList<Instoresmodel> stores = <Instoresmodel>[].obs;

  @override
  void onInit() {
    fetchInStoreWashStores();
    super.onInit();
  }

  Future<void> fetchInStoreWashStores() async {
    try {
      isLoading.value = true;

      final response = await repository.getInStoreWashStores();
      List data = response.data;

      stores.value = data.map((e) => Instoresmodel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching stores: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
