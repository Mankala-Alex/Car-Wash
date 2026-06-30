import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/models/google_places/place_details_model.dart';
import 'package:car_wash_customer_app/app/models/google_places/place_prediction_model.dart';
import 'package:car_wash_customer_app/app/repositories/google_places/google_places_repository.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';

class LocationPickerController extends GetxController {
  GoogleMapController? googleMapController;
  final GooglePlacesRepository _googlePlacesRepository =
      GooglePlacesRepository();

  Timer? _debounce;

  Future<void> moveCamera(LatLng location, {double zoom = 18}) async {
    if (googleMapController == null) return;

    await googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }

  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxString selectedAddress = "Select location on map".obs;
  RxBool isLoadingLocation = false.obs;
  final RxList<PlacePredictionModel> suggestions = <PlacePredictionModel>[].obs;

  final RxBool isSearching = false.obs;

  final TextEditingController searchController = TextEditingController();
  // RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        searchPlaces(query);
      },
    );
  }

  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      suggestions.clear();
      return;
    }

    try {
      isSearching.value = true;

      final response = await _googlePlacesRepository.autocomplete(query);

      if (response.statusCode == 200 && response.data["success"] == true) {
        final List data = response.data["data"];

        suggestions.assignAll(
          data.map((e) => PlacePredictionModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      print("Search error : $e");
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectPlace(String placeId) async {
    try {
      final response = await _googlePlacesRepository.getPlaceDetails(placeId);

      if (response.statusCode == 200 && response.data["success"] == true) {
        final place = PlaceDetailsModel.fromJson(response.data["data"]);
        final location = LatLng(
          place.latitude,
          place.longitude,
        );

        selectedLocation.value = location; // <-- ADD THIS

        selectedAddress.value = place.address;

        await moveCamera(location);

        searchController.text = place.address;

        suggestions.clear();

        FocusManager.instance.primaryFocus?.unfocus();
      }
    } catch (e) {
      print("Place details error : $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      print("🚀 Starting getCurrentLocation...");

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("📍 Location services enabled: $serviceEnabled");

      if (!serviceEnabled) {
        isLoadingLocation.value = false;

        Get.defaultDialog(
          title: "Location Required",
          middleText: "Please enable your device location to continue.",
          textConfirm: "Settings",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back();
            await Geolocator.openLocationSettings();
          },
        );

        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      print("📍 Current permission status: $permission");

      if (permission == LocationPermission.denied) {
        print("📍 Permission was denied, requesting permission...");
        permission = await Geolocator.requestPermission();
        print("📍 Permission after request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation.value = false;

        Get.defaultDialog(
          title: "Permission Required",
          middleText: "Please allow location permission from App Settings.",
          textConfirm: "Open Settings",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back();
            await Geolocator.openAppSettings();
          },
        );

        return;
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        isLoadingLocation.value = false;

        Get.snackbar(
          "Location Permission",
          "Location permission is required.",
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      print("✅ Permission granted");

      // Try to get current position first
      print("📍 Getting current position...");
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true,
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            print(
                "⏱️ getCurrentPosition timed out, trying last known position");
            throw TimeoutException('Location request timed out');
          },
        );

        print(
            "✅ Got current position: ${position.latitude}, ${position.longitude}");
        print("✅ Accuracy: ${position.accuracy}m");

        LatLng currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation.value = currentLocation;
        //markers.clear();

        // markers.add(
        //   Marker(
        //     markerId: const MarkerId("selected_location"),
        //     position: currentLocation,
        //   ),
        // );

        await moveCamera(currentLocation);

        // Get address from coordinates
        await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        print("✅ Location loaded successfully");
        isLoadingLocation.value = false;
      } catch (e) {
        print("⚠️ Failed to get current position: $e");
        print("📍 Attempting to get last known position as fallback...");

        Position? lastPosition = await Geolocator.getLastKnownPosition();

        if (lastPosition != null) {
          print(
              "✅ Got last known position: ${lastPosition.latitude}, ${lastPosition.longitude}");
          LatLng currentLocation =
              LatLng(lastPosition.latitude, lastPosition.longitude);

          selectedLocation.value = currentLocation;

          await moveCamera(currentLocation);

          // Get address from coordinates
          await getAddressFromCoordinates(
            lastPosition.latitude,
            lastPosition.longitude,
          );

          print("✅ Location loaded successfully (using fallback)");
          isLoadingLocation.value = false;
        } else {
          print("❌ No last known position available either");
          throw Exception('Could not get location');
        }
      }
    } catch (e, stackTrace) {
      print("❌ Error getting location: $e");
      print("📋 Stack trace: $stackTrace");

      isLoadingLocation.value = false;

      Get.snackbar(
        "Location Error",
        "Unable to get your current location. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        selectedAddress.value =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // Future<void> selectLocationOnMap(LatLng latLng) async {
  //   selectedLocation.value = latLng;

  //markers.clear();

  // markers.add(
  //   Marker(
  //     markerId: const MarkerId("selected_location"),
  //     position: latLng,
  //   ),
  // );
  //   await getAddressFromCoordinates(latLng.latitude, latLng.longitude);
  // }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void confirmLocation() {
    if (selectedLocation.value != null) {
      // Check if we're editing an existing location
      final args = Get.arguments ?? {};
      final isEditing = args['isEditing'] ?? false;
      final editingLocation = args['editingLocation'];

      // Navigate to location details screen with arguments
      Get.toNamed(
        Routes.locationDetails,
        arguments: {
          'latitude': selectedLocation.value!.latitude,
          'longitude': selectedLocation.value!.longitude,
          'address': selectedAddress.value,
          'editingLocation': isEditing ? editingLocation : null,
        },
      );
    } else {
      errorToast('error'.tr + 'please_select_a_location'.tr);
    }
  }

  void clearSearch() {
    searchController.clear();
    suggestions.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
