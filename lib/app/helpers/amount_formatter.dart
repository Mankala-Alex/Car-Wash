/// Formats a money value for display.
///
/// Money columns are stored as `numeric` on the backend and often reach the app
/// as raw floating point strings (e.g. `45.123200000000004`), which look broken
/// on screen. Every amount is therefore rounded to **at most two decimals** and
/// trailing zeros are dropped:
///
/// ```dart
/// formatAmount("45.123200000000004"); // "45.12"
/// formatAmount(35.45);                // "35.45"
/// formatAmount("35.50");              // "35.5"
/// formatAmount(35);                   // "35"
/// ```
String formatAmount(dynamic value, {String fallback = "0"}) {
  if (value == null) return fallback;

  final double? parsed = value is num
      ? value.toDouble()
      : double.tryParse(value.toString().trim());

  // Not a number (e.g. an empty string or "N/A"): keep whatever came in.
  if (parsed == null || parsed.isNaN || parsed.isInfinite) {
    return value.toString();
  }

  // Round first so 45.123200000000004 becomes 45.12.
  final double rounded = double.parse(parsed.toStringAsFixed(2));

  if (rounded == 0) return "0";

  // Whole amounts carry no decimals at all (35.00 -> 35).
  if (rounded == rounded.roundToDouble()) {
    return rounded.toStringAsFixed(0);
  }

  // Keep the second decimal only when it is meaningful (35.50 -> 35.5).
  final String text = rounded.toStringAsFixed(2);
  return text.endsWith("0") ? text.substring(0, text.length - 1) : text;
}
