import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class Page3View extends GetView<DashboardController> {
  const Page3View({super.key});

  @override
  Widget build(BuildContext context) {
    // initialize controller

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "My Wallet",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),

              // WALLET BALANCE CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xffFFD2A2), Color(0xffFFD2A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Available Balance",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Image.asset(
                                "assets/carwash/SAR.png",
                                width: 30,
                                height: 30,
                                //color: AppColors.primaryLight,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text("150.00",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Image.asset("assets/carwash/cash.png", height: 70),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ADD MONEY Button
              GestureDetector(
                onTap: () => _openAddMoneySheet(context),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xffFF9A2A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "Add Money",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  // BOTTOM SHEET
  void _openAddMoneySheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return DraggableScrollableSheet(
              maxChildSize: 0.85,
              minChildSize: 0.40,
              initialChildSize: 0.55,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 15,
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // 👈 keyboard push
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ENTER AMOUNT
                            const Text("Enter Amount",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 12),

                            // Amount input + DROPDOWN ICON
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                  color: const Color(0xffF7F7F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                children: [
                                  const Text("₹",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: controller.amountCtrl,
                                      keyboardType: TextInputType.number,
                                      onChanged: controller.onAmountTyped,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                      decoration: const InputDecoration(
                                          border: InputBorder.none),
                                    ),
                                  ),

                                  // ▼ dropdown button
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Amount chips
                            Row(
                              children: [
                                _chip("+ ₹500", 0, 500),
                                _chip("+ ₹1000", 1, 1000),
                                _chip("+ ₹2000", 2, 2000),
                              ],
                            ),

                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 12),

                            // PAYMENT BLOCK
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Center(
                                                child: Text("UPI",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text("Pay Using",
                                              style: TextStyle(
                                                  color: Colors.black54)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Text("PhonePe UPI",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),

                                // RED TOTAL BOX
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 1),
                                  decoration: BoxDecoration(
                                      color: AppColors.secondaryLight,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "₹${controller.selectedAmount.value.toInt()}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Proceed to pay ₹${controller.selectedAmount.value.toInt()}")));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: const Text("Add money ▸",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  // CHIP WIDGET
  Widget _chip(String text, int index, double value) {
    return Obx(() {
      bool selected = controller.selectedChipIndex.value == index;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => controller.selectChip(index, value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.orange.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected ? Colors.orange : Colors.grey.shade300),
            ),
            child: Text(
              text,
              style: TextStyle(
                  color: selected ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    });
  }
}
