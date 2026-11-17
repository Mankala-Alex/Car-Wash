import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RiyalSymbol loads the Saudi Riyal SVG asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: RiyalSymbol(size: 24))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RiyalAmount renders the amount next to the symbol', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RiyalAmount(
              "45.5",
              prefix: "Total: ",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("Total: "), findsOneWidget);
    expect(find.textContaining("45.5"), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RiyalAmount fitToWidth shrinks instead of truncating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            // Narrow card like the dashboard service tiles.
            child: SizedBox(
              width: 78,
              child: RiyalAmount(
                "1234.56",
                fitToWidth: true,
                minFontSize: 8,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(RiyalAmount),
        matching: find.byType(RichText),
      ),
    );

    // No "1234…": the text must fit as-is.
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RiyalAmount keeps the base font size when it fits', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: RiyalAmount(
                "45",
                fitToWidth: true,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final RichText richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(RiyalAmount),
        matching: find.byType(RichText),
      ),
    );

    expect(richText.text.style?.fontSize, 16);
  });

  testWidgets('RiyalAmount fitToWidth also respects a bounded height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              // Tall text in a short slot must shrink, not overflow.
              height: 14,
              child: RiyalAmount(
                "45",
                fitToWidth: true,
                minFontSize: 6,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final RichText richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(RiyalAmount),
        matching: find.byType(RichText),
      ),
    );

    expect(richText.text.style?.fontSize, lessThan(16));
    expect(tester.takeException(), isNull);
  });
}
