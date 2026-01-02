import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class BookSlotView extends GetView<BookSlotController> {
  const BookSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Confirm Car Wash",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ------------------ SCROLL CONTENT ------------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceCard(context),
                  const SizedBox(height: 16),
                  Text(
                    "Select Your Vehicle",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefaultLight,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleList(context),

                  const SizedBox(height: 16),
                  Text(
                    "Select Date and Time",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefaultLight,
                        ),
                  ),
                  const SizedBox(height: 15),

                  _buildDatePicker(context),
                  const SizedBox(height: 15),

                  _buildTimeSlots(context),
                  const SizedBox(height: 30),

                  _buildLocationSection(context),
                  const SizedBox(height: 20),
                  _buildPriceDetails(context),

                  const SizedBox(height: 10),
                  // IMPORTANT
                ],
              ),
            ),
          ),

          // ------------------ FIXED BOTTOM BUTTON ------------------
          _buildBottomConfirmBookingBar(
              context, MediaQuery.of(context).size.width, controller.price),
        ],
      ),
    );
  }

  // ---------------- SERVICE CARD ----------------

  Widget _buildServiceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: controller.image.startsWith("http")
                ? Image.network(
                    controller.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/carwash/default_service.png",
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    controller.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SERVICE DETAILS',
                  style: TextStyle(
                    color: AppColors.textLightGrayLight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Image.asset(
                      "assets/carwash/SAR.png",
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      controller.price,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  controller.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller.features
                      .map(
                        (f) => Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.textGreenLight,
                            ),
                            const SizedBox(width: 6),
                            Text(f, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- VEHICLES ----------------

  Widget _buildVehicleList(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2, // controls height RELATIVE to width
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.customerVehicles.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            if (index == controller.customerVehicles.length) {
              return _buildAddVehicleCard(context);
            }

            final v = controller.customerVehicles[index];

            return _buildVehicleCard(
              context,
              vehicleName: "${v["make"]} ${v["model"]}",
              plateNumber: v["vehicle_number"] ?? "",
              imagePath: "assets/carwash/splash_2.jpg",
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context, {
    required String vehicleName,
    required String plateNumber,
    required String imagePath,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.updateSelectedVehicle(vehicleName),
        child: Container(
          width: Get.width * 0.55,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: controller.selectedVehicle.value == vehicleName
                  ? AppColors.secondaryLight
                  : AppColors.borderGray,
              width: controller.selectedVehicle.value == vehicleName ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 2.4, // same visual size as before
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                vehicleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                plateNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddVehicleCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(Routes.addcar);
        if (result == true) {
          controller.fetchCustomerVehicles();
        }
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline,
                size: 30, color: AppColors.textDefaultLight),
            const SizedBox(height: 8),
            Text(
              "Add New",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDefaultLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DATE PICKER ----------------

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 100,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.slotDates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (_, index) {
              final d = controller.slotDates[index].date;

              return Obx(() {
                final bool isSelected = controller.selectedDate.value != null &&
                    controller.isSameDate(controller.selectedDate.value!, d);

                return GestureDetector(
                  onTap: () => controller.updateSelectedDate(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primaryLight : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('MMM').format(d).toUpperCase(),
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDefaultLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Text('${d.day}',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDefaultLight)),
                        Text(DateFormat('EEE').format(d).toUpperCase(),
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDefaultLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              });
            }),
      );
    });
  }

  // ---------------- TIME SLOTS ----------------

  Widget _buildTimeSlots(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTimes.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.selectedDate.value == null) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Please select a date",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      }

      if (controller.slotTimes.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "No slots available for this date",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      }

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: controller.slotTimes.map((slot) {
          final label = slot.time;
          //final String label = "${slot.startTime} - ${slot.endTime}";
          final bool isSelected = controller.selectedTimeSlot.value == label;

          return ChoiceChip(
            showCheckmark: false,
            label: Text(label),
            selected: isSelected,
            onSelected: slot.isActive
                ? (_) => controller.updateSelectedTimeSlot(label, slot.id)
                : null,
            selectedColor: AppColors.primaryLight,
            disabledColor: Colors.grey.shade300,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: !slot.isActive
                  ? Colors.grey[800]
                  : (isSelected ? Colors.black : AppColors.textDefaultLight),
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: !slot.isActive
                    ? Colors.transparent
                    : (isSelected ? Colors.transparent : Colors.grey[500]!),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          );
        }).toList(),
      );
    });
  }

  // ---------------- LOCATION ----------------

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/carwash/map.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildAddressCard(
          context,
          icon: Icons.home_outlined,
          title: "Home",
          address: "123 Market St, San Francisco",
        ),
        const SizedBox(height: 12),
        _buildAddressCard(
          context,
          icon: Icons.work_outline,
          title: "Work",
          address: "456 Tech Ave, Silicon Valley",
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.addlocation);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
                    size: 24,
                    color: AppColors.secondaryLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Add New Address",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.updateSelectedAddress(title),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedAddress.value == title
                  ? AppColors.primaryLight
                  : Colors.grey[300]!,
              width: controller.selectedAddress.value == title ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.bgLight),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                    ),
                    Text(
                      address,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textLightGrayLight),
                    ),
                  ],
                ),
              ),
              Radio<bool>(
                value: true,
                groupValue: controller.selectedAddress.value == title,
                onChanged: (v) {
                  if (v == true) controller.updateSelectedAddress(title);
                },
                activeColor: AppColors.secondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PRICE DETAILS ----------------

  Widget _buildPriceDetails(BuildContext context) {
    // You can compute VAT / total here if needed
    const String vat = "5.00";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price Details",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDefaultLight,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Premium Wash',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/carwash/SAR.png",
                    width: 15,
                    height: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    controller.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    'VAT',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/carwash/SAR.png",
                    width: 15,
                    height: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    vat,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/carwash/SAR.png",
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    controller.price, // or calculated total
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDefaultLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- BOTTOM BAR ----------------

  Widget _buildBottomConfirmBookingBar(
      BuildContext context, double screenWidth, String totalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/carwash/SAR.png",
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      totalAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                controller.bookSlot();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                "Confirm Book",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textWhiteLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
