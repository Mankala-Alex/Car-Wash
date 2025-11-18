import 'package:flutter/material.dart';

class DirectionalWidget extends StatelessWidget {
  final Widget child;

  const DirectionalWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
}
