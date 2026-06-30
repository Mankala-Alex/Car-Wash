import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:car_wash_customer_app/app/controllers/booking_flow/location_picker_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerView extends GetView<LocationPickerController> {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          "pick_location".tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            if (controller.isLoadingLocation.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.selectedLocation.value ??
                    const LatLng(24.7136, 46.6753),
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              onMapCreated: (GoogleMapController mapController) {
                controller.googleMapController = mapController;

                if (controller.selectedLocation.value != null) {
                  mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      controller.selectedLocation.value!,
                      17,
                    ),
                  );
                }
              },
              onCameraMove: (CameraPosition position) {
                controller.selectedLocation.value = position.target;
              },
              onCameraIdle: () async {
                final location = controller.selectedLocation.value;

                if (location != null) {
                  await controller.getAddressFromCoordinates(
                    location.latitude,
                    location.longitude,
                  );
                }
              },
            );
          }),
          Positioned(
            top: MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() {
                    if (controller.isSearching.value) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    if (controller.searchController.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.clearSearch,
                      );
                    }

                    return const SizedBox();
                  }),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 16,
            right: 16,
            child: Obx(() {
              if (controller.suggestions.isEmpty) {
                return const SizedBox();
              }

              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 250,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = controller.suggestions[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.secondaryLight,
                        ),
                        title: Text(
                          item.mainText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();

                          controller.selectPlace(item.placeId);
                        },
                      );
                    },
                  ),
                ),
              );
            }),
          ),

          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 55,
                ),
              ),
            ),
          ),
          // Current location button
          Positioned(
            bottom: 120,
            right: 16,
            child: Obx(() {
              return FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.secondaryLight,
                onPressed: controller.isLoadingLocation.value
                    ? null
                    : () => controller.getCurrentLocation(),
                child: controller.isLoadingLocation.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
              );
            }),
          ),

          // Bottom sheet with address and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "selected_location".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.secondaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() {
                            return Text(
                              controller.selectedAddress.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.confirmLocation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "confirm_location".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
