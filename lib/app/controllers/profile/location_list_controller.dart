import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationListController extends GetxController {
  var addresses = <AddressModel>[
    AddressModel(
      title: "Work",
      distance: "8 m",
      fullAddress:
          "Floor 5, Miaprosoft, Vasavi MPM Grand, Yella Reddy Guda, Hyderabad",
      icon: Icons.apartment,
      isSelected: true,
    ),
    AddressModel(
      title: "Other",
      distance: "1.2 km",
      fullAddress: "pws42, SR Nagar, Hyderabad",
      icon: Icons.location_on_outlined,
    ),
    AddressModel(
      title: "Other",
      distance: "498 m",
      fullAddress:
          "alinagar nagar padmaja hostel, ali nagar, Yousufguda, Hyderabad",
      icon: Icons.location_on_outlined,
    ),
    AddressModel(
      title: "Home",
      distance: "258 m",
      fullAddress:
          "1, anupama ladies pg, sri chakra food court, Delta Chambers, Mumbai Highway",
      icon: Icons.home_filled,
    ),
  ].obs;

  // -----------------------------------------------------
  // SHOW BOTTOM SHEET (like the screenshot)
  // -----------------------------------------------------
  void showBottomSheet(AddressModel item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.fullAddress,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // ---- Edit Button ----
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black87),
              title: const Text(
                "Edit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
              },
            ),

            const Divider(),

            // ---- Delete Button ----
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                "Delete",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
              onTap: () {
                addresses.remove(item);
                Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class AddressModel {
  String title;
  String distance;
  String fullAddress;
  IconData icon;
  bool isSelected;

  AddressModel({
    required this.title,
    required this.distance,
    required this.fullAddress,
    required this.icon,
    this.isSelected = false,
  });
}
