import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class LocationPickerController extends GetxController {
  final MapController mapController = MapController();

  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxString selectedAddress = "Select location on map".obs;
  RxBool isLoadingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      print("🚀 Starting getCurrentLocation...");

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("📍 Location services enabled: $serviceEnabled");

      if (!serviceEnabled) {
        print("⚠️ Location services are disabled on this device");
        _useDefaultLocation();
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
        print("❌ Location permission permanently denied");
        _useDefaultLocation();
        return;
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("❌ Location permission not granted: $permission");
        _useDefaultLocation();
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
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    // Default to Riyadh, Saudi Arabia
    LatLng defaultLocation = const LatLng(24.7136, 46.6753);
    selectedLocation.value = defaultLocation;
    selectedAddress.value = "Riyadh, Saudi Arabia (Default)";
    isLoadingLocation.value = false;
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

  Future<void> selectLocationOnMap(LatLng latLng) async {
    selectedLocation.value = latLng;
    await getAddressFromCoordinates(latLng.latitude, latLng.longitude);
  }

  void confirmLocation() {
    if (selectedLocation.value != null) {
      Get.back(result: {
        'latitude': selectedLocation.value!.latitude,
        'longitude': selectedLocation.value!.longitude,
        'address': selectedAddress.value,
      });
    } else {
      Get.snackbar('Error', 'Please select a location');
    }
  }
}
