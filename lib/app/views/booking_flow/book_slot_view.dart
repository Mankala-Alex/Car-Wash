import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/custome_widgets/saved_location_options_sheet.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/saved_location_model.dart';
import 'package:car_wash_customer_app/app/models/offers/offer_coupon_model.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class BookSlotView extends GetView<BookSlotController> {
  const BookSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "confirm_car_wash".tr,
          style: const TextStyle(
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
                    "select_your_vehicle".tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefaultLight,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleList(context),

                  const SizedBox(height: 16),

                  // Slots are per service area, so WHERE comes before WHEN.
                  // The date/time pickers stay empty until an address resolved
                  // to one of the areas the business serves.
                  _buildLocationSection(context),
                  const SizedBox(height: 8),
                  _buildServiceabilityStatus(context),
                  const SizedBox(height: 20),

                  Text(
                    "select_date_and_time".tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefaultLight,
                        ),
                  ),
                  const SizedBox(height: 6),
                  _buildAreaGateHint(context),
                  const SizedBox(height: 10),

                  _buildDatePicker(context),
                  const SizedBox(height: 15),

                  _buildTimeSlots(context),
                  const SizedBox(height: 30),

// Apply Coupon - above Price Details
                  _buildApplyCouponRow(context),

                  const SizedBox(height: 20),
                  _buildPriceDetails(context),

                  const SizedBox(height: 10),
                  // IMPORTANT
                ],
              ),
            ),
          ),

          // ------------------ FIXED BOTTOM BUTTON ------------------
          _buildBottomConfirmBookingBar(context),
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
          BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, 5)),
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
                      "assets/carwash/car1.png",
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
                Text(
                  'service_details'.tr,
                  style: const TextStyle(
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
                    const RiyalSymbol(size: 18),
                    const SizedBox(width: 5),
                    Obx(
                      () => Text(
                        controller.price.value,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
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
    final double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.22, // Responsive height (22% of screen height)
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
              vehicleName: [v["make"], v["model"]]
                  .map((e) => (e ?? '').toString().trim())
                  .where((e) => e.isNotEmpty)
                  .join(' '),
              plateNumber: v["vehicle_number"] ?? "",
              imagePath: "assets/carwash/car1.png",
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
                  child: Image.asset(imagePath, fit: BoxFit.cover),
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
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 30,
              color: AppColors.textDefaultLight,
            ),
            const SizedBox(height: 8),
            Text(
              "add_new".tr,
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

  // ---------------- AREA GATE (slots are per area) ----------------

  /// Slots belong to a service area, so nothing can be picked before the
  /// address is known. This explains it instead of showing an empty row.
  Widget _buildAreaGateHint(BuildContext context) {
    return Obx(() {
      if (!controller.hasServiceArea) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.amber.shade800,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "choose_location_for_slots".tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final area = controller.serviceAreaName.value;
      return Text(
        area.isEmpty
            ? "slots_for_your_area".tr
            : "$area · ${"slots_for_your_area".tr}",
        style: TextStyle(
          fontSize: 12.5,
          color: AppColors.textDefaultLight.withOpacity(0.7),
        ),
      );
    });
  }

  // ---------------- DATE PICKER ----------------

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      // No area yet -> no dates (they are per area).
      if (!controller.hasServiceArea) return const SizedBox.shrink();

      if (controller.isLoadingDates.value) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.slotDates.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "no_dates_for_your_area".tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        );
      }

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
                      color: isSelected ? AppColors.primaryLight : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(d).toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textDefaultLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textDefaultLight,
                        ),
                      ),
                      Text(
                        DateFormat('EEE').format(d).toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textDefaultLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }

  // ---------------- TIME SLOTS ----------------

  Widget _buildTimeSlots(BuildContext context) {
    return Obx(() {
      // No area yet -> the slots of the area are unknown.
      if (!controller.hasServiceArea) return const SizedBox.shrink();

      if (controller.isLoadingTimes.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.selectedDate.value == null) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "please_select_a_date".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      }

      if (controller.slotTimes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "no_slots_available_for_this_date".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      }

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: controller.slotTimes.map((slot) {
          final label = slot.displayStartLabel;
          //final String label = "${slot.startTime} - ${slot.endTime}";
          final bool isSelected = controller.selectedTimeSlot.value == label;

          return ChoiceChip(
            showCheckmark: false,
            label: Text(label),
            selected: isSelected,
            onSelected: slot.isActive
                ? (_) => controller.updateSelectedTimeSlot(slot)
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

  Widget _buildServiceabilityStatus(BuildContext context) {
    return Obx(() {
      if (controller.selectedSavedLocation.value == null) {
        return const SizedBox.shrink();
      }

      final isChecking = controller.isCheckingServiceability.value;
      final isServiceable = controller.isServiceable.value;
      final message = controller.serviceabilityMessage.value;

      final color = isChecking
          ? Colors.orange
          : isServiceable
              ? Colors.green
              : Colors.red;

      final icon = isChecking
          ? Icons.autorenew
          : isServiceable
              ? Icons.check_circle
              : Icons.info_outline;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.isEmpty
                    ? 'checking_service_availability_short'.tr
                    : message,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   width: double.infinity,
        //   height: 150,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withValues(alpha: 0.05),
        //         spreadRadius: 1,
        //         blurRadius: 5,
        //         offset: const Offset(0, 3),
        //       ),
        //     ],
        //     image: const DecorationImage(
        //       image: AssetImage('assets/carwash/map.png'),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 16),

        // Static Home and Work locations
        // _buildAddressCard(
        //   context,
        //   icon: Icons.home_outlined,
        //   title: "Home",
        //   address: "123 Market St, San Francisco",
        // ),
        // const SizedBox(height: 12),
        // _buildAddressCard(
        //   context,
        //   icon: Icons.work_outline,
        //   title: "Work",
        //   address: "456 Tech Ave, Silicon Valley",
        // ),

        // Dynamically render saved locations
        Obx(() {
          if (controller.savedLocations.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: controller.savedLocations.map((location) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSavedLocationCard(
                    context,
                    location: location,
                    icon: Icons.location_on_outlined,
                    title: location.label,
                    address: location.address,
                    houseNo: location.houseNo,
                    landmark: location.landmark,
                    phoneNumber: location.phoneNumber,
                  ),
                ],
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            controller.openLocationPicker();
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
                    color: AppColors.secondaryLight.withValues(alpha: 0.15),
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
                    "add_new_address".tr,
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

  Widget _buildSavedLocationCard(
    BuildContext context, {
    required SavedLocation location,
    required IconData icon,
    required String title,
    required String address,
    required String houseNo,
    String? landmark,
    required String phoneNumber,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          controller.updateSelectedAddress(location);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedSavedLocation.value?.id == location.id
                  ? AppColors.primaryLight
                  : Colors.grey[300]!,
              width: controller.selectedSavedLocation.value?.id == location.id
                  ? 2
                  : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLightGrayLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 3-dot menu: Edit / Delete, same sheet as the Addresses screen.
              InkWell(
                onTap: () {
                  showSavedLocationOptionsSheet(controller, location);
                },
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.more_vert, color: Colors.black54, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PRICE DETAILS ----------------

  Widget _buildPriceDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "price_details".tr,
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
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // SERVICE PRICE
              Row(
                children: [
                  Text('service_price'.tr),
                  const Spacer(),
                  const RiyalSymbol(size: 15),
                  const SizedBox(width: 5),
                  Obx(
                    () => Text(
                      controller.servicePrice.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // DISCOUNT (only when a coupon is applied)
              Obx(
                () => controller.hasCouponApplied
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              'discount'.tr,
                              style: const TextStyle(
                                color: AppColors.textGreenLight,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '- ',
                              style: TextStyle(
                                color: AppColors.textGreenLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const RiyalSymbol(
                              size: 15,
                              color: AppColors.textGreenLight,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              controller.couponDiscountAmount.toStringAsFixed(
                                2,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGreenLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // VAT
              Obx(
                () => Row(
                  children: [
                    Text('${'vat'.tr} (${controller.vatPercentLabel}%)'),
                    const Spacer(),
                    const RiyalSymbol(size: 15),
                    const SizedBox(width: 5),
                    Text(
                      controller.displayVatAmount.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const Divider(height: 25),

              // TOTAL
              Row(
                children: [
                  Text(
                    'total_amount'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const RiyalSymbol(size: 18),
                  const SizedBox(width: 5),
                  Obx(
                    () => Text(
                      controller.totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDefaultLight,
                      ),
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 6),
              // const Divider(height: 25),

              // APPLY COUPON
              // _buildApplyCouponRow(context),
            ],
          ),
        ),
      ],
    );
  }

  /// "Apply coupon" row inside the price card. Opens a sheet with the coupons
  /// the backend says are valid for the selected service + slot.
  ///
  Widget _buildApplyCouponRow(BuildContext context) {
    return Obx(() {
      final applied = controller.appliedCoupon.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: applied != null
                ? AppColors.textGreenLight
                : AppColors.borderGray,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.secondaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied != null ? applied.code : 'apply_coupon'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDefaultLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Text(
                  //   applied != null
                  //       ? (applied.title.isNotEmpty
                  //           ? applied.title
                  //           : 'coupon_applied'.tr)
                  //       : 'available_coupons_hint'.tr,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     color: Colors.grey.shade600,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (applied != null)
              TextButton(
                onPressed: () {
                  controller.removeCoupon();
                  successToast('coupon_removed'.tr);
                },
                child: Text(
                  'remove'.tr.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else
              OutlinedButton(
                onPressed: () => _openCouponSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondaryLight,
                  side: const BorderSide(
                    color: AppColors.secondaryLight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: Text(
                  'View_coupons'.tr.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
  // Widget _buildApplyCouponRow(BuildContext context) {
  //   return Obx(() {
  //     final applied = controller.appliedCoupon.value;

  //     if (applied != null) {
  //       return Row(
  //         children: [
  //           const Icon(
  //             Icons.local_offer,
  //             size: 18,
  //             color: AppColors.textGreenLight,
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   applied.code,
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 if (applied.title.isNotEmpty)
  //                   Text(
  //                     applied.title,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //                   ),
  //               ],
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               controller.removeCoupon();
  //               successToast('coupon_removed'.tr);
  //             },
  //             child: Text('remove'.tr),
  //           ),
  //         ],
  //       );
  //     }

  //     return InkWell(
  //       onTap: () => _openCouponSheet(context),
  //       borderRadius: BorderRadius.circular(12),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 6),
  //         child: Row(
  //           children: [
  //             const Icon(
  //               Icons.local_offer_outlined,
  //               size: 18,
  //               color: AppColors.secondaryLight,
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 'apply_coupon'.tr,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   color: AppColors.secondaryLight,
  //                 ),
  //               ),
  //             ),
  //             const Icon(
  //               Icons.chevron_right,
  //               size: 20,
  //               color: AppColors.secondaryLight,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }

  /// Bottom sheet listing the coupons valid for the current service + slot.
  Future<void> _openCouponSheet(BuildContext context) async {
    if (controller.selectedSlotId.value == 0) {
      errorToast('please_select_a_time_slot'.tr);
      return;
    }

    controller.loadAvailableCoupons();

    await Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'apply_coupon'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'available_coupons_hint'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                if (controller.isLoadingCoupons.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.availableCoupons.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'no_coupons_available'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.availableCoupons.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final coupon = controller.availableCoupons[index];
                    return _couponTile(context, coupon);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _couponTile(BuildContext context, OfferCouponModel coupon) {
    final restrictions = coupon.restrictionsLabel;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            coupon.discountLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coupon.code,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (coupon.title.isNotEmpty)
                Text(
                  coupon.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              if (restrictions.isNotEmpty)
                Text(
                  restrictions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () async {
            final error = await controller.applyCoupon(coupon);

            if (error != null) {
              errorToast(error);
              return;
            }

            Get.back(); // close the sheet
            successToast('coupon_applied'.tr);
          },
          child: Text('apply'.tr),
        ),
      ],
    );
  }

  // ---------------- BOTTOM BAR ----------------

  Widget _buildBottomConfirmBookingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  "total".tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    const RiyalSymbol(size: 20),
                    const SizedBox(width: 5),
                    Obx(
                      () => Text(
                        controller.totalAmount.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(
              () => ElevatedButton(
                onPressed: controller.canConfirmBooking
                    ? () async {
                        await controller.bookSlot();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.canConfirmBooking
                      ? AppColors.secondaryLight
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: controller.isCheckingServiceability.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "confirm_book".tr,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textWhiteLight,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
