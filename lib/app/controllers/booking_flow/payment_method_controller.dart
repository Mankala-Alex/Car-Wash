import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/payment_controller.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/models/payment/saved_card_model.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/payment_services.dart';
import 'package:get/get.dart';

/// Lets the customer choose between Card and Apple Pay **before** any payment
/// attempt is created.
///
/// The Card branch delegates to the existing [PaymentController.payNow] flow
/// (`POST /api/payment/create` → `/payment_webview`) without modifying it.
/// Only the Apple Pay branch is new.
class PaymentMethodController extends GetxController {
  final PaymentService _service = PaymentService();

  static const String cardMethod = 'card';
  static const String applePayMethod = 'apple_pay';

  /// Paymob KSA unified checkout. Only used when the backend does not return an
  /// explicit checkout URL alongside the Apple Pay intention.
  static const String paymobKsaUnifiedCheckout =
      'https://ksa.paymob.com/unifiedcheckout/';

  /// Raw arguments received from the Payment Details screen. Forwarded intact
  /// so no booking information is lost between screens.
  late final Map<String, dynamic> bookingArguments = Map<String, dynamic>.from(
    Get.arguments ?? const {},
  );

  // ==============================
  // STATE
  // ==============================

  final RxBool isLoadingMethods = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString methodsError = RxnString();
  final RxString selectedMethod = ''.obs;

  final RxBool cardEnabled = false.obs;
  final RxBool applePayEnabled = false.obs;

  // ==============================
  // SAVED CARDS
  // ==============================

  /// Cards this customer already saved with Paymob (loaded from our backend).
  final RxList<SavedCardModel> savedCards = <SavedCardModel>[].obs;

  /// `null` means "pay with a new card".
  final RxnInt selectedSavedCardId = RxnInt();

  /// Ask Paymob to save the card that will be typed in the checkout.
  final RxBool saveCardForNextTime = false.obs;

  final RxBool isLoadingSavedCards = false.obs;
  final RxnInt deletingSavedCardId = RxnInt();

  SavedCardModel? get selectedSavedCard {
    final id = selectedSavedCardId.value;

    if (id == null) return null;

    for (final card in savedCards) {
      if (card.id == id) return card;
    }

    return null;
  }

  // ==============================
  // BOOKING DATA
  // ==============================

  String customerId = '';
  String customerName = '';
  String vehicle = '';
  String serviceId = '';
  String serviceName = '';
  int slotId = 0;
  String scheduledAt = '';
  double amount = 0.0;

  double? latitude;
  double? longitude;
  String? pincode;
  String? city;
  String? formattedAddress;
  String? address;
  String? houseNumber;
  String? landmark;
  String? addressLabel;

  String image = '';

  bool get hasAnyMethod => cardEnabled.value || applePayEnabled.value;

  @override
  void onInit() {
    super.onInit();

    _readBookingArguments();
    loadPaymentMethods();
  }

  void _readBookingArguments() {
    final args = bookingArguments;

    customerId = args['customer_id']?.toString() ?? '';
    customerName = args['customer_name']?.toString() ?? '';
    vehicle = args['vehicle']?.toString() ?? '';

    serviceId = args['service_id']?.toString() ?? '';
    serviceName = args['service_name']?.toString() ?? '';

    slotId = int.tryParse(args['slot_id']?.toString() ?? '0') ?? 0;

    scheduledAt = args['scheduled_at']?.toString() ?? '';

    amount = double.tryParse(args['amount']?.toString() ?? '0') ?? 0.0;

    latitude = args['latitude'] == null
        ? null
        : double.tryParse(args['latitude'].toString());

    longitude = args['longitude'] == null
        ? null
        : double.tryParse(args['longitude'].toString());

    pincode = args['pincode']?.toString();
    city = args['city']?.toString();
    formattedAddress = args['formatted_address']?.toString();
    address = args['address']?.toString();
    houseNumber = args['house_number']?.toString();
    landmark = args['landmark']?.toString();
    addressLabel = args['address_label']?.toString();

    image = args['image']?.toString() ?? '';
  }

  // ==============================
  // AVAILABLE METHODS
  // ==============================

  Future<void> loadPaymentMethods() async {
    isLoadingMethods.value = true;
    methodsError.value = null;

    try {
      final response = await _service.fetchPaymentMethods();

      if (response['success'] != true) {
        methodsError.value =
            _serverMessage(response) ?? 'Could not load payment methods.';
        return;
      }

      final methods = response['payment_methods'];

      cardEnabled.value = _isEnabled(methods, 'card');
      applePayEnabled.value =
          _isEnabled(methods, 'apple_pay') || _isEnabled(methods, 'applePay');

      if (!hasAnyMethod) {
        methodsError.value = 'No payment method is currently available.';
        return;
      }

      // Preselect the default Card option so Continue is usable immediately.
      if (selectedMethod.value.isEmpty ||
          (selectedMethod.value == cardMethod && !cardEnabled.value) ||
          (selectedMethod.value == applePayMethod && !applePayEnabled.value)) {
        selectedMethod.value = cardEnabled.value ? cardMethod : applePayMethod;
      }

      // Saved cards are only meaningful for the card branch.
      if (cardEnabled.value) {
        await loadSavedCards();
      }
    } catch (e) {
      print('❌ Payment methods error: $e');
      methodsError.value = 'Could not load payment methods. Please try again.';
    } finally {
      isLoadingMethods.value = false;
    }
  }

  /// Accepts both `{ "card": { "enabled": true } }` and `{ "card": true }`.
  bool _isEnabled(dynamic methods, String key) {
    // Handle the API response when payment_methods is a List.
    if (methods is List) {
      for (final method in methods) {
        if (method is Map &&
            method['id']?.toString().toLowerCase() == key.toLowerCase()) {
          final enabled = method['enabled'];

          return enabled == true || enabled?.toString().toLowerCase() == 'true';
        }
      }

      return false;
    }

    // Keep backward compatibility if the backend returns a Map.
    if (methods is Map) {
      final entry = methods[key];

      if (entry is bool) return entry;

      if (entry is Map) {
        final enabled = entry['enabled'];

        return enabled == true || enabled?.toString().toLowerCase() == 'true';
      }
    }

    return false;
  }

  String? _serverMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();

    if (message == null || message.isEmpty || message == 'null') return null;

    return message;
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  // ==============================
  // SAVED CARDS
  // ==============================

  /// Loads the customer's saved cards and preselects the default one so the
  /// card they saved last time is offered again at checkout.
  Future<void> loadSavedCards() async {
    isLoadingSavedCards.value = true;

    try {
      final cards = await _service.fetchSavedCards();

      savedCards.assignAll(cards);

      if (cards.isEmpty) {
        selectedSavedCardId.value = null;
        return;
      }

      final selectedStillExists = cards.any(
        (card) => card.id == selectedSavedCardId.value,
      );

      if (!selectedStillExists) {
        SavedCardModel? preferred;

        for (final card in cards) {
          if (card.isDefault) {
            preferred = card;
            break;
          }
        }

        selectedSavedCardId.value = (preferred ?? cards.first).id;
      }

      print("💳 Saved cards: ${cards.length} "
          "(selected: ${selectedSavedCardId.value})");
    } finally {
      isLoadingSavedCards.value = false;
    }
  }

  /// Selects a saved card, or `null` to pay with a new one.
  void selectSavedCard(int? cardId) {
    selectedSavedCardId.value = cardId;

    // A card that is already saved never needs saving again.
    if (cardId != null) saveCardForNextTime.value = false;
  }

  void toggleSaveCardForNextTime(bool value) {
    // Saving only applies to a brand new card.
    if (selectedSavedCardId.value != null) return;

    saveCardForNextTime.value = value;
  }

  /// Deletes a saved card from the account.
  Future<void> deleteSavedCard(SavedCardModel card) async {
    if (deletingSavedCardId.value != null) return;

    deletingSavedCardId.value = card.id;

    try {
      final deleted = await _service.deleteSavedCard(card.id);

      if (!deleted) {
        errorToast("card_remove_failed".tr);
        return;
      }

      savedCards.removeWhere((saved) => saved.id == card.id);

      if (selectedSavedCardId.value == card.id) {
        selectedSavedCardId.value =
            savedCards.isEmpty ? null : savedCards.first.id;
      }

      successToast("card_removed".tr);
    } finally {
      deletingSavedCardId.value = null;
    }
  }

  // ==============================
  // CONTINUE
  // ==============================

  Future<void> continueWithSelected() async {
    // Guard against repeated taps creating duplicate payment attempts.
    if (isLoading.value) return;

    final method = selectedMethod.value;

    if (method.isEmpty) {
      errorToast('please_select_payment_method'.tr);
      return;
    }

    if (method == cardMethod && !cardEnabled.value) {
      errorToast('card_unavailable'.tr);
      return;
    }

    if (method == applePayMethod && !applePayEnabled.value) {
      errorToast('apple_pay_unavailable'.tr);
      return;
    }

    isLoading.value = true;

    try {
      if (method == cardMethod) {
        await _payWithCard();
      } else {
        await _payWithApplePay();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Reuses the existing, working card flow unchanged.
  Future<void> _payWithCard() async {
    // The Payment Details screen keeps its PaymentController alive underneath
    // this route, so its already-parsed booking data is reused.
    PaymentController cardFlow;
    try {
      cardFlow = Get.find<PaymentController>();
    } catch (_) {
      cardFlow = Get.put(PaymentController(), tag: 'standaloneCardFlow');
    }

    final savedCard = selectedSavedCard;

    final outcome = await cardFlow.payWithCard(
      // A saved card is already tokenized; only a new card can be saved.
      saveCard: savedCard == null && saveCardForNextTime.value,
      savedCardId: savedCard?.id,
    );

    // Paymob could not charge the saved card (expired token, tokenization
    // disabled, …). Nothing was charged, so put the customer on "new card"
    // and let them press Continue again instead of leaving them stuck.
    if (outcome == CardChargeOutcome.savedCardRejected) {
      selectedSavedCardId.value = null;

      await loadSavedCards();

      selectedSavedCardId.value = null;
    }
  }

  /// Creates the Paymob Apple Pay intention, then opens the checkout.
  Future<void> _payWithApplePay() async {
    try {
      final response = await _service.createApplePayPayment(
        customerId: customerId,
        customerName: customerName,
        vehicle: vehicle,
        serviceId: serviceId,
        serviceName: serviceName,
        slotId: slotId,
        scheduledAt: scheduledAt,
        amount: amount,
        latitude: latitude,
        longitude: longitude,
        pincode: pincode,
        city: city,
        formattedAddress: formattedAddress,
        address: address,
        houseNumber: houseNumber,
        landmark: landmark,
        addressLabel: addressLabel,
      );

      if (response['success'] != true) {
        errorToast(_serverMessage(response) ?? 'apple_pay_failed'.tr);
        return;
      }

      final attemptId = response['payment_attempt_id']?.toString() ?? '';
      final bookingReference = response['booking_reference']?.toString() ?? '';
      final clientSecret = response['client_secret']?.toString() ?? '';
      final publicKey = response['public_key']?.toString() ?? '';

      print(
        '🍎 APPLE PAY INTENTION → attempt: $attemptId, '
        'booking: $bookingReference, checkout: ${response['checkout']}',
      );

      if (attemptId.isEmpty) {
        errorToast('payment_init_failed'.tr);
        return;
      }

      final checkoutUrl = _resolveCheckoutUrl(
        response: response,
        publicKey: publicKey,
        clientSecret: clientSecret,
      );

      if (checkoutUrl == null) {
        errorToast('apple_pay_open_failed'.tr);
        return;
      }

      // Same route + same argument shape as the card flow, so payment status
      // verification and the confirmation screen stay identical.
      Get.toNamed(
        '/payment_webview',
        arguments: {
          'url': checkoutUrl,
          'paymentAttemptId': attemptId,
          'booking_reference': bookingReference,
          'service_name': serviceName,
          'scheduled_at': scheduledAt,
          'amount': amount,
          'image': image,
        },
      );
    } catch (e) {
      print('❌ Apple Pay error: $e');

      final errorText = e.toString();

      // The seat is reserved before the Apple Pay sheet opens, so a full slot
      // comes back as 409 SLOT_UNAVAILABLE and nothing is charged.
      if (errorText.contains('SLOT_UNAVAILABLE')) {
        errorToast('slot_no_longer_available'.tr);
        _returnToSlots();
        return;
      }

      final serviceAreaMessageMatch = RegExp(
        r'message\s*:\s*([^,\n}]+)',
      ).firstMatch(errorText);

      if (errorText.contains('SERVICE_AREA_NOT_AVAILABLE') &&
          serviceAreaMessageMatch != null) {
        final serviceAreaMessage = serviceAreaMessageMatch.group(1)?.trim();

        if (serviceAreaMessage != null &&
            serviceAreaMessage.isNotEmpty &&
            serviceAreaMessage != 'null') {
          errorToast(serviceAreaMessage);
          return;
        }
      }

      errorToast('apple_pay_failed_try_again'.tr);
    }
  }

  /// Returns to the slot picker with a refreshed list after the chosen time was
  /// taken by someone else. Nothing was charged in that case.
  void _returnToSlots() {
    try {
      final bookSlot = Get.find<BookSlotController>();
      bookSlot.refreshSelectedDateSlots();
    } catch (e) {
      print('⚠️ Could not refresh slots: $e');
    }

    Get.until(
      (route) => route.settings.name == Routes.bookslot || route.isFirst,
    );
  }

  /// Prefers a checkout URL supplied by the backend; otherwise builds the
  /// Paymob KSA unified checkout link from the returned intention keys.
  ///
  /// Only the publishable `public_key` is used — no secret or HMAC key ever
  /// reaches the app.
  String? _resolveCheckoutUrl({
    required Map<String, dynamic> response,
    required String publicKey,
    required String clientSecret,
  }) {
    for (final key in [
      'checkout_url',
      'redirect_url',
      'redirection_url',
      'url',
    ]) {
      final value = response[key]?.toString().trim() ?? '';

      if (value.startsWith('http')) return value;
    }

    if (publicKey.isEmpty || clientSecret.isEmpty) return null;

    return Uri.parse(paymobKsaUnifiedCheckout).replace(
      queryParameters: {
        'publicKey': publicKey,
        'clientSecret': clientSecret,
      },
    ).toString();
  }
}
