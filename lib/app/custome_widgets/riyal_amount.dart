import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Path of the official Saudi Riyal symbol artwork.
const String saudiRiyalSymbolAsset = "assets/app_icon/Saudi_Riyal_Symbol.svg";

/// Width / height ratio of the artwork (`viewBox="0 0 1124.14 1256.39"`).
const double _riyalSymbolAspectRatio = 1124.14 / 1256.39;

/// Renders the Saudi Riyal symbol (﷼) as an image instead of the "SAR" text.
///
/// ```dart
/// const RiyalSymbol(size: 18);              // next to a `Text` widget
/// RiyalSymbol(size: 22, color: Colors.blue) // tinted
/// ```
class RiyalSymbol extends StatelessWidget {
  const RiyalSymbol({super.key, this.size = 16, this.color});

  /// Height of the symbol. The width follows the artwork aspect ratio.
  final double size;

  /// Tint applied to the symbol. Defaults to the ambient text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF231F20);

    return SvgPicture.asset(
      saudiRiyalSymbolAsset,
      height: size,
      width: size * _riyalSymbolAspectRatio,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      semanticsLabel: "SAR",
    );
  }
}

/// Builds the inline spans of an amount followed by the Riyal symbol.
///
/// Useful when the amount is part of a bigger [Text.rich] paragraph:
///
/// ```dart
/// Text.rich(
///   TextSpan(children: riyalAmountSpans(amount: "45.00", prefix: "Total: ")),
///   style: style,
/// );
/// ```
List<InlineSpan> riyalAmountSpans({
  Object? amount,
  String? prefix,
  String? suffix,
  TextStyle? style,
  double? symbolHeight,
  Color? symbolColor,
  bool symbolFirst = false,
}) {
  final String text = amount == null ? "" : amount.toString();
  final double height = symbolHeight ?? (style?.fontSize ?? 15);

  final List<InlineSpan> spans = [
    if (prefix != null && prefix.isNotEmpty) TextSpan(text: prefix),
  ];

  // Nothing to show: keep the surrounding text but never draw a lone symbol.
  if (text.isEmpty) {
    if (suffix != null && suffix.isNotEmpty) {
      spans.add(TextSpan(text: suffix));
    }
    return spans;
  }

  final InlineSpan symbol = WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: RiyalSymbol(size: height, color: symbolColor),
  );

  if (symbolFirst) {
    spans.add(symbol);
    spans.add(const TextSpan(text: " "));
  }

  spans.add(TextSpan(text: text));

  if (!symbolFirst) {
    spans.add(const TextSpan(text: " "));
    spans.add(symbol);
  }

  if (suffix != null && suffix.isNotEmpty) {
    spans.add(TextSpan(text: suffix));
  }

  return spans;
}

/// Drop-in replacement for `Text("<amount> SAR")` that renders the Riyal
/// symbol image instead of the "SAR" word.
///
/// ```dart
/// RiyalAmount(formatAmount(booking.amount), style: style);
/// RiyalAmount(offer.value, prefix: "Save ", suffix: " off");
/// ```
class RiyalAmount extends StatelessWidget {
  const RiyalAmount(
    this.amount, {
    super.key,
    this.prefix,
    this.suffix,
    this.style,
    this.symbolHeight,
    this.symbolColor,
    this.symbolFirst = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.fitToWidth = false,
    this.minFontSize = 10,
  });

  /// Amount to display (String or num).
  final Object? amount;

  /// Optional text placed before the amount.
  final String? prefix;

  /// Optional text placed after the symbol.
  final String? suffix;

  final TextStyle? style;

  /// Height of the symbol; defaults to the text size.
  final double? symbolHeight;

  /// Tint of the symbol; defaults to the text colour.
  final Color? symbolColor;

  /// Draws the symbol before the amount instead of after it.
  final bool symbolFirst;

  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;

  /// Shrinks the amount just enough to fit the width handed down by the
  /// parent instead of truncating it (no more `13.8…` on narrow cards).
  ///
  /// The text is rendered at the original `style.fontSize` whenever it fits,
  /// so every phone keeps the same look; only an over-long amount on a narrow
  /// card is drawn a little smaller.
  final bool fitToWidth;

  /// Smallest font size allowed while shrinking when [fitToWidth] is enabled.
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle effective = DefaultTextStyle.of(
      context,
    ).style.merge(style);

    final double baseFontSize = effective.fontSize ?? 16;
    // Keep the historical default symbol height (`style.fontSize` or 15) for
    // the regular, non-shrinking rendering.
    final double baseSymbolSize = symbolHeight ?? (style?.fontSize ?? 15);

    if (!fitToWidth) {
      return _buildText(effective, baseSymbolSize);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fitted = _largestFittingFontSize(
          context: context,
          effective: effective,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          baseFontSize: baseFontSize,
          baseSymbolSize: baseSymbolSize,
        );

        final double fittedSymbol = baseFontSize == 0
            ? baseSymbolSize
            : baseSymbolSize * (fitted / baseFontSize);

        return _buildText(effective.copyWith(fontSize: fitted), fittedSymbol);
      },
    );
  }

  Widget _buildText(TextStyle effective, double symbolSize) {
    return Text.rich(
      TextSpan(
        children: riyalAmountSpans(
          amount: amount,
          prefix: prefix,
          suffix: suffix,
          style: effective,
          symbolHeight: symbolSize,
          symbolColor: symbolColor ?? effective.color,
          symbolFirst: symbolFirst,
        ),
      ),
      style: effective,
      maxLines: fitToWidth ? 1 : maxLines,
      overflow: fitToWidth ? TextOverflow.ellipsis : overflow,
      textAlign: textAlign,
      softWrap: fitToWidth ? false : softWrap,
    );
  }

  /// Plain string used to measure the amount (the Riyal symbol is an image, so
  /// its width is computed from its own aspect ratio).
  String get _plainAmount {
    final String value = amount == null ? "" : amount.toString();
    if (value.isEmpty) return "";

    final String body = "${prefix ?? ""}$value${suffix ?? ""}";
    return symbolFirst ? " $body" : "$body ";
  }

  /// Measures the amount (without the symbol) at [fontSize].
  Size _measure(BuildContext context, TextStyle effective, double fontSize) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
          text: _plainAmount, style: effective.copyWith(fontSize: fontSize)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final Size size = painter.size;
    painter.dispose();
    return size;
  }

  double _largestFittingFontSize({
    required BuildContext context,
    required TextStyle effective,
    required double maxWidth,
    required double maxHeight,
    required double baseFontSize,
    required double baseSymbolSize,
  }) {
    final double lowerBound =
        minFontSize < baseFontSize ? minFontSize : baseFontSize;

    double symbolWidth(double fontSize) {
      final double symbolSize = baseFontSize == 0
          ? baseSymbolSize
          : baseSymbolSize * (fontSize / baseFontSize);
      return symbolSize * _riyalSymbolAspectRatio;
    }

    double fontSize = baseFontSize;

    // 1) Vertical: the single line must also fit the height handed down by the
    //    parent (service cards are tight, so an oversized style would push the
    //    card into a "bottom overflowed" warning).
    final Size baseSize = _measure(context, effective, baseFontSize);
    if (maxHeight.isFinite &&
        maxHeight > 0 &&
        baseSize.height > 0 &&
        baseSize.height > maxHeight) {
      fontSize *= (maxHeight / baseSize.height) * 0.98;
    }

    // 2) Horizontal: the text width grows almost linearly with the font size,
    //    so a couple of proportional estimates are enough (and much cheaper
    //    than a full binary search on every rebuild).
    if (maxWidth.isFinite && maxWidth > 0) {
      double needed =
          _measure(context, effective, fontSize).width + symbolWidth(fontSize);

      for (int i = 0;
          i < 3 && needed > maxWidth && fontSize > lowerBound;
          i++) {
        final double estimate = fontSize * (maxWidth / needed) * 0.98;
        fontSize = estimate < lowerBound
            ? lowerBound
            : (estimate > fontSize ? fontSize : estimate);
        needed = _measure(context, effective, fontSize).width +
            symbolWidth(fontSize);
      }
    }

    if (fontSize > baseFontSize) return baseFontSize;
    return fontSize < lowerBound ? lowerBound : fontSize;
  }
}
