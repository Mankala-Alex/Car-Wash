import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  //wallet
  RxDouble selectedAmount = 1000.0.obs;
  RxInt selectedChipIndex = 1.obs;

  TextEditingController amountCtrl = TextEditingController(text: "1000");

  // DROPDOWN
  RxBool dropdownOpen = false.obs;
  RxInt selectedDropdownValue = 1000.obs;

  List<int> dropdownValues = [500, 1000, 2000, 5000, 10000];

  void toggleDropdown() {
    dropdownOpen.value = !dropdownOpen.value;
  }

  void selectDropdown(int value) {
    selectedDropdownValue.value = value;
    updateAmount(value.toDouble());
    dropdownOpen.value = false;
  }

  void updateAmount(double value) {
    selectedAmount.value = value;
    amountCtrl.text = value.toInt().toString();
    selectedChipIndex.value = -1;
  }

  void selectChip(int index, double value) {
    selectedChipIndex.value = index;
    updateAmount(value);
  }

  void onAmountTyped(String v) {
    selectedChipIndex.value = -1;
    selectedAmount.value = double.tryParse(v) ?? 0;
  }
}
