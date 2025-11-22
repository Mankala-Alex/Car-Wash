import 'package:get/get.dart';

class AddCarController extends GetxController {
  // -------- FILTER SELECTION --------
  var selectedFilter = 0.obs;

  void selectFilter(int index) {
    if (selectedFilter.value == index) {
      selectedFilter.value = 0; // toggle off
    } else {
      selectedFilter.value = index;
    }
  }

  // -------- SEARCH --------
  var searchQuery = "".obs;

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  // -------- CAR SELECTION --------
  var selectedCarIndex = (-1).obs;

  void selectCar(int index) {
    selectedCarIndex.value = index;
  }

  // -------- FULL CAR LIST --------
  final carList = <Map<String, String>>[
    {"name": "Toyota Camry.png", "img": "assets/carwash/toyota_camry.png"},
    {"name": "Honda Civic", "img": "assets/carwash/Honda_Civic.png"},
    {
      "name": "Mitsubishi Pajero",
      "img": "assets/carwash/Mitsubishi_Pajero.png"
    },
    {"name": "Mercedes C-Class", "img": "assets/carwash/full_wash_car.png"},
    {"name": "Ford Mustang", "img": "assets/carwash/instore1.png"},
    {"name": "Honda Civic", "img": "assets/carwash/features/langcar3.png"},
    {"name": "Porsche 911", "img": "assets/carwash/whitecar.png"},
    {"name": "Toyota Camry", "img": "assets/carwash/toyota_camry.png"},
  ].obs;

  // -------- FILTERED + SEARCHED RESULT --------
  List<Map<String, String>> get filteredCars {
    return carList.where((car) {
      final name = car["name"]!.toLowerCase();
      final query = searchQuery.value.toLowerCase();

      if (!name.contains(query)) return false;

      switch (selectedFilter.value) {
        case 1: // <1500cc
          return name.contains("civic") || name.contains("a4");
        case 2: // 1500–2500cc
          return name.contains("camry") || name.contains("mustang");
        case 3: // >2500cc
          return name.contains("model") || name.contains("x5");
        default:
          return true;
      }
    }).toList();
  }
}
