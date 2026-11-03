# Booking and Location Flow Analysis

This report documents the current implementation found in the Flutter project as of the current codebase. No application code was modified.

## 1) Current Booking Flow

### 1.1 Booking screen/page

- FILE PATH: `lib/app/views/booking_flow/book_slot_view.dart`
- CLASS: `BookSlotView`
- METHOD: `build()`
- Trigger button: `BookSlotView._buildBottomConfirmBookingBar()` -> `onPressed: () async { await controller.bookSlot(); }`

### 1.2 Booking controller

- FILE PATH: `lib/app/controllers/booking_flow/book_slot_controller.dart`
- CLASS: `BookSlotController`
- METHOD: `bookSlot()`

### 1.3 Booking repository

- FILE PATH: `lib/app/repositories/auth/book_service/book_slot_repository.dart`
- CLASS: `BookSlotRepository`
- METHOD: `postBookSlot(requestBody)`

### 1.4 Booking service/API service

- FILE PATH: `lib/app/services/api_service.dart`
- CLASS: `ApiService`
- METHOD: `post(String endpoint, Map<String, dynamic> data, { bool requireAuthToken = false })`

- FILE PATH: `lib/app/services/endpoints.dart`
- CLASS: `EndPoints`
- VARIABLE: `apiPostbookslot = 'bookings'`

### 1.5 Booking model/request model

- FILE PATH: `lib/app/models/booking slot/book_slot_model.dart`
- CLASS: `BookSlotModel`
- Relevant fields include: `latitude`, `longitude`, `formattedAddress`, `address`, `houseNumber`, `landmark`, `addressLabel`

This model exists, but the current flow does not appear to build a `BookSlotModel` instance for the booking request. The request is built as a raw `Map<String, dynamic>` in `BookSlotController.bookSlot()`.

### 1.6 Method that actually creates the booking

The current code does NOT actually call the booking creation API from `BookSlotController.bookSlot()`.

The method that actually executes a booking-like request in the current flow is:

- FILE PATH: `lib/app/controllers/booking_flow/payment_controller.dart`
- CLASS: `PaymentController`
- METHOD: `payNow()`

and it calls:

- FILE PATH: `lib/app/services/payment_services.dart`
- CLASS: `PaymentService`
- METHOD: `createPayment({...})`

This sends a POST request to:

- `EndPoints.apiPaymentCreate` = `"payment/create"`

### 1.7 Exact API endpoint used in current flow

Current project code path:

`BookSlotController.bookSlot()`
  -> `Get.toNamed(Routes.payment)`
  -> `PaymentController.payNow()`
  -> `PaymentService.createPayment()`
  -> `ApiService.post(EndPoints.apiPaymentCreate, requestBody, requireAuthToken: true)`

Therefore, the active route is:

- ENDPOINT: `payment/create`
- METHOD: `POST`
- AUTH: `requireAuthToken: true`

However, the repository method for booking creation exists and is defined as:

- FILE PATH: `lib/app/repositories/auth/book_service/book_slot_repository.dart`
- METHOD: `postBookSlot(requestBody)`
- ENDPOINT: `EndPoints.apiPostbookslot` = `'bookings'`
- METHOD: `POST`
- AUTH: `requireAuthToken: true`

BUT this method is not invoked by the current booking flow in `BookSlotController.bookSlot()`.

### 1.8 Exact request body in current booking flow

The real booking request body currently built in `BookSlotController.bookSlot()` is:

```dart
final body = {
  "customer_id": customerUuid,
  "customer_name": customerName,
  "vehicle": selectedVehicle.value,
  "service_id": serviceId,
  "service_name": name,
  "slot_id": selectedSlotId.value,
  "scheduled_at": buildScheduledAt(),
  "amount": priceNumber,
  "status": "PENDING",
  "latitude": location?.latitude,
  "longitude": location?.longitude,
  "formatted_address": location?.address,
  "address": location?.address,
  "house_number": location?.houseNo,
  "landmark": location?.landmark,
  "address_label": location?.label,
};
```

This body is printed in the controller with:

```dart
print("📤 FINAL BOOKING BODY → $body");
```

But the code immediately does:

```dart
Get.toNamed(
  Routes.payment,
  arguments: {...same data...},
);
```

and does not call `repository.postBookSlot(body)`.

So the current code builds a booking body, but does not send it to `POST /bookings` in the active flow.

### 1.9 Actual current booking/payment relationship

The current flow is:

- `BookSlotView` -> `BookSlotController.bookSlot()`
- Build body for booking data
- Navigate to payment screen: `Get.toNamed(Routes.payment, arguments: {...})`
- `PaymentController.payNow()`
- `PaymentService.createPayment()`
- `ApiService.post(EndPoints.apiPaymentCreate, requestBody, requireAuthToken: true)`

This is effectively:

`Create booking data locally -> Payment -> Payment service call`

It is not a direct `Create booking -> Payment -> Confirmation` flow, and there is no active `POST /bookings` request from this controller.

---

## 2) Current Location and Address Flow

### 2.1 Location screen/page

- FILE PATH: `lib/app/views/booking_flow/location_picker_view.dart`
- CLASS: `LocationPickerView`
- CONTROLLER: `LocationPickerController`

This is the map/location picker screen with GoogleMap and current location access.

### 2.2 Location controller

- FILE PATH: `lib/app/controllers/booking_flow/location_picker_controller.dart`
- CLASS: `LocationPickerController`
- Important variables:
  - `Rx<LatLng?> selectedLocation`
  - `RxString selectedAddress`
  - `GoogleMapController? googleMapController`
  - `final RxList<PlacePredictionModel> suggestions`

### 2.3 Address screen/page

- FILE PATH: `lib/app/views/profile/location_details_view.dart`
- CLASS: `LocationDetailsView`

This screen collects:

- house number
- landmark
- save-as label (`Home`, `Work`, `Other`)
- phone number

### 2.4 Address controller

- FILE PATH: `lib/app/controllers/profile/location_details_controller.dart`
- CLASS: `LocationDetailsController`

It receives arguments:

```dart
latitude = Get.arguments['latitude'] ?? 0.0;
longitude = Get.arguments['longitude'] ?? 0.0;
address = Get.arguments['address'] ?? '';
editingLocation = Get.arguments['editingLocation'];
```

Then it creates or updates a `SavedLocation` object with:

- `label`
- `address`
- `latitude`
- `longitude`
- `houseNo`
- `landmark`
- `phoneNumber`

### 2.5 Location picker

- FILE PATH: `lib/app/controllers/booking_flow/location_picker_controller.dart`
- CLASS: `LocationPickerController`
- METHODS:
  - `getCurrentLocation()`
  - `searchPlaces(String query)`
  - `selectPlace(String placeId)`
  - `getAddressFromCoordinates(double latitude, double longitude)`
  - `confirmLocation()`

### 2.6 Address model

- FILE PATH: `lib/app/models/booking slot/saved_location_model.dart`
- CLASS: `SavedLocation`
- Fields:
  - `id`
  - `label`
  - `address`
  - `latitude`
  - `longitude`
  - `houseNo`
  - `landmark`
  - `phoneNumber`

### 2.7 Saved address model

- Same file: `lib/app/models/booking slot/saved_location_model.dart`
- CLASS: `SavedLocation`

### 2.8 Location helper/service

- Google Maps display: `GoogleMap` widget in `LocationPickerView`
- Google Places backend calls: `GooglePlacesRepository`
- Geolocator GPS: `Geolocator.getCurrentPosition()`
- Reverse geocoding: `placemarkFromCoordinates(latitude, longitude)` from `geocoding` package

### 2.9 Current location sources / technology used

Confirmed in code:

- Google Maps: YES
  - `package:google_maps_flutter/google_maps_flutter.dart`
  - `GoogleMap` widget used in `LocationPickerView`

- Google Places: YES (via backend endpoints)
  - `GooglePlacesRepository.autocomplete()`
  - `GooglePlacesRepository.getPlaceDetails()`
  - Endpoints: `maps/autocomplete` and `maps/place-details`

- Geocoding: YES
  - `placemarkFromCoordinates(latitude, longitude)` in `LocationPickerController.getAddressFromCoordinates()`

- flutter_map: NOT FOUND

- OpenStreetMap: NOT FOUND

- GPS/current location: YES
  - `Geolocator.isLocationServiceEnabled()`
  - `Geolocator.getCurrentPosition()`

- Manual address entry: YES
  - `LocationDetailsView` collects house number and landmark after location selection

- Saved addresses: YES (local storage only)
  - `savedLocations` is stored in `SharedPreferences` under the key `"savedLocations"`

- Any other API: YES — Google Places backend API calls, and payment API (`payment/create`)

### 2.10 How the selected location address is built

`LocationPickerController.getAddressFromCoordinates()`:

```dart
List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

if (placemarks.isNotEmpty) {
  Placemark place = placemarks[0];
  selectedAddress.value =
      "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
}
```

This is a human-readable string built from `Placemark` fields, not a structured postal-code field.

---

## 3) Latitude and Longitude Flow

### Search results

Confirmed variables and flows:

- `LocationPickerController.selectedLocation`
- `PlaceDetailsModel.latitude`
- `PlaceDetailsModel.longitude`
- `SavedLocation.latitude`
- `SavedLocation.longitude`
- `BookSlotController.selectedSavedLocation`
- `BookSlotController.bookSlot()` request body
- `PaymentController.latitude` / `longitude`
- `PaymentService.createPayment()` request body

### 3.1 Where latitude comes from

- GPS current location: `LocationPickerController.getCurrentLocation()`
  ```dart
  Position position = await Geolocator.getCurrentPosition(...)
  LatLng currentLocation = LatLng(position.latitude, position.longitude);
  selectedLocation.value = currentLocation;
  ```

- Google Places selected result: `LocationPickerController.selectPlace()`
  ```dart
  final place = PlaceDetailsModel.fromJson(response.data["data"]);
  final location = LatLng(place.latitude, place.longitude);
  selectedLocation.value = location;
  ```

- Saved locations: `SavedLocation.latitude` loaded from `SharedPreferences`

### 3.2 Where longitude comes from

Same as above:

- `Geolocator.getCurrentPosition()` -> `position.longitude`
- `PlaceDetailsModel.longitude`
- `SavedLocation.longitude`

### 3.3 Which controller stores them

- `LocationPickerController`
  - `selectedLocation` is `Rx<LatLng?>`

- `BookSlotController`
  - `selectedSavedLocation` is `Rx<SavedLocation?>`

- `PaymentController`
  - `latitude` and `longitude` are nullable doubles read from navigation arguments

### 3.4 Which model stores them

- `PlaceDetailsModel`
  - `double latitude; double longitude;`

- `SavedLocation`
  - `double latitude; double longitude;`

- `BookSlotModel`
  - fields for `latitude` and `longitude` exist

### 3.5 How they are passed between screens

#### Location picker -> location details

`LocationPickerController.confirmLocation()`:

```dart
Get.toNamed(
  Routes.locationDetails,
  arguments: {
    'latitude': selectedLocation.value!.latitude,
    'longitude': selectedLocation.value!.longitude,
    'address': selectedAddress.value,
    'editingLocation': isEditing ? editingLocation : null,
  },
);
```

#### Location details -> saved locations -> booking

`LocationDetailsController.saveLocation()` creates a `SavedLocation` and then:

```dart
bookSlotController.addSavedLocation(savedLocation);
```

`BookSlotController.updateSelectedAddress(String title)` sets:

```dart
selectedSavedLocation.value = location;
```

Then in `BookSlotController.bookSlot()`:

```dart
final location = selectedSavedLocation.value;

final body = {
  "latitude": location?.latitude,
  "longitude": location?.longitude,
  "formatted_address": location?.address,
  "address": location?.address,
  "house_number": location?.houseNo,
  "landmark": location?.landmark,
  "address_label": location?.label,
};
```

### 3.6 Are latitude/longitude stored locally?

YES.

- `SavedLocation` objects are stored in `SharedPreferences` under the key `"savedLocations"`
- `BookSlotController.loadSavedLocations()` reads them back

### 3.7 Are latitude/longitude included in the booking request?

YES in the request body built in `BookSlotController.bookSlot()`.

But note: this request body is not sent by the current code path. It is only built and then passed to navigation arguments for the payment flow.

---

## 4) Pincode / Postal Code Investigation

### 4.1 Search keywords used

The following terms were searched across the project:

- `pincode`
- `pinCode`
- `postal_code`
- `postalCode`
- `postcode`
- `postCode`
- `zip`
- `zipCode`
- `postal`
- `postalcode`
- `address`
- `formatted_address`
- `formattedAddress`
- `city`
- `state`
- `region`
- `country`

### 4.2 Current status

PINCODE IS NOT CURRENTLY AVAILABLE IN THE FLUTTER BOOKING FLOW.

Confirmed findings:

- No `pincode`/`postal_code` field exists in the current booking request body.
- No `pincode` variable exists in the `BookSlotController`, `LocationPickerController`, `LocationDetailsController`, `PaymentController`, or request models.
- No `zip`/`postal`/`postcode` field is used in the booking flow.
- Reverse geocoding via `placemarkFromCoordinates()` gets a `Placemark`, but the code only pulls:
  - `street`
  - `locality`
  - `administrativeArea`

It does not extract or store `postalCode`.

### 4.3 Evidence in app code

`LocationPickerController.getAddressFromCoordinates()`:

```dart
Placemark place = placemarks[0];
selectedAddress.value =
    "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
```

No `place.postalCode` is read.

### 4.4 Pincode in request fields

The booking / payment request bodies include:

- `latitude`
- `longitude`
- `formatted_address`
- `address`
- `house_number`
- `landmark`
- `address_label`

They do NOT include:

- `pincode`
- `postal_code`
- `postalCode`
- `zip`
- `zipCode`
- `postcode`

### 4.5 Saved addresses and pincode

`SavedLocation` model fields:

```dart
final String id;
final String label;
final String address;
final double latitude;
final double longitude;
final String houseNo;
final String? landmark;
final String phoneNumber;
```

No `pincode` field exists.

### 4.6 Address hierarchy actually present

Address-related fields that exist in the code:

- `address` (string)
- `formatted_address` (string)
- `house_number` (string)
- `landmark` (string)
- `address_label` (string)
- `latitude` (double)
- `longitude` (double)

Fields not currently present:

- `pincode`
- `postal_code`
- `postalCode`
- `postcode`
- `zip`
- `zipCode`
- `city`
- `state`
- `region`
- `country`

---

## 5) Google Maps / Address Data Check

### 5.1 Google Maps usage

Confirmed file:

- `lib/app/views/booking_flow/location_picker_view.dart`

Code:

```dart
return GoogleMap(
  initialCameraPosition: CameraPosition(
    target: controller.selectedLocation.value ?? const LatLng(24.7136, 46.6753),
    zoom: 16,
  ),
  myLocationEnabled: true,
  myLocationButtonEnabled: false,
  zoomControlsEnabled: false,
  compassEnabled: true,
  ...
);
```

### 5.2 Google Places usage

Confirmed files:

- `lib/app/repositories/google_places/google_places_repository.dart`
- `lib/app/models/google_places/place_prediction_model.dart`
- `lib/app/models/google_places/place_details_model.dart`

Endpoints in `EndPoints`:

```dart
static const apiPlaceAutocomplete = "maps/autocomplete";
static const apiPlaceDetails = "maps/place-details";
```

`PlaceDetailsModel.fromJson()` receives:

```dart
return PlaceDetailsModel(
  latitude: (json["latitude"] ?? 0).toDouble(),
  longitude: (json["longitude"] ?? 0).toDouble(),
  address: json["address"] ?? "",
  name: json["name"] ?? "",
);
```

This model has only the following fields:

- `latitude`
- `longitude`
- `address`
- `name`

No postal code, city, state, or country fields are extracted.

### 5.3 Reverse geocoding actual fields extracted

`LocationPickerController.getAddressFromCoordinates()`:

```dart
Placemark place = placemarks[0];
selectedAddress.value =
    "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
```

So the app receives and stores only:

- `street`
- `locality`
- `administrativeArea`

It does not use:

- `postalCode`
- `subAdministrativeArea`
- `country`
- `isoCountryCode`
- `subLocality`

The code does not create a structured address object with those fields.

---

## 6) Saved Address Flow

### 6.1 Save addresses

Yes, customers can save addresses in the local app flow.

Evidence:

- `LocationDetailsView` -> `LocationDetailsController.saveLocation()`
- `SavedLocation` model
- `BookSlotController.addSavedLocation()`
- `BookSlotController.loadSavedLocations()`
- `SharedPrefsHelper.setString("savedLocations", locationsJson)`

### 6.2 Saved address model and storage

- FILE PATH: `lib/app/models/booking slot/saved_location_model.dart`
- CLASS: `SavedLocation`

Stored shape:

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'label': label,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'houseNo': houseNo,
    'landmark': landmark,
    'phoneNumber': phoneNumber,
  };
}
```

### 6.3 Local storage key

- FILE PATH: `lib/app/controllers/booking_flow/book_slot_controller.dart`
- METHOD: `loadSavedLocations()`

```dart
String? locationsJson = await SharedPrefsHelper.getString("savedLocations");
```

- FILE PATH: `lib/app/helpers/shared_preferences.dart`
- METHOD: `setString(String key, String value)`

So this is local app storage, not a backend address API.

### 6.4 Create / update / get address APIs

No backend CRUD endpoints for saved addresses were found in the current app code.

- Create address API: NOT FOUND
- Update address API: NOT FOUND
- Get addresses API: NOT FOUND
- Selected address logic: local only through `savedLocations` list and `SharedPreferences`

### 6.5 Does saved address contain pincode / city / state / region / country?

No. `SavedLocation` contains:

- `label`
- `address`
- `latitude`
- `longitude`
- `houseNo`
- `landmark`
- `phoneNumber`

It does not contain any pincode or structured city/state/country fields.

---

## 7) Trace Selected Address into Booking

### 7.1 Customer selects address

Flow:

1. `BookSlotView._buildSavedLocationCard()` taps:
   ```dart
   onTap: () {
     controller.updateSelectedAddress(title);
   }
   ```

2. `BookSlotController.updateSelectedAddress(String title)`:
   ```dart
   selectedAddress.value = title;

   final location = savedLocations.firstWhereOrNull(
     (e) => e.label == title,
   );

   if (location != null) {
     selectedSavedLocation.value = location;
   }
   ```

3. Later `BookSlotController.bookSlot()` does:
   ```dart
   final location = selectedSavedLocation.value;
   ```

4. Booking / payment payload built from `location`:
   ```dart
   "latitude": location?.latitude,
   "longitude": location?.longitude,
   "formatted_address": location?.address,
   "address": location?.address,
   "house_number": location?.houseNo,
   "landmark": location?.landmark,
   "address_label": location?.label,
   ```

### 7.2 Data variables involved

Actual names found:

- `selectedAddress` : `Rx<String?>` in `BookSlotController`
- `selectedSavedLocation` : `Rx<SavedLocation?>` in `BookSlotController`
- `location` local variable in `BookSlotController.bookSlot()`
- `latitude`, `longitude` in `BookSlotController.bookSlot()` and `PaymentController`
- `formatted_address`, `address`, `house_number`, `landmark`, `address_label` in request maps

### 7.3 The selected address is not sent to a booking API in the current flow

The code builds the map but then navigates away to payment instead of calling the booking repository.

---

## 8) Exact Booking Request Body and Field-by-Field Status

### 8.1 Final body built in current app code

`BookSlotController.bookSlot()` builds:

```dart
final body = {
  "customer_id": customerUuid,
  "customer_name": customerName,
  "vehicle": selectedVehicle.value,
  "service_id": serviceId,
  "service_name": name,
  "slot_id": selectedSlotId.value,
  "scheduled_at": buildScheduledAt(),
  "amount": priceNumber,
  "status": "PENDING",
  "latitude": location?.latitude,
  "longitude": location?.longitude,
  "formatted_address": location?.address,
  "address": location?.address,
  "house_number": location?.houseNo,
  "landmark": location?.landmark,
  "address_label": location?.label,
};
```

### 8.2 Field status

| FIELD | STATUS | SOURCE | FILE | VARIABLE |
|---|---|---|---|---|
| customer_id | CURRENTLY SENT in built map | `customerUuid` loaded from `SharedPrefsHelper` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `customerUuid` |
| customer_name | CURRENTLY SENT in built map | `customerName` loaded from `SharedPrefsHelper` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `customerName` |
| vehicle | CURRENTLY SENT in built map | `selectedVehicle.value` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedVehicle` |
| service_id | CURRENTLY SENT in built map | `serviceId` from navigation args | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `serviceId` |
| service_name | CURRENTLY SENT in built map | `name` from navigation args | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `name` |
| slot_id | CURRENTLY SENT in built map | `selectedSlotId.value` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSlotId` |
| scheduled_at | CURRENTLY SENT in built map | `buildScheduledAt()` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `buildScheduledAt()` |
| amount | CURRENTLY SENT in built map | `priceNumber` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `priceNumber` |
| latitude | CURRENTLY SENT in built map | `location?.latitude` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation` |
| longitude | CURRENTLY SENT in built map | `location?.longitude` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation` |
| formatted_address | CURRENTLY SENT in built map | `location?.address` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation.address` |
| address | CURRENTLY SENT in built map | `location?.address` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation.address` |
| house_number | CURRENTLY SENT in built map | `location?.houseNo` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation.houseNo` |
| landmark | CURRENTLY SENT in built map | `location?.landmark` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation.landmark` |
| address_label | CURRENTLY SENT in built map | `location?.label` | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `selectedSavedLocation.label` |
| pincode | NOT CURRENTLY SENT | NOT FOUND | NOT FOUND | NOT FOUND |
| postal_code | NOT CURRENTLY SENT | NOT FOUND | NOT FOUND | NOT FOUND |

### 8.3 Actual payment request body

`PaymentService.createPayment()` sends:

```dart
final requestBody = {
  "customer_id": customerId,
  "customer_name": customerName,
  "vehicle": vehicle,
  "service_id": serviceId,
  "service_name": serviceName,
  "slot_id": slotId,
  "scheduled_at": scheduledAt,
  "amount": amount,
  "latitude": latitude,
  "longitude": longitude,
  "formatted_address": formattedAddress,
  "address": address,
  "house_number": houseNumber,
  "landmark": landmark,
  "address_label": addressLabel,
};
```

This is also missing `pincode`.

---

## 9) Repository / API Service Trace

### 9.1 Booking repository chain

Current booking repository exists:

- `lib/app/repositories/auth/book_service/book_slot_repository.dart`
  - `postBookSlot(requestBody)`

```dart
Future<Response> postBookSlot(requestBody) async {
  return await ApiService.post(EndPoints.apiPostbookslot, requestBody,
      requireAuthToken: true);
}
```

### 9.2 API service chain

- `lib/app/services/api_service.dart`
- `ApiService.post()` uses Dio and sets `data: data` and `options: Options(extra: {"auth": requireAuthToken})`

### 9.3 Where the chain stops in the actual flow

The real flow currently stops before this repository call:

`BookSlotController.bookSlot()`
  -> builds `body`
  -> `Get.toNamed(Routes.payment, arguments: {...})`
  -> `PaymentController.payNow()`
  -> `PaymentService.createPayment()`
  -> `ApiService.post(EndPoints.apiPaymentCreate, requestBody, requireAuthToken: true)`

Therefore the repository `postBookSlot` is defined but unused in the active code path.

---

## 10) Error Handling

### 10.1 Booking API errors

There is no active booking API call in the current flow, so there is no direct booking-error handling for `POST /bookings` in `BookSlotController`.

The user-facing errors in the current code are mostly toast-based from helper functions and from payment service exceptions.

### 10.2 Payment error handling

- `PaymentController.payNow()` catches `Exception` and calls:
  ```dart
  errorToast("payment_failed".tr);
  ```

- `PaymentService.createPayment()` catches `DioException` and throws:
  ```dart
  throw Exception(
    "Payment create failed: "
    "${e.response?.statusCode} - ${e.response?.data}",
  );
  ```

### 10.3 HTTP 400 / 401 / 403 / 500

These are not explicitly handled in app logic for booking creation.

The `ApiService` interceptor logs details but does not convert them into custom UI flows for booking errors. It prints request and response details.

### 10.4 `DioException`

`ApiService` logs `DioException` details:

```dart
if (error.response != null) {
  print("⬅️ Response status: ${error.response?.statusCode}");
  print("⬅️ Response data: ${error.response?.data}");
}
```

This is a log-only path, not a user-facing structured error mapping.

### 10.5 Response data / toast / snackbar / dialog

These are used in different places:

- `errorToast(...)` for message toasts
- `Get.snackbar(...)` for location errors in `LocationPickerController.getCurrentLocation()`
- `Get.defaultDialog(...)` for location permission requirements

For booking/payment failure, the code mostly uses `errorToast("payment_failed".tr)` or `errorToast("booking_failed".tr)` when code paths are used.

### 10.6 What would happen for backend service-area pincode error?

The app would not currently render or handle a specific `SERVICE_AREA_NOT_AVAILABLE` error because it does not send a `pincode` field and does not inspect `response.data["error"]` or `response.data["details"]` in the booking flow.

The payment service does catch `DioException`, but the exception is thrown and then bubbled to `PaymentController.payNow()`, which then displays a generic payment failure toast.

So for the backend responses:

```json
{
  "error": "SERVICE_AREA_NOT_AVAILABLE",
  "message": "No valid customer pincode was provided for service-area verification."
}
```

or

```json
{
  "error": "SERVICE_AREA_NOT_AVAILABLE",
  "details": "This pincode is not currently serviced",
  "pincode": "12345"
}
```

The current app does not have logic to parse, display, or act on `error`, `message`, `details`, or `pincode` in the booking/payment flow.

---

## 11) Payment Flow

### 11.1 Payment controller

- FILE PATH: `lib/app/controllers/booking_flow/payment_controller.dart`
- CLASS: `PaymentController`
- METHOD: `payNow()`

### 11.2 Payment service

- FILE PATH: `lib/app/services/payment_services.dart`
- CLASS: `PaymentService`
- METHOD: `createPayment({...})`

### 11.3 Payment API

- FILE PATH: `lib/app/services/endpoints.dart`
- VARIABLE: `apiPaymentCreate = "payment/create"`

### 11.4 Payment status API

- `apiPaymentStatus = "payment/status"`
- `apiPaymentStatusByAttempt = "payment/status/attempt"`

### 11.5 Confirmation screen

- FILE PATH: `lib/app/views/booking_flow/payment_webview.dart`
- (Used after payment URL navigation)

### 11.6 Navigation after payment

`PaymentController.payNow()` does:

```dart
Get.toNamed(
  "/payment_webview",
  arguments: {
    "url": paymentUrl,
    "paymentAttemptId": paymentAttemptId,
    "booking_reference": bookingReference,
    "service_name": serviceName,
    "scheduled_at": scheduledAt,
    "amount": amount,
    "image": image,
  },
);
```

### 11.7 Relationship to booking

The current app flow is effectively:

`BookSlotController.bookSlot()` -> store booking details + navigate to payment -> `PaymentController.payNow()` -> `PaymentService.createPayment()` -> `payment/create`

There is no active direct booking creation call in this sequence.

---

## 12) Local Storage Findings

### 12.1 SharedPreferences and related helpers

- FILE PATH: `lib/app/helpers/shared_preferences.dart`
- CLASS: `SharedPrefsHelper`

### 12.2 Keys found relevant to location/address storage

- `savedLocations`
- `customerUuid`
- `customerName`
- `customerPhone`
- `accessToken`
- localization keys: `language_code`, `country_code`

### 12.3 Address-related values stored locally

In `BookSlotController.loadSavedLocations()`:

```dart
String? locationsJson = await SharedPrefsHelper.getString("savedLocations");
```

The saved objects are `SavedLocation` instances with:

- `address`
- `latitude`
- `longitude`
- `houseNo`
- `landmark`
- `label`
- `phoneNumber`

### 12.4 Pincode storage

No pincode or postal code key was found in any relevant local storage logic.

---

## 13) Current Flow Diagram

```text
Customer
   ↓
BookSlotView
   ↓
BookSlotController.bookSlot()
   ↓
Build booking data map with:
   customer_id
   customer_name
   vehicle
   service_id
   service_name
   slot_id
   scheduled_at
   amount
   latitude
   longitude
   formatted_address
   address
   house_number
   landmark
   address_label
   ↓
No POST /bookings call in current flow
   ↓
Navigate to payment screen
   ↓
PaymentController.payNow()
   ↓
PaymentService.createPayment()
   ↓
POST payment/create
   ↓
Backend
```

Location/address flow:

```text
Customer
   ↓
LocationPickerView
   ↓
LocationPickerController.getCurrentLocation()
   │   or searchPlaces() / selectPlace()
   ↓
selectedLocation = LatLng(latitude, longitude)
   ↓
getAddressFromCoordinates(latitude, longitude)
   ↓
selectedAddress = "street, locality, administrativeArea"
   ↓
LocationDetailsView
   ↓
LocationDetailsController.saveLocation()
   ↓
SavedLocation model
   ↓
SharedPreferences key: "savedLocations"
   ↓
BookSlotController.selectedSavedLocation
   ↓
BookSlotController.bookSlot() builds map for booking/payment
```

Pincode is not included in this diagram because it is not present in the actual Flutter code.

---

## 14) Final Status Table

| Item | Status | File Path | Class | Method/Variable | Source |
|------|--------|-----------|-------|-----------------|--------|
| Booking screen | FOUND | `lib/app/views/booking_flow/book_slot_view.dart` | `BookSlotView` | `build()` | User flow |
| Booking controller | FOUND | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `BookSlotController` | `bookSlot()` | Active booking flow |
| Booking repository | FOUND | `lib/app/repositories/auth/book_service/book_slot_repository.dart` | `BookSlotRepository` | `postBookSlot(requestBody)` | Defined but unused |
| Booking API | FOUND (defined) / NOT ACTIVE | `lib/app/services/endpoints.dart` | `EndPoints` | `apiPostbookslot = 'bookings'` | Repository definition |
| Location screen | FOUND | `lib/app/views/booking_flow/location_picker_view.dart` | `LocationPickerView` | `build()` | Map selection flow |
| Location controller | FOUND | `lib/app/controllers/booking_flow/location_picker_controller.dart` | `LocationPickerController` | `getCurrentLocation()`, `selectPlace()` | GPS + Google Places |
| Address model | FOUND | `lib/app/models/booking slot/saved_location_model.dart` | `SavedLocation` | model fields | Local saved address |
| Saved address | FOUND | `lib/app/controllers/booking_flow/book_slot_controller.dart` | `BookSlotController` | `savedLocations`, `loadSavedLocations()` | Local SharedPreferences |
| Latitude | FOUND | `lib/app/controllers/booking_flow/location_picker_controller.dart` | `LocationPickerController` | `selectedLocation`, `position.latitude` | GPS/Places |
| Longitude | FOUND | `lib/app/controllers/booking_flow/location_picker_controller.dart` | `LocationPickerController` | `selectedLocation`, `position.longitude` | GPS/Places |
| Formatted address | FOUND | `lib/app/controllers/booking_flow/location_picker_controller.dart` | `LocationPickerController` | `selectedAddress.value` | geocoding string |
| Address | FOUND | `lib/app/models/booking slot/saved_location_model.dart` | `SavedLocation` | `address` | saved location |
| House number | FOUND | `lib/app/controllers/profile/location_details_controller.dart` | `LocationDetailsController` | `houseNoController.text` | manual detail entry |
| Landmark | FOUND | `lib/app/controllers/profile/location_details_controller.dart` | `LocationDetailsController` | `landmarkController.text` | manual detail entry |
| Address label | FOUND | `lib/app/models/booking slot/saved_location_model.dart` | `SavedLocation` | `label` | saved location |
| Pincode | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | No pincode field in flow |
| Postal code | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | No postal code field in flow |
| City | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | Not extracted/stored |
| State | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | Not extracted/stored |
| Region | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | Not extracted/stored |
| Country | NOT FOUND | NOT FOUND | NOT FOUND | NOT FOUND | Not extracted/stored |
| Payment flow | FOUND | `lib/app/controllers/booking_flow/payment_controller.dart` | `PaymentController` | `payNow()` | Payment screen |
| Booking error handling | FOUND (generic) | `lib/app/services/api_service.dart` and `lib/app/controllers/booking_flow/payment_controller.dart` | `ApiService`, `PaymentController` | logging + generic toast | No pincode-specific handling |

---

## 15) Final Conclusions

1. Does the Flutter app currently have a pincode/postal code?
   - NO. The current app does not have a pincode/postal code field in the booking flow.

2. If yes, exactly where does it come from?
   - Not applicable. It is not present.

3. If yes, is it currently sent to POST /api/bookings?
   - Not applicable. `POST /bookings` is defined in the repository but not invoked by the active flow.

4. If no, where does the customer's current address/location data come from?
   - GPS via `Geolocator.getCurrentPosition()` in `LocationPickerController.getCurrentLocation()`.
   - Google Places via `GooglePlacesRepository.autocomplete()` and `getPlaceDetails()`.
   - Reverse geocoding via `placemarkFromCoordinates()` used to build a `selectedAddress` string.
   - Saved addresses are local `SavedLocation` objects persisted in `SharedPreferences` under `"savedLocations"`.

5. Which exact Flutter file/method should eventually be changed to include the pincode?
   - The actual data-building point is `lib/app/controllers/booking_flow/book_slot_controller.dart` inside `BookSlotController.bookSlot()`, where the final request map is built.
   - The actual payment request data is also built in `lib/app/services/payment_services.dart` inside `PaymentService.createPayment()`.
   - If the backend now requires a pincode for service-area validation, the immediate current change site is the booking/map-building logic in `BookSlotController.bookSlot()`, and the same field would then need to be included in `PaymentService.createPayment()` if the payment endpoint expects it as well.

6. Will adding the pincode require changing the location UI, the booking UI, or only the existing data flow?
   - Based on the current code, the data flow must change to include the field. Whether the UI must change depends on whether the user is expected to input or confirm the pincode. The current app does not have a pincode UI field or structured address object, so the existing data flow and location/address model would need to be extended.

7. Is there anything in the current booking/payment flow that must NOT be changed?
   - The current active flow (`BookSlotController.bookSlot()` -> `Get.toNamed(Routes.payment)` -> `PaymentController.payNow()`) should not be altered in a way that bypasses payment initiation. The current code intentionally navigates to the payment screen rather than sending `POST /bookings` directly. This is part of the application's current structure and should be respected in any later implementation work.

## Final note

This project currently has location data (GPS + selected map address + saved address) and latitude/longitude, but no pincode/postal code in the Flutter app. The backend requirement for pincode validation does not currently match the app's request payload.
