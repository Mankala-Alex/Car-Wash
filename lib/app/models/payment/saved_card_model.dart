/// A card the customer asked Paymob to save at checkout.
///
/// Only Paymob's opaque token plus display metadata exists server-side, and the
/// token itself is never sent to the app — [id] is what the payment API accepts
/// back to pay with this card again.
class SavedCardModel {
  final int id;
  final String maskedPan;
  final String cardBrand;
  final int? expiryMonth;
  final int? expiryYear;
  final String? holderName;
  final bool isDefault;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  const SavedCardModel({
    required this.id,
    required this.maskedPan,
    required this.cardBrand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
    required this.isDefault,
    required this.lastUsedAt,
    required this.createdAt,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      maskedPan: json["masked_pan"]?.toString() ?? "",
      cardBrand: json["card_brand"]?.toString() ?? "",
      expiryMonth: int.tryParse(json["expiry_month"]?.toString() ?? ""),
      expiryYear: int.tryParse(json["expiry_year"]?.toString() ?? ""),
      holderName: json["holder_name"]?.toString(),
      isDefault: json["is_default"] == true ||
          json["is_default"]?.toString().toLowerCase() == "true",
      lastUsedAt: DateTime.tryParse(json["last_used_at"]?.toString() ?? ""),
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
    );
  }

  /// Human readable card label, e.g. `VISA •••• 1111`.
  ///
  /// Paymob's `masked_pan` already contains the trailing digits with x/asterisk
  /// padding, so an empty value falls back to a generic label instead of
  /// producing a dangling bullet.
  String get displayLabel {
    final brand = cardBrand.isNotEmpty ? cardBrand : "CARD";
    final digits = _lastFourDigits;

    if (digits.isEmpty) return brand;

    return "$brand •••• $digits";
  }

  String get _lastFourDigits {
    final digitsOnly = maskedPan.replaceAll(RegExp(r"[^0-9]"), "");

    if (digitsOnly.length >= 4) {
      return digitsOnly.substring(digitsOnly.length - 4);
    }

    return digitsOnly;
  }

  /// `12/29`, or an empty string when Paymob did not return an expiry.
  String get formattedExpiry {
    if (expiryMonth == null || expiryYear == null) return "";

    final month = expiryMonth!.toString().padLeft(2, "0");
    final year = expiryYear! >= 100
        ? (expiryYear! % 100).toString().padLeft(2, "0")
        : expiryYear!.toString().padLeft(2, "0");

    return "$month/$year";
  }
}
