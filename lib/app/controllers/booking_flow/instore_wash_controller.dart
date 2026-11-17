import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_wash_customer_app/app/models/instores_model.dart';
import 'package:car_wash_customer_app/app/repositories/instore_repository.dart';

class InstoreWashController extends GetxController {
  final InstoreRepository repository = InstoreRepository();

  RxBool isLoading = false.obs;
  RxList<InstoresModel> stores = <InstoresModel>[].obs;
  RxList<InstoresModel> filteredStores = <InstoresModel>[].obs;
  RxString searchQuery = ''.obs;

  /// Where the customer currently is. Used to compute the distance shown on
  /// every partner card and to order the list nearest first.
  final Rxn<Position> customerPosition = Rxn<Position>();

  /// `store.id` -> distance from the customer in kilometres.
  final RxMap<String, double> distancesKm = <String, double>{}.obs;

  final RxBool isLoadingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInStoreWashStores();
    loadCustomerLocation();
  }

  Future<void> fetchInStoreWashStores() async {
    try {
      isLoading.value = true;

      final response = await repository.getInStoreWashStores();
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : <dynamic>[];

      stores.value = data.map((e) => InstoresModel.fromJson(e)).toList();
      _recomputeDistances();
      applyFilters();
    } catch (e) {
      debugPrint("Error fetching stores: $e");
      stores.clear();
      filteredStores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ===== CUSTOMER LOCATION (for distance) =====
  /// Resolves the device position once so every partner can be measured
  /// against it. Fails silently: without a fix the cards simply do not show a
  /// distance and the list keeps the API order.
  Future<void> loadCustomerLocation() async {
    try {
      isLoadingLocation.value = true;

      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint("Distance hidden: location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        debugPrint("Distance hidden: location permission not granted");
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          // Medium accuracy is plenty for a kilometre-level distance and it
          // returns much faster than `best`.
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint("Current position unavailable ($e), trying last known");
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) return;

      customerPosition.value = position;
      _recomputeDistances();
      applyFilters();
    } catch (e) {
      debugPrint("Error resolving customer location: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// Recomputes the customer -> partner distances (in km) for every store that
  /// has usable coordinates. Partners without coordinates are left out, they
  /// are then sorted to the end of the list.
  void _recomputeDistances() {
    final Position? from = customerPosition.value;
    if (from == null) return;

    final Map<String, double> next = <String, double>{};

    for (final InstoresModel store in stores) {
      final loc = store.location;
      if (loc == null) continue;
      if (loc.lat == 0 && loc.lng == 0) continue;

      next[store.id] = Geolocator.distanceBetween(
            from.latitude,
            from.longitude,
            loc.lat,
            loc.lng,
          ) /
          1000;
    }

    distancesKm.assignAll(next);
  }

  // ===== SEARCH + NEAREST-FIRST SORT =====
  void searchStores(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final String query = searchQuery.value.trim().toLowerCase();

    final List<InstoresModel> result = stores.where((store) {
      return query.isEmpty ||
          store.companyName.toLowerCase().contains(query) ||
          store.city.toLowerCase().contains(query) ||
          store.streetName.toLowerCase().contains(query) ||
          store.district.toLowerCase().contains(query);
    }).toList();

    // Nearest partner first; stores without coordinates keep the API order at
    // the bottom of the list.
    result.sort((a, b) {
      final double? da = distancesKm[a.id];
      final double? db = distancesKm[b.id];
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    filteredStores.assignAll(result);
  }

  /// Distance to [store] in kilometres, or null when not known yet.
  double? distanceFor(InstoresModel store) => distancesKm[store.id];

  /// Human readable distance, e.g. `850 m` or `2.3 km`. Empty when unknown.
  String distanceLabel(InstoresModel store) {
    final double? km = distancesKm[store.id];
    if (km == null) return "";

    if (km < 1) return "${(km * 1000).round()} ${'m_short'.tr}";

    return "${km.toStringAsFixed(km < 10 ? 1 : 0)} ${'km'.tr}";
  }

  // ===== PHONE CALL FUNCTION =====
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Phone call error: $e');
    }
  }

  // ===== OPEN GOOGLE MAPS WITH NAVIGATION =====
  Future<void> openLocationInGoogleMaps(double lat, double lng) async {
    if (lat == 0 && lng == 0) {
      debugPrint('Location coordinates are missing');
      return;
    }

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Google Maps launch error: $e');
    }
  }
}
